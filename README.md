# Advanced CI/CD Pipeline

Enterprise-grade CI/CD infrastructure demonstrating end-to-end DevOps practices with Java/Spring Boot, Jenkins, Docker, Kubernetes, and infrastructure automation.

## Overview

This project provides a complete CI/CD pipeline including:
- **Application**: Spring Boot 3.3.5 REST service with health checks
- **CI/CD**: Jenkins declarative pipeline with 8 stages
- **Build**: Maven with artifact repository integration
- **Containerization**: Docker multi-stage builds
- **Orchestration**: Kubernetes deployment manifests
- **Infrastructure**: Terraform IaC with AWS VPC, EC2, Security Groups
- **Automation**: Ansible playbooks for environment setup
- **Quality**: SonarQube code analysis and quality gates
- **Monitoring**: Prometheus + Grafana stack

## Prerequisites

- Git
- Java 17 JDK
- Maven 3.9.4
- Docker
- Kubernetes CLI (kubectl)
- Terraform >= 1.5.0
- Ansible
- AWS CLI with credentials configured

## Quick Start

### 1. Infrastructure Setup

```bash
cd terraform
terraform init
terraform plan -var="key_name=your-ec2-key" -out=tfplan
terraform apply tfplan
```

### 2. Configuration Management

```bash
cd ../ansible
ansible-playbook -i inventory.ini playbooks/site.yml
```

### 3. Build Application

```bash
cd ../app
mvn clean package
```

### 4. Deploy to Kubernetes

```bash
cd ../
./deploy.sh
```

## Project Structure

```
.
├── app/                          # Spring Boot application
│   ├── src/main/java/           # Application source
│   └── pom.xml                   # Maven configuration
├── Dockerfile                    # Multi-stage Docker build
├── Jenkinsfile                   # Jenkins pipeline
├── k8s/                          # Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── secret.yaml
├── terraform/                    # Infrastructure as Code
│   ├── versions.tf
│   ├── variables.tf
│   ├── vpc.tf
│   ├── ec2.tf
│   └── security_groups.tf
├── ansible/                      # Configuration management
│   ├── playbooks/
│   └── roles/
├── monitoring/                   # Prometheus & Grafana config
├── sonar-project.properties      # SonarQube configuration
└── deploy.sh                     # Deployment script
```

## Configuration

### Jenkins Credentials

Create the following credentials in Jenkins:
- `jfrog-artifactory-credentials`: JFrog username/password
- `sonarqube-token`: SonarQube authentication token
- `docker-registry-credentials`: JFrog Docker registry credentials

See [CREDENTIALS.md](CREDENTIALS.md) for detailed setup instructions.

### Terraform Variables

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform/terraform.tfvars with your values
```

### Kubernetes Secret

Generate and update the Docker credentials secret:

```bash
cat ~/.docker/config.json | base64 -w 0
# Copy output to k8s/secret.yaml
```

## Pipeline Stages

1. **Build**: Maven clean deploy with artifact repository
2. **Unit Test**: Run test suite and generate reports
3. **SonarQube Analysis**: Code quality scanning
4. **Quality Gate**: Enforce quality standards
5. **Publish JAR**: Upload artifacts to JFrog
6. **Docker Build**: Create container image
7. **Docker Publish**: Push image to registry
8. **Deploy to EKS**: Deploy to Kubernetes cluster

## Environment Variables

Key environment variables used in the pipeline:
- `APP_NAME`: Application identifier
- `APP_VERSION`: Application version
- `JFROG_URL`: JFrog Artifactory endpoint
- `SONARQUBE_URL`: SonarQube server endpoint

## Kubernetes Deployment

The deployment manifests include:
- **Namespace**: Isolated environment for the application
- **Deployment**: 2 replicas with resource limits
- **Service**: LoadBalancer exposing port 80 → 8080
- **Health Checks**: Liveness probe on `/actuator/health`

## Monitoring

Access monitoring stack via:
- **Prometheus**: Scrapes metrics from Kubernetes
- **Grafana**: Visualizes application and infrastructure metrics

## Troubleshooting

### Build Failures
- Check Maven dependencies: `mvn dependency:tree`
- Verify Java 17 compatibility in pom.xml
- Run tests locally: `mvn test`

### Kubernetes Issues
- Check pod status: `kubectl get pods -n advanced-cicd`
- View logs: `kubectl logs -f <pod-name> -n advanced-cicd`
- Describe pod: `kubectl describe pod <pod-name> -n advanced-cicd`

### SonarQube Quality Gate
- Review analysis at SonarQube UI
- Check code coverage requirements
- Fix security vulnerabilities before retry

## Contributing

Follow these practices:
- Run `mvn clean test` before commits
- Update version in pom.xml for releases
- Test Dockerfile builds locally
- Validate Terraform with `terraform validate`
- Test Ansible playbooks in staging environment

## License

Proprietary - Advanced DevOps Infrastructure
