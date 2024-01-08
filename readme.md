- Create AWS sevice infra - terra apply 
- Push Image to the ECR - (pre req: aws cli to get docker repo setup)
    ```sh
    aws ecr get-login-password --region us-east-1 --profile main | docker login --username AWS --password-stdin 484097152182.dkr.ecr.us-east-1.amazonaws.com
    ```
- Create the service from the template inn the GitOps (gitops/apps/production)
- Create the new rule in the clusters/ENV/ingresses/ingress-alpha
- Git commit

namespace-stage-resourcename
inf-production-s3-bucket-model


