# Kubernetes Workspace

It turns out, that terraform can only run, if the Kubernetes cluster is
already up and running. Therefore this workspace is separate and can only
be run after infrastructure is up and running.

The kubernetes provider and kubectl provider pick up the outputs of the
infrastrucuture workspace.
