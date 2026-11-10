# Contour HTTPProxy CORS

The HTTPProxy schemas include `spec.virtualhost.corsPolicy`.
Its fields follow the VirtualHost CORS definition in the
[Contour v1.20.1 CRD](https://github.com/projectcontour/contour/blob/v1.20.1/examples/contour/01-crds.yaml).
The reference identifies the API definition only.
It does not select or upgrade a controller version for a cluster.
The strict schema rejects unknown CORS fields.
