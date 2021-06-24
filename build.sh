#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

function crd_to_json_schema() {
  local api_version crd_group crd_kind crd_version document input kind

  echo "Processing ${1}..."
  input="input/${1}.yaml"
  if [[ "${1}" != "platformlog" ]]; then
    curl -L --silent --show-error "${@:2}" > "${input}"
  fi

  # Clean the input for compound schema docs that don't contain a yaml seperator (e.g., aso)
  perl -i -0pe 'BEGIN{undef $/;} s/(.+[^\-{3}]\s*)\napiVersion: apiextensions.k8s.io(.*)$/$1\n---\napiVersion: apiextensions.k8s.io$2/mg' "${input}"

  for document in $(seq 0 $(($(yq read --collect --doc '*' --length "${input}") - 1))); do
    api_version=$(yq read --doc "${document}" "${input}" apiVersion | cut --delimiter=/ --fields=2)
    kind=$(yq read --doc "${document}" "${input}" kind)
    crd_kind=$(yq read --doc "${document}" "${input}" spec.names.kind | tr '[:upper:]' '[:lower:]')
    crd_group=$(yq read --doc "${document}" "${input}" spec.group | cut --delimiter=. --fields=1)

    if [[ "${kind}" != CustomResourceDefinition ]]; then
      continue
    fi

    case "${api_version}" in
      v1beta1)
        crd_version=$(yq read --doc "${document}" "${input}" spec.version)
        if [ ! -z ${crd_version} ]; then
          yq read --doc "${document}" --prettyPrint --tojson "${input}" spec.validation.openAPIV3Schema | write_schema "${crd_kind}-${crd_group}-${crd_version}.json"
        else
          for crd_version in $(yq read --doc "${document}" "${input}" spec.versions.*.name); do
            yq read --doc "${document}" --prettyPrint --tojson "${input}" spec.validation.openAPIV3Schema | write_schema "${crd_kind}-${crd_group}-${crd_version}.json"
          done
        fi          
        ;;

      v1)
        for crd_version in $(yq read --doc "${document}" "${input}" spec.versions.*.name); do
          yq read --doc "${document}" --prettyPrint --tojson "${input}" "spec.versions.(name==${crd_version}).schema.openAPIV3Schema" | write_schema "${crd_kind}-${crd_group}-${crd_version}.json"
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

crd_to_json_schema argo-rollouts https://raw.githubusercontent.com/argoproj/argo-rollouts/stable/manifests/install.yaml
crd_to_json_schema cert-manager https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.crds.yaml
crd_to_json_schema helm-operator https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml
crd_to_json_schema prometheus-operator https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/master/example/prometheus-operator-crd/monitoring.coreos.com_{alertmanagers,podmonitors,probes,prometheuses,prometheusrules,servicemonitors,thanosrulers}.yaml
crd_to_json_schema contour https://raw.githubusercontent.com/phylake/contour/v1.5-adobe/examples/contour/01-crds.yaml
crd_to_json_schema istio https://raw.githubusercontent.com/istio/istio/master/manifests/charts/base/crds/crd-all.gen.yaml
crd_to_json_schema aso https://raw.githubusercontent.com/Azure/azure-service-operator/master/charts/azure-service-operator/crds/apiextensions.k8s.io_v1_customresourcedefinition_{apimgmtapis,apimservices,appinsights,appinsightsapikeys,azureloadbalancers,azurenetworkinterfaces,azurepublicipaddresses,azuresqlactions,azuresqldatabases,azuresqlfailovergroups,azuresqlfirewallrules,azuresqlmanagedusers,azuresqlservers,azuresqlusers,azuresqlvnetrules,azurevirtualmachineextensions,azurevirtualmachines,azurevmscalesets,blobcontainers,consumergroups,cosmosdbs,cosmosdbsqldatabases,eventhubnamespaces,eventhubs,keyvaultkeys,keyvaults,mysqldatabases,mysqlfirewallrules,mysqlservers,mysqlusers,mysqlvnetrules,postgresqldatabases,postgresqlfirewallrules,postgresqlservers,postgresqlusers,postgresqlvnetrules,rediscacheactions,rediscachefirewallrules,rediscaches,resourcegroups,storageaccounts,virtualnetworks}.azure.microsoft.com.yaml
crd_to_json_schema cilium https://raw.githubusercontent.com/cilium/cilium/master/pkg/k8s/apis/cilium.io/client/crds/v2/cilium{clusterwidenetworkpolicies,endpoints,externalworkloads,identities,localredirectpolicies,networkpolicies,nodes}.yaml
crd_to_json_schema elasticache-controller https://raw.githubusercontent.com/aws-controllers-k8s/elasticache-controller/main/helm/crds/elasticache.services.k8s.{aws_cacheparametergroups,aws_cachesubnetgroups,aws_replicationgroups,aws_snapshots}.yaml
crd_to_json_schema dynamodb-controller https://raw.githubusercontent.com/aws-controllers-k8s/dynamodb-controller/main/helm/crds/dynamodb.services.k8s.{aws_backups,aws_globaltables,aws_tables}.yaml
crd_to_json_schema eck-operator https://raw.githubusercontent.com/elastic/cloud-on-k8s/master/deploy/eck-operator/charts/eck-operator-crds/templates/all-crds.yaml
