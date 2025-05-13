#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# use homebrew cut if installed
HOMEBREW_PREFIX="$(brew --prefix)"
if [[ -d "${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin" ]]; then
  PATH="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin:${PATH}"
fi

function crd_to_json_schema() {
  local api_version crd_group crd_kind crd_version document input kind

  echo "Processing ${1}..."
  input="input/${1}.yaml"
  if [[ "${1}" != "platformlog" ]]; then
    if ! curl -f -L --silent --show-error "${@:2}" > "${input}"; then
      echo "Failed to download ${1} from ${*:2}"
      return
    fi
  fi

  # Clean the input for compound schema docs that don't contain a yaml seperator (e.g., aso)
  perl -i -0pe 'BEGIN{undef $/;} s/(.+[^\-{3}]\s*)\napiVersion: apiextensions.k8s.io(.*)$/$1\n---\napiVersion: apiextensions.k8s.io$2/mg' "${input}"
  # Replace known problematic strings (adds {} as allowed characters for ASO objects)
  perl -i -0pe 's/\^\[-\\w\\._\\\(\\\)\]\+\$/\^\[-\\w\\._\\\(\\\)\\{\\}\]\+\$/g' "${input}"

  for document in $(seq 0 $(($(yq ea '[.] | length' "${input}") - 1))); do
    api_version=$(yq eval "select(documentIndex == ${document}) | .apiVersion" "${input}" | cut --delimiter=/ --fields=2)
    kind=$(yq eval "select(documentIndex == ${document}) | .kind" "${input}")
    crd_kind=$(yq eval "select(documentIndex == ${document}) | .spec.names.kind" "${input}" | tr '[:upper:]' '[:lower:]')
    crd_group=$(yq eval "select(documentIndex == ${document}) | .spec.group" "${input}" | cut --delimiter=. --fields=1)

    if [[ "${kind}" != CustomResourceDefinition ]]; then
      continue
    fi

    case "${api_version}" in
      v1beta1)
        echo "apiextensions: ${api_version} documentIndex: ${document} | kind: ${kind} crd_kind: ${crd_kind} crd_group: ${crd_group}"
        crd_version=$(yq eval "select(documentIndex == ${document}) | .spec.version" "${input}")
        if [ -n "${crd_version}" ]; then
          yq eval --prettyPrint -o json "select(documentIndex == ${document}) | .spec.validation.openAPIV3Schema" "${input}"  | write_schema "${crd_kind}-${crd_group}-${crd_version}.json"
        else
          for crd_version in $(yq eval "select(documentIndex == ${document}) | .spec.versions[].name" "${input}"); do
            yq eval --prettyPrint -o json "select(documentIndex == ${document}) | .spec.validation.openAPIV3Schema" "${input}" | write_schema "${crd_kind}-${crd_group}-${crd_version}.json"
          done
        fi
        ;;

      v1)
        echo "apiextensions: ${api_version} documentIndex: ${document} | kind: ${kind} crd_kind: ${crd_kind} crd_group: ${crd_group}"
        for crd_version in $(yq eval "select(documentIndex == ${document}) | .spec.versions[].name" "${input}"); do
          yq eval --prettyPrint -o json "select(documentIndex == ${document}) | .spec.versions[] | select(.name == \"${crd_version}\") | .schema.openAPIV3Schema" "${input}" | write_schema "${crd_kind}-${crd_group}-${crd_version}.json"
        done
        ;;

      *)
        echo "Unknown API version: ${api_version}" >&2
        return 1
        ;;
    esac
  done
}

function write_schema() {
  sponge "master-standalone/${1}"
  jq 'def strictify: . + if .type == "object" and has("properties") then {additionalProperties: false} + {properties: (({} + .properties) | map_values(strictify))} else null end; . * {properties: {spec: .properties.spec | strictify}}' "master-standalone/${1}" | sponge "master-standalone-strict/${1}"
}

crd_to_json_schema argo-cd https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
crd_to_json_schema argo-workflows https://raw.githubusercontent.com/argoproj/argo-workflows/main/manifests/base/crds/full/argoproj.io_{clusterworkflowtemplates,cronworkflows,workflowartifactgctasks,workfloweventbindings,workflows,workflowtaskresults,workflowtasksets,workflowtemplates}.yaml
crd_to_json_schema argo-rollouts https://raw.githubusercontent.com/argoproj/argo-rollouts/stable/manifests/install.yaml
crd_to_json_schema cert-manager https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.crds.yaml
crd_to_json_schema helm-operator https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml
crd_to_json_schema helm-repository https://raw.githubusercontent.com/fluxcd/source-controller/main/config/crd/bases/source.toolkit.fluxcd.io_helmrepositories.yaml
crd_to_json_schema prometheus-operator https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/master/example/prometheus-operator-crd/monitoring.coreos.com_{alertmanagers,alertmanagerconfigs,podmonitors,probes,prometheuses,prometheusrules,servicemonitors,thanosrulers}.yaml
crd_to_json_schema istio https://raw.githubusercontent.com/istio/istio/master/manifests/charts/base/files/crd-all.gen.yaml
crd_to_json_schema cilium https://raw.githubusercontent.com/cilium/cilium/master/pkg/k8s/apis/cilium.io/client/crds/v2/cilium{clusterwidenetworkpolicies,endpoints,identities,localredirectpolicies,networkpolicies,nodes}.yaml
crd_to_json_schema dynamodb-controller https://raw.githubusercontent.com/aws-controllers-k8s/dynamodb-controller/main/helm/crds/dynamodb.services.k8s.{aws_backups,aws_globaltables,aws_tables}.yaml
crd_to_json_schema aws-adopted-resources https://raw.githubusercontent.com/aws-controllers-k8s/dynamodb-controller/main/helm/crds/services.k8s.aws_adoptedresources.yaml
crd_to_json_schema elasticache-controller https://raw.githubusercontent.com/aws-controllers-k8s/elasticache-controller/main/helm/crds/elasticache.services.k8s.{aws_cacheparametergroups,aws_cachesubnetgroups,aws_replicationgroups,aws_snapshots}.yaml
crd_to_json_schema rds-controller https://raw.githubusercontent.com/aws-controllers-k8s/rds-controller/main/helm/crds/rds.services.k8s.aws_{dbinstances,dbparametergroups,dbsubnetgroups}.yaml
crd_to_json_schema eck-operator https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.6/deploy/eck-operator/charts/eck-operator-crds/templates/all-crds.yaml
crd_to_json_schema vault-secrets-operator https://raw.githubusercontent.com/ricoberger/vault-secrets-operator/master/charts/vault-secrets-operator/crds/ricoberger.de_vaultsecrets.yaml
crd_to_json_schema vpa https://raw.githubusercontent.com/kubernetes/autoscaler/master/vertical-pod-autoscaler/deploy/vpa-v1-crd-gen.yaml
crd_to_json_schema external-secrets-operator https://raw.githubusercontent.com/external-secrets/external-secrets/main/deploy/crds/bundle.yaml
