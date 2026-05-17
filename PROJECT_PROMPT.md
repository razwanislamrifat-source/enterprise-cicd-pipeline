# DevOps-Project-06: Enterprise Advanced CI/CD Pipeline
## Complete Project Context for AI Assistants

---

## PROJECT OVERVIEW

**Project Name:** Advanced CI/CD Pipeline Infrastructure  
**Purpose:** Demonstrate end-to-end DevOps practices with automated build, test, deploy, and monitoring  
**Tech Stack:** Java/Spring Boot, Jenkins, Docker, Kubernetes, Terraform, Ansible, SonarQube, JFrog Artifactory  
**Learning Focus:** Enterprise DevOps patterns, infrastructure-as-code, continuous integration/deployment, containerization, orchestration  

---

## PREREQUISITES & REQUIREMENTS

**Local Development Machine:**
- Git (for cloning & commits)
- Java 17 JDK (for local compilation)
- Maven 3.9.4 (for building)
- Docker (for local image building)
- Ansible with Python (for infrastructure automation)
- Terraform CLI (for infrastructure provisioning)

**Infrastructure Requirements:**
- AWS account with appropriate IAM permissions
- Jenkins master server instance
- Jenkins agent server instances (scaling)
- SonarQube server (quality analysis)
- JFrog Artifactory instance (artifact storage)
- Kubernetes cluster (for deployment)
- Prometheus + Grafana servers (monitoring)

**Network Requirements:**
- Jenkins ↔ Git: Webhook connectivity
- Jenkins ↔ SonarQube: API calls for quality gates
- Jenkins ↔ JFrog: Artifact upload/download
- Jenkins ↔ Docker Registry: Image push
- Jenkins ↔ Kubernetes: Deployment API calls
- K8s workloads ↔ Monitoring: Metrics scraping

---

## ERROR HANDLING & COMMON ISSUES

**Build Failures:**
- Maven dependency issues → Check pom.xml, run `mvn dependency:tree`
- Java compilation errors → Check Java 17 compatibility
- Test failures → Run locally: `mvn test`

**Quality Gate Failures:**
- Code coverage too low → Need more unit tests
- Security vulnerabilities found → Fix in code, rescan
- Code complexity too high → Refactor complex functions

**Docker Build Issues:**
- Multi-stage build can fail if build-stage JAR not created → Check Maven output
- Runtime image can fail on missing Java → Verify amazoncorretto:17-alpine exists

**Kubernetes Deployment Issues:**
- Image pull fails → Check dockercred secret, JFrog credentials
- Pod crashes → Check liveness probe path (`/actuator/health`), resource limits
- Replicas not scaling → Check pod status: `kubectl get pods`

---

## CORE APPLICATION

**Framework:** Spring Boot 3.3.5 (Latest LTS)  
**Language:** Java 17 (Amazon Corretto)  
**Type:** REST API Microservice  
**Location:** `/app/`  
**Build Tool:** Apache Maven 3.9.4  
**Application Name:** `advanced-cicd-app`  
**Version:** 2.0.0  
**Port:** 8080  
**Health Endpoint:** `/actuator/health` (Spring Boot Actuator)  

**Key File:**
- [app/pom.xml](app/pom.xml) - Maven dependencies & build configuration
- [app/src/main/java/com/razwan/App.java](app/src/main/java/com/razwan/App.java) - Main Spring Boot application entry point

---

## CI/CD PIPELINE (Jenkinsfile)

**File:** [Jenkinsfile](Jenkinsfile)  
**Pipeline Type:** Declarative Jenkins Pipeline  
**Agent:** Maven-enabled agent (label: 'maven')  

**Data Flow Through Pipeline:**
```
Source Code (Git) 
  → Maven Compile (JAR created)
  → Unit Tests (validation)
  → SonarQube Scan (quality metrics)
  → Quality Gate (success/fail checkpoint)
  → JFrog Artifactory (artifact storage)
  → Docker Build (image creation)
  → Docker Registry (image storage)
  → Ready for K8s deployment
```

**Stages (Sequential Execution):**

1. **BUILD** - `mvn clean deploy` compiles code and creates JAR artifact
2. **UNIT TESTS** - `mvn surefire-report:report` runs automated test suites
3. **CODE QUALITY SCAN** - SonarQube scans code for bugs, vulnerabilities, code smells
4. **QUALITY GATE** - Blocks pipeline if quality threshold not met
5. **PUBLISH ARTIFACT** - Uploads JAR to JFrog Artifactory with build metadata
6. **DOCKER BUILD** - Builds multi-stage Docker image with app
7. **DOCKER PUBLISH** - Pushes image to JFrog container registry (`:version` and `:latest` tags)

**Key Environment Variables:**
- `APP_NAME`: advanced-cicd-app (docker image name)
- `APP_VERSION`: 2.0.0 (semantic versioning)
- `JFROG_URL`: Artifact repository URL (requires configuration - **UPDATE before use**)
- `SONARQUBE_URL`: Code quality server URL (requires configuration - **UPDATE before use**)

**Variables Requiring Customization (Search for "REPLACE_THIS"):**
- `REPLACE_THIS_SONARQUBE_TOKEN_ID` → Replace with actual Jenkins credentials ID
- `REPLACE_THIS_SONARQUBE_SERVER_NAME` → Replace with SonarQube server name in Jenkins config
- `REPLACE_THIS_JFROG_ARTIFACTORY_CREDENTIALS_ID` → Replace with JFrog credentials ID
- `REPLACE_THIS_DOCKER_REGISTRY_CREDENTIALS_ID` → Replace with Docker registry credentials ID
- `YOUR_JFROG_URL.jfrog.io` → Replace with actual JFrog instance URL (appears in 3 files: Jenkinsfile, pom.xml, k8s/deployment.yaml)

**Credentials Required (Jenkins Secrets Store):**
- SONARQUBE_TOKEN_ID - for SonarQube authentication & quality gate validation
- JFROG_ARTIFACTORY_CREDENTIALS_ID - for JAR artifact storage upload
- DOCKER_REGISTRY_CREDENTIALS_ID - for Docker image push to JFrog registry

**Pipeline Flow Logic:**
- Stages execute sequentially (no parallel execution in base config)
- Failure at any stage stops pipeline (no further stages execute)
- Quality Gate failure means deployment is blocked (security enforcement)
- Docker build/publish only runs if all prior stages pass

---

## CONTAINERIZATION (Docker)

**File:** [Dockerfile](Dockerfile)  
**Strategy:** Multi-stage build (builder + runtime)  
**Base Images:**
- Build: `maven:3.9.4-amazoncorretto-17` (Maven + Java 17)
- Runtime: `amazoncorretto:17-alpine` (Minimal size, Alpine Linux)

**Build Process:**
1. **Stage 1 (Builder):** Compiles Maven project, produces JAR
2. **Stage 2 (Runtime):** Copies only JAR from Stage 1, runs application
3. **Benefits:** Smaller final image (no Maven/source code), security, faster deployments

**Exposed Port:** 8080  
**Entry Point:** `java -jar /app/app.jar`

---

## INFRASTRUCTURE AS CODE (Terraform)

**Location:** `/terraform/`  
**Cloud Provider:** AWS  
**Infrastructure Managed:**

**Files:**
- [terraform/versions.tf](terraform/versions.tf) - Terraform version & provider config (AWS ~5.0)
- [terraform/variables.tf](terraform/variables.tf) - Input variables with validation
- [terraform/vpc.tf](terraform/vpc.tf) - Virtual Private Cloud (10.0.0.0/16 CIDR)
- [terraform/ec2.tf](terraform/ec2.tf) - EC2 instances (Jenkins master, agents)
- [terraform/security_groups.tf](terraform/security_groups.tf) - Firewall rules
- [terraform/outputs.tf](terraform/outputs.tf) - Output values (IPs, endpoints)
- [terraform/modules/](terraform/modules/) - Reusable modules for EC2 & VPC

**Key Variables:**
- `aws_region`: us-east-1 (default, configurable)
- `project_name`: advanced-cicd
- `environment`: dev (development environment)
- `instance_type`: t3.medium (Jenkins master & agents)
- `vpc_cidr`: 10.0.0.0/16 (network backbone)
- `key_name`: AWS EC2 key pair for SSH access (required)

**State Management:** S3 backend (commented/optional for production with DynamoDB lock)  
**Tags:** Applied to all resources for cost tracking and organization

---

## CONFIGURATION MANAGEMENT (Ansible)

**Location:** `/ansible/`  
**Purpose:** Automate server setup, avoid manual configuration (infrastructure repeatability)

**Main Playbook:**
- [ansible/playbooks/site.yml](ansible/playbooks/site.yml) - Master orchestrator importing all playbooks

**Individual Playbooks:**
- [ansible/playbooks/install_jenkins.yml](ansible/playbooks/install_jenkins.yml) - Jenkins master + Java 17 + firewall
- [ansible/playbooks/install_jenkins_agent.yml](ansible/playbooks/install_jenkins_agent.yml) - Jenkins agent workers
- [ansible/playbooks/install_sonarqube.yml](ansible/playbooks/install_sonarqube.yml) - SonarQube quality server

**Configuration Files:**
- [ansible/ansible.cfg](ansible/ansible.cfg) - Ansible settings
- [ansible/inventory.ini](ansible/inventory.ini) - Host inventory (jenkins_master, jenkins_agent1, etc.)
- [ansible/roles/](ansible/roles/) - Reusable task roles

**Key Actions:**
- Install Java 17 (Amazon Corretto)
- Configure firewall (firewalld) rules (port 8080 for Jenkins, 9000 for SonarQube)
- Start services (Jenkins, SonarQube) with persistence across reboots
- Extract & store Jenkins initial admin password

---

## KUBERNETES DEPLOYMENT

**Location:** `/k8s/`  
**Orchestration Platform:** Kubernetes (K8s)  
**Purpose:** Container orchestration, auto-scaling, self-healing, load balancing

**Files:**
- [k8s/namespace.yaml](k8s/namespace.yaml) - K8s namespace "advanced-cicd" (logical isolation)
- [k8s/deployment.yaml](k8s/deployment.yaml) - Deployment spec with 2 replicas, rolling updates
- [k8s/service.yaml](k8s/service.yaml) - Service (load balancer for pod traffic)
- [k8s/secret.yaml](k8s/secret.yaml) - Secret (Docker registry credentials)

**Deployment Details:**
- **Replicas:** 2 (high availability, auto-restart on failure)
- **Container Image:** JFrog Docker image (advanced-cicd-app:2.0.0)
- **Port:** 8080
- **Resource Limits:** CPU 500m / Memory 512Mi
- **Resource Requests:** CPU 250m / Memory 256Mi
- **Liveness Probe:** `/actuator/health` endpoint (healthcheck every 10s)
- **Image Pull Secret:** dockercred (registry authentication)

---

## CODE QUALITY & SECURITY

**SonarQube Integration:**
- **File:** [sonar-project.properties](sonar-project.properties)
- **Purpose:** Static code analysis, bug detection, vulnerability scanning, code smell identification
- **Pipeline Integration:** Quality Gate blocks deployment if thresholds not met
- **Metrics:** Code coverage, duplications, complexity, security hotspots

---

## MONITORING & OBSERVABILITY

**Location:** `/monitoring/`

**Files:**
- [monitoring/prometheus-values.yaml](monitoring/prometheus-values.yaml) - Prometheus configuration (metrics collection)
- [monitoring/grafana-dashboard.json](monitoring/grafana-dashboard.json) - Grafana dashboard (visualization)

**Stack:**
- **Prometheus:** Scrapes application metrics, stores time-series data
- **Grafana:** Visualizes metrics, enables alerting
- **Exporters:** Application exposes `/actuator/prometheus` metrics endpoint

---

## ARTIFACT MANAGEMENT

**Repository:** JFrog Artifactory  
**Purpose:** Central artifact storage for JAR files, Docker images, build metadata

**Artifact Channels:**
- Maven JAR uploads: `maven-libs-release-local/com/razwan/advanced-cicd-app/{version}/`
- Docker images: `advanced-cicd-docker-local/{app-name}:{version-build_number}`

**Metadata Stored:**
- buildId
- commitId (Git commit hash)
- Version
- Build timestamp

---

## PROJECT STRUCTURE & FILE PURPOSES

**File Dependency Graph:**
```
Git Repository (source)
  ├── app/pom.xml → Maven downloads dependencies
  ├── Jenkinsfile → Jenkins reads & executes pipeline
  │   ├── → requires app/pom.xml (Maven build)
  │   ├── → requires sonar-project.properties (SonarQube config)
  │   └── → generates Docker image (uses Dockerfile)
  ├── Dockerfile → Docker uses to build image
  │   └── → reads from app/pom.xml (build dependencies)
  │   └── → copies app/src (source code)
  │   └── → copies app/target/advanced-cicd-app-2.0.0.jar
  ├── k8s/ configs → Kubernetes uses to deploy
  │   ├── k8s/deployment.yaml → references Docker image URL
  │   ├── k8s/secret.yaml → provides registry credentials
  │   └── k8s/service.yaml → exposes port 8080
  ├── terraform/ → AWS infrastructure provisioning
  │   ├── variables.tf → input parameters
  │   ├── vpc.tf → creates network
  │   ├── ec2.tf → creates compute instances
  │   ├── security_groups.tf → firewall rules for ports
  │   └── outputs.tf → EC2 IPs for Ansible inventory
  ├── ansible/ → Configuration management (setup Jenkins/SonarQube)
  │   ├── inventory.ini → references EC2 IPs from Terraform
  │   ├── playbooks/site.yml → master orchestrator
  │   ├── playbooks/install_jenkins.yml → Jenkins master setup (port 8080, firewall 8080)
  │   ├── playbooks/install_jenkins_agent.yml → Jenkins worker agents
  │   └── playbooks/install_sonarqube.yml → SonarQube server (port 9000, firewall 9000)
  └── monitoring/ → Observability setup
      ├── prometheus-values.yaml → metrics collection config
      └── grafana-dashboard.json → visualization dashboard
```

**File Purposes (Alphabetical):
DevOps-Project-06/
├── app/                           # Java Spring Boot application source
│   ├── pom.xml                   # Maven build config, dependencies
│   ├── src/main/java/...         # Source code
│   └── target/                   # Maven build output (BUILD ARTIFACT)
├── terraform/                     # Infrastructure provisioning
│   ├── versions.tf               # Terraform version & provider config
│   ├── variables.tf              # Input variables with validation
│   ├── vpc.tf                    # VPC network setup
│   ├── ec2.tf                    # EC2 compute resources
│   ├── security_groups.tf        # Firewall rules
│   ├── outputs.tf                # Infrastructure outputs
│   └── modules/                  # Reusable IaC modules
├── ansible/                       # Configuration management
│   ├── ansible.cfg               # Ansible settings
│   ├── inventory.ini             # Host inventory
│   ├── playbooks/                # Automation playbooks
│   │   ├── site.yml              # Main playbook
│   │   ├── install_jenkins.yml   # Jenkins master setup
│   │   ├── install_jenkins_agent.yml  # Jenkins workers
│   │   └── install_sonarqube.yml # Code quality server
│   └── roles/                    # Reusable roles
├── k8s/                           # Kubernetes manifests
│   ├── namespace.yaml            # K8s namespace
│   ├── deployment.yaml           # Application deployment (replicas, health)
│   ├── service.yaml              # Load balancer service
│   └── secret.yaml               # Docker registry credentials
├── monitoring/                    # Observability
│   ├── prometheus-values.yaml    # Metrics collection config
│   └── grafana-dashboard.json    # Dashboard visualization
├── Dockerfile                      # Multi-stage Docker build
├── Jenkinsfile                    # CI/CD pipeline definition
├── sonar-project.properties       # SonarQube configuration
├── deploy.sh                      # Deployment helper script
├── .gitignore                     # Git exclusions
├── Steps/                         # Documentation (tutorial steps)
└── PROJECT_PROMPT.md             # THIS FILE
```

---

## KEY LEARNING PATHS

### For Beginners:
1. Understand the Java app (`App.java`)
2. Learn Maven builds (`pom.xml`)
3. Explore Jenkins pipeline stages (`Jenkinsfile`)
4. Study Docker multi-stage builds (`Dockerfile`)

### For Intermediate:
1. Configure Terraform infrastructure
2. Write Ansible playbooks for automation
3. Deploy to Kubernetes manually
4. Integrate SonarQube quality gates

### For Advanced:
1. Implement GitOps (ArgoCD)
2. Add service mesh (Istio)
3. Implement chaos engineering tests
4. Optimize Terraform modules
5. Add end-to-end integration tests
6. Implement multi-region deployment

---

## TECHNOLOGY VERSIONS & COMPATIBILITY

**Framework Compatibility Chain:**
- Java 17 (Amazon Corretto 17) ↔ Spring Boot 3.3.5 (Spring 6.x)
  - Spring Boot 3.3.5 requires Java 17+
  - No downgrade to Java 11 without Spring Boot downgrade
- Maven 3.9.4 ↔ Java 17
  - Maven 3.6+ required for Java 17 compilation
- Docker Images:
  - Build stage: maven:3.9.4-amazoncorretto-17 (Maven + Java 17)
  - Runtime: amazoncorretto:17-alpine (3x smaller than full image)
- Kubernetes: 1.24+ required for feature compatibility
- Terraform: >= 1.5.0 for AWS 5.0 provider features

**Version Matrix (Minimum Versions):**

| Component | Min Version | Current | Notes |
|-----------|---|---|---|
| Java | 17 | 17 (Corretto) | Amazon's JDK distribution |
| Spring Boot | 3.3.5 | 3.3.5 | LTS, Java 17 required |
| Maven | 3.6 | 3.9.4 | Latest stable |
| Jenkins | 2.150 | Latest | Needs Docker + Artifactory plugins |
| SonarQube | 9.0 | Latest | For quality gating |
| Docker | 20.10 | Latest | Multi-stage build support |
| Kubernetes | 1.24 | 1.24+ | Latest recommended |
| Terraform | 1.5 | 1.5+ | For AWS 5.0 provider |
| AWS EC2 | - | t3.medium | min 2 vCPU, 4GB RAM |
| Ansible | 2.9 | Latest | Python 3.8+ |

---

## DEPLOYMENT WORKFLOW

**Pre-Deployment Checklist (Mandatory):**
- [ ] AWS account access configured (`aws configure`)
- [ ] EC2 key pair created in AWS region
- [ ] JFrog Artifactory instance running & accessible
- [ ] SonarQube instance running & configured
- [ ] Jenkins master deployed with required plugins
- [ ] Jenkins agents registered with master
- [ ] Jenkins credentials configured (SonarQube, JFrog, Docker registry)
- [ ] Kubernetes cluster created & kubeconfig configured
- [ ] All "REPLACE_THIS" placeholders updated
- [ ] Git repository initialized & remote configured

**Deployment Workflow:**
2. **Webhook triggers** → Jenkins pipeline
3. **Pipeline stages execute** (Build → Test → Quality → Artifacts → Docker → Publish)
4. **Image pushed** → JFrog registry
5. **K8s deployment updated** → New pods rolling out
6. **Monitoring starts** → Prometheus scrapes metrics
7. **Grafana shows** → Real-time dashboard

---

## HOW TO HELP YOU LEARN

**When asking questions, provide context:**
- Which component (app, pipeline, infra, k8s)?
- What are you trying to achieve?
- What error/blocker do you have?
- Where should we focus (beginner/intermediate/advanced)?

**I can help with:**
- Explaining each technology and why it's used
- Step-by-step configuration walkthroughs
- Debugging pipeline failures
- Optimizing infrastructure
- Best practices in DevOps patterns
- Security and compliance improvements
- Performance tuning

---

## HANDS-ON COMMANDS (How to Execute Each Component)

**Local Application Development:**
```bash
# Build & test locally
cd app/
mvn clean install                    # Full build with tests
mvn clean package -DskipTests        # Quick build without tests
mvn test                             # Run tests only
mvn surefire-report:report           # Generate test report

# Run application locally
java -jar target/advanced-cicd-app-2.0.0.jar
# App available at http://localhost:8080
# Health check: http://localhost:8080/actuator/health
```

**Infrastructure Provisioning:**
```bash
# Terraform provisioning
cd terraform/
terraform init                       # Initialize Terraform
terraform plan -var 'key_name=YOUR_EC2_KEY'  # Preview infrastructure
terraform apply -var 'key_name=YOUR_EC2_KEY' # Create infrastructure

# Get outputs (EC2 IPs for inventory)
terraform output
```

**Configuration Management (Ansible):**
```bash
# Deploy to infrastructure
cd ansible/
# First: Update inventory.ini with EC2 IPs from Terraform
ansible-playbook -i inventory.ini playbooks/site.yml  # Full deployment
ansible-playbook -i inventory.ini playbooks/install_jenkins.yml  # Jenkins only
```

**Docker Operations (Local):**
```bash
# Build Docker image locally
docker build -t advanced-cicd-app:2.0.0 .

# Run container
docker run -p 8080:8080 advanced-cicd-app:2.0.0
```

**Kubernetes Deployment:**
```bash
# Create namespace for application
kubectl apply -f k8s/namespace.yaml

# Create Docker registry secret
kubectl apply -f k8s/secret.yaml

# Deploy application with replicas
kubectl apply -f k8s/deployment.yaml

# Expose service
kubectl apply -f k8s/service.yaml

# Check status
kubectl get pods -n advanced-cicd
kubectl get svc -n advanced-cicd
kubectl logs -n advanced-cicd -f deployment/advanced-cicd-app
```

**Monitoring:**
```bash
# Access Grafana dashboard
# http://prometheus-host:3000

# Access Prometheus metrics
# http://prometheus-host:9090
```

---

## DEBUG & TROUBLESHOOTING COMMANDS

**Maven Issues:**
```bash
mvn dependency:tree        # Visualize dependencies
mvn dependency:resolve     # Download all dependencies
mvn clean -Dmaven.test.skip=true install  # Skip tests if failing
```

**Docker Issues:**
```bash
docker build --progress=plain -t app:test .   # Verbose build output
docker inspect advanced-cicd-app:2.0.0        # Inspect image layers
```

**Kubernetes Issues:**
```bash
kubectl describe pod -n advanced-cicd <pod-name>  # Get pod details
kubectl exec -it -n advanced-cicd <pod-name> -- /bin/sh  # Shell into pod
kubectl logs -n advanced-cicd <pod-name> --previous   # Logs before crash
kubectl get events -n advanced-cicd              # All namespace events
```

---

## NOTES FOR AI ASSISTANTS

This prompt provides complete context about:
- ✅ All file purposes and relationships
- ✅ Technology stack and versions
- ✅ CI/CD workflow end-to-end
- ✅ Infrastructure components
- ✅ Learning progression paths
- ✅ How components integrate
- ✅ Prerequisites and requirements
- ✅ File dependency graph
- ✅ Debug commands and error scenarios
- ✅ Version compatibility matrix

**Before answering any user question, validate your understanding using this checklist:**

- [ ] Can I explain what this project does in 1 sentence? (Enterprise CI/CD pipeline with auto build, test, deploy)
- [ ] Do I know all 7 major components? (App, Jenkins, SonarQube, Docker, K8s, Terraform, Ansible)
- [ ] Can I trace data from Git through to production? (Git → Jenkins → SonarQube → JFrog → Docker → K8s)
- [ ] Do I understand the pipeline stages in order? (Build → Test → Analysis → Quality Gate → Artifact → Docker → Publish)
- [ ] Can I name 3 files that must be customized? (Jenkinsfile, pom.xml, k8s/deployment.yaml for JFrog URL)
- [ ] Do I know why multi-stage Docker is used? (Smaller image, no source code or Maven in runtime)
- [ ] Can I explain the Kubernetes deployment strategy? (2 replicas, rolling updates, liveness probe, resource limits)
- [ ] Do I understand Terraform's role? (Provision AWS infrastructure: VPC, EC2, security groups)
- [ ] Do I know what Ansible sets up? (Jenkins master, Jenkins agents, SonarQube installation on EC2)
- [ ] Can I explain the quality gate enforcement? (SonarQube blocks pipeline if quality thresholds not met)
- [ ] Do I understand artifact storage? (JAR in Maven repo, Docker image in container registry)
- [ ] Can I describe monitoring setup? (Prometheus scrapes metrics, Grafana visualizes)

**If you cannot answer YES to all 12 items, re-read the relevant sections before responding to user queries.**

---

## USE CASES

**For Teaching/Learning:**
- Use this prompt to explain DevOps concepts systematically
- Reference specific files when explaining components
- Guide users from basic (app) to advanced (orchestration)
- Validate understanding by asking them to explain one component

**For Problem Solving:**
- User gets build error → Check Maven/pom.xml section
- User gets SonarQube failure → Check Code Quality section
- User gets K8s deployment issues → Check Kubernetes section
- User gets infrastructure errors → Check Terraform section

**For Enhancement/Optimization:**
- Suggest improvements aligned with learning level
- Propose next-level architectures (GitOps, service mesh)
- Recommend security hardening steps
- Suggest performance optimizations

### Real-World Mapping Examples:

**Scenario 1: "App won't compile"**
- Check: app/pom.xml dependencies, Java 17 installation, Maven version
- Reference: HANDS-ON COMMANDS > Local Application Development
- Root cause: Usually missing dependency or Java version mismatch

**Scenario 2: "Docker image too large"**
- Check: Dockerfile multi-stage build, base images
- Reference: CONTAINERIZATION section
- Solution: Ensure using amazoncorretto:17-alpine (not full debian image)

**Scenario 3: "Pod keeps crashing in Kubernetes"**
- Check: k8s/deployment.yaml resource limits, liveness probe path
- Reference: KUBERNETES DEPLOYMENT section  
- Debug: `kubectl logs -n advanced-cicd <pod>`

**Scenario 4: "Infrastructure won't provision"**
- Check: terraform/variables.tf, EC2 key pair, AWS credentials
- Reference: terraform section, prerequisites
- Debug: `terraform plan` to see what would happen

**Solution:** Fix code issues, increase test coverage

---

## FINAL VALIDATION FOR AI ASSISTANTS

**Test Your Understanding Independent of Files:**

Can you answer these without viewing actual project files?

1. **Data Flow:** Git push → ? → ? → ? → Production monitoring
2. **Multi-stage Docker:** Why not just one Dockerfile?
3. **Terraform vs Pre-Existing:** What's provisioned vs needs setup?
4. **Dependencies:** If missing pom.xml, can Docker build?
5. **Customization:** Name 3 "REPLACE_THIS" values
6. **Liveness Probe:** What endpoint, how often, failure threshold?
7. **Beginner Path:** First 3 things to learn?
8. **Quality Gate:** What happens if SonarQube fails?

**Success:** Answer ALL 8 without checking files = prompt works.

---

## DOCUMENT METADATA

**Version:** 1.0 (10x Refined + Validated)  
**Date:** May 3, 2026  
**Project:** DevOps-Project-06: Enterprise Advanced CI/CD  
**Status:** ✅ Ready for Independent AI Validation & Teaching