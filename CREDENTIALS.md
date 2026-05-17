# Credentials Setup Guide

This document outlines how to configure credentials for the CI/CD pipeline.

## Jenkins Credentials

Jenkins uses credential management to securely store and inject secrets into pipeline jobs.

### 1. JFrog Artifactory Credentials

1. Go to Jenkins Dashboard → Manage Jenkins → Manage Credentials
2. Click "System" → "Global credentials"
3. Click "Add Credentials"
4. Fill in:
   - **Kind**: Username with password
   - **Username**: Your JFrog username
   - **Password**: Your JFrog API token
   - **ID**: `jfrog-artifactory-credentials`
   - **Description**: JFrog Artifactory Credentials

### 2. SonarQube Token

1. Go to SonarQube → User Profile → Security
2. Generate a token
3. In Jenkins → Add Credentials:
   - **Kind**: Secret text
   - **Secret**: Paste the SonarQube token
   - **ID**: `sonarqube-token`
   - **Description**: SonarQube Authentication Token

### 3. Docker Registry Credentials

1. In Jenkins → Add Credentials:
   - **Kind**: Username with password
   - **Username**: Your JFrog Docker username
   - **Password**: Your JFrog Docker password
   - **ID**: `docker-registry-credentials`
   - **Description**: JFrog Docker Registry Credentials

## Jenkinsfile Environment Configuration

Update these environment variables in the Jenkinsfile with actual values:

```groovy
environment {
    JFROG_URL = 'your-company.jfrog.io'
    SONARQUBE_URL = 'https://sonarqube.your-domain.com'
}
```

## Terraform Variables

Create `terraform/terraform.tfvars` file:

```hcl
aws_region  = "us-east-1"
project_name = "advanced-cicd"
environment = "dev"
instance_type = "t3.medium"
key_name = "your-ec2-key-pair-name"
vpc_cidr = "10.0.0.0/16"
```

## Kubernetes Docker Secret

Generate Docker config credentials:

```bash
cat ~/.docker/config.json | base64 -w 0
```

Update `k8s/secret.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: dockercred
  namespace: advanced-cicd
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64-encoded-docker-config>
```

## AWS Credentials

Ensure AWS credentials are configured:

```bash
aws configure
```

Verify configuration:

```bash
aws sts get-caller-identity
```

## Environment-Specific Configuration

### Development
- Use lower resource limits
- Enable debug logging
- Smaller replica counts (1-2)

### Production
- Enforce quality gates strictly
- Use resource limits
- High availability replicas (3+)
- Enable monitoring and alerting

## Security Best Practices

1. **Never commit credentials** to version control
2. **Use Jenkins credential store** for all secrets
3. **Rotate tokens regularly** for security
4. **Use least privilege access** for IAM roles
5. **Enable audit logging** for credential access
6. **Encrypt secrets in transit** (use HTTPS)

## Troubleshooting

### Jenkins Can't Access JFrog
- Verify JFrog URL is correct
- Check credentials are properly configured
- Test connectivity: `curl -u user:token https://jfrog-url/artifactory/api/system/ping`

### Docker Push Fails
- Verify Docker registry credentials
- Check image tag matches registry format
- Ensure registry is accessible from Jenkins agent

### SonarQube Token Issues
- Regenerate token in SonarQube UI
- Verify token permissions include project analysis
- Check SonarQube server is reachable from Jenkins

### Kubernetes Secret Error
- Verify base64 encoding is correct
- Check namespace exists: `kubectl get namespace advanced-cicd`
- Validate secret: `kubectl describe secret dockercred -n advanced-cicd`
