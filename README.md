# kubernetes-json-schema

A repo to host custom resource definitions to be use with `kubeval`. Fixes this [issue](https://github.com/instrumenta/kubeval/issues/47).

```bash
kubeval --additional-schema-locations https://raw.githubusercontent.com/joshuaspence/kubernetes-json-schema/master -d .
```
