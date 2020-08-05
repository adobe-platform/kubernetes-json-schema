# kubernetes-json-schema

A repo to host custom resource definitions to be use with `kubeval`. Fixes this [issue](https://github.com/instrumenta/kubeval/issues/47).

1. Obtain the YAML for the CRD you want to validate

2. Run [js-yaml](https://github.com/nodeca/js-yaml), the output is the filename that `kubeval` expects (you can find the expected filename from a failed run of `kubeval`) :

```bash
js-yaml helmrelease-crd.yaml > helmrelease-helm-v1.json
```

3. Upload the resulting schema on github, in a repository that container the `master-standalone` folder at the root (you can use a branch different from `master`, just amend the `--additional-schema-locations` flag below).

4. Validate CRDs:

```bash
kubeval --additional-schema-locations https://raw.githubusercontent.com/ams0/kubernetes-json-schema/master -d .
```
