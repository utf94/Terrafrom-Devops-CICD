## This repository holds the Kubernetes manifests for all the services to run on GKE cluster.

### Created via bootstrap command per cluster:
```shell
flux bootstrap github \
  --components-extra=image-reflector-controller,image-automation-controller \
  --owner=webaverse-studios \
  --repository=gitops-infinitia \
  --branch=main \
  --path=clusters/ENV \
  --read-write-key
```
The bootstrap command is idempotent and can be run many times if needed, but should only be run once per cluster.

### Required secrets needs to be created prior to deploying any apps or services:
```shell
kubectl -n datadog create secret generic datadog-api-key \
--from-literal api-key="DD_API_KEY"

kubectl -n datadog create secret generic datadog-app-key \
--from-literal app-key="DD_APP_KEY"
```

The next two keys are identical but in different namespaces, needed for Image Automation to pull Docker images from ECR:

```shell
kubectl -n default create secret generic aws-credentials \
--from-literal=AWS_ACCESS_KEY_ID="AWS_ACCESS_KEY_ID" \
--from-literal=AWS_SECRET_ACCESS_KEY="AWS_SECRET_ACCESS_KEY"

kubectl -n flux-system create secret generic aws-credentials \
--from-literal=AWS_ACCESS_KEY_ID="AWS_ACCESS_KEY_ID" \
--from-literal=AWS_SECRET_ACCESS_KEY="AWS_SECRET_ACCESS_KEY"
```

Last but not least git creds to pull Gitops repo:

```shell
kubectl create secret generic git-creds \
  --namespace=flux-system \
  --from-literal=username="GITHUB_USER_NAME" \
  --from-literal=password="GITHUB_PAT"
```