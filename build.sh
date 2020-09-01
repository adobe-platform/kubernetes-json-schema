#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

function crd_to_json_schema() {
  local api_version group input kind version

  echo "Processing ${1}..."
  input="input/${1}.yaml"
  curl --silent --show-error "${2}" > "${input}"

  api_version=$(yq read "${input}" apiVersion | cut --delimiter=/ --fields=2)
  kind=$(yq read "${input}" spec.names.kind | tr '[:upper:]' '[:lower:]')
  group=$(yq read "${input}" spec.group | cut --delimiter=. --fields=1)

  case "${api_version}" in
    v1beta1)
      version=$(yq read "${input}" spec.version)
      yq read --prettyPrint --tojson "${input}" spec.validation.openAPIV3Schema | write_schema "${kind}-${group}-${version}.json"
      ;;

    v1)
      for version in $(yq read "${input}" spec.versions.*.name); do
        yq read --prettyPrint --tojson "${input}" "spec.versions.(name==${version}).schema.openAPIV3Schema" | write_schema "${kind}-${group}-${version}.json"
      done
      ;;

    *)
      echo "Unknown API version: ${version}" >&2
      return 1
      ;;
  esac
}

function write_schema() {
  sponge "master-standalone/${1}"
  jq 'def strictify: . + if .type == "object" then {additionalProperties: false} + {properties: (({} + .properties) | map_values(strictify))} else null end; . * {properties: {spec: .properties.spec | strictify}}' "master-standalone/${1}" | sponge "master-standalone-strict/${1}"
}

crd_to_json_schema cert-manager https://raw.githubusercontent.com/jetstack/cert-manager/master/deploy/crds/crd-clusterissuers.yaml
crd_to_json_schema helm-operator https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml
