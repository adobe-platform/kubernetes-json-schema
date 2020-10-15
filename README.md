# kubernetes-json-schema

A repo to host custom resource definitions to be use with `kubeval`. Fixes this [issue](https://github.com/instrumenta/kubeval/issues/47).

```bash
kubeval --additional-schema-locations https://raw.githubusercontent.com/adobe-platform/kubernetes-json-schema/master -d .
```
Forked from https://github.com/joshuaspence/kubernetes-json-schema

CRD's currently supported:
- argo-rollouts
- azure-service-operator
- cert-manager
- cilium
- contour (adobe fork)
- helm-operator
- istio
- prometheus-operator
