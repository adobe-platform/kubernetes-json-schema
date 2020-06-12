# kubernetes-json-schema

1. Obtain the YAML for the CRD you want to validate
2. Run [js-yaml](https://github.com/nodeca/js-yaml)

```bash
js-yaml helmrelease-crd.yaml > helmrelease-crd.json
```

3. Run [jsonnet](https://jsonnet.org/) on the file. You can find the expected filename from a failed run of `kubeval`:

```bash
jsonnet helmrelease-crd.json > helmrelease-helm-v1.json
```

4. Upload the resulting schema on github

5. Validate CRDs:

```bash
kubeval --additional-schema-locations https://raw.githubusercontent.com/ams0/kubernetes-json-schema/master -d .
```
