# 🚀 7-Day DevSecOps Masterclass:

---

## **Target Audience:**

- Basic understanding of AWS services
- Docker and Kubernetes fundamentals
- CI/CD concepts
- Basic Linux commands
- Git version control
- GitOps deployment

### 🛠️ Prerequisites Tools Required

**Cloud & Infrastructure:**

- AWS Account (Free Tier)
- AWS CLI v2 configured
- Terraform, eksctl, kubectl

**CI/CD & Containers:**

- Jenkins
- Docker
- Git

---

## Day-1: CI Pipeline + Shift-Left Security

**Topics Covered:**

- **Create VM Instance (t3.large, x86-64 Spot Instance)** for shift-left security tools installation
- Jenkins setup on EC2 with proper IAM roles
- Multi-stage Jenkins Pipeline configuration
- **Shift-Left Security Tools Installation:**
  - **Snyk** - Software Composition Analysis (SCA)
  - **SonarQube** - Static Application Security Testing (SAST)
  - **Gitleaks** - Secret scanning
  - **OWASP Dependency-Check** - Dependency vulnerabilities
  - **SBOM** - Software Bill of Materials — it's a formal, structured inventory
- **Nexus** repository setup for Unified Docker + npm storages
- **Container Security:** **Dockle** image linting
- Break-the-build logic for High/Critical vulnerabilities
- Git webhook automation for triggered builds
- MERN Stack Multi-stage Dockerfiles creation (Frontend & Backend)
- Security best practices: `.dockerignore`, non-root users, minimal layers, Alpine base images

**Learning Outcome:** End-to-end automated CI pipeline with multi-layer security scanning and secure Docker image creation

---

## Day-2: Infrastructure as Code & Production Networking

**Topics Covered:**

- Multi-AZ VPC setup with Terraform (Public/Private subnets, NAT Gateway, Route Tables)
- Amazon EKS cluster provisioning with Managed Node Groups
- EKS Security best practices: Envelope encryption, private endpoint, audit logging
- Security scanning with **Checkov** on Terraform manifests
- Remote backend with state locking (S3 + DynamoDB)
- Infrastructure validation and compliance checks
- Cost optimization with resource tagging
- **AWS Load Balancer Controller** installation and configuration
- Ingress setup with path-based routing (`/` → Frontend, `/api` → Backend)

```bash
# Create S3 bucket for Terraform state
aws s3api create-bucket \
  --bucket terraform-state-${AWS_ACCOUNT_ID} \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket terraform-state-${AWS_ACCOUNT_ID} \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket terraform-state-${AWS_ACCOUNT_ID} \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1

echo "✅ Terraform backend resources created!"

# Verify IAM user
aws iam get-user --user-name jenkins-eks-admin-user

# Verify attached policies
aws iam list-attached-user-policies --user-name jenkins-eks-admin-user

# Test S3 access
aws s3 ls s3://terraform-state-${AWS_ACCOUNT_ID}

# Test DynamoDB access
aws dynamodb describe-table --table-name terraform-state-lock
```

**Learning Outcome:** Production-ready infrastructure setup with security and compliance

---

## Day-3: Auto-Scaling + GitOps + Persistent Storage

**Topics Covered:**

- **IRSA (IAM Roles for Service Accounts)** for least-privilege AWS access
- SSL/TLS termination using **AWS Certificate Manager (ACM)**
- Security groups and Network ACLs configuration
- **Horizontal Pod Autoscaler (HPA)** setup
- CPU and Memory-based autoscaling configuration & scaling verification
- **ArgoCD** installation on EKS
- Git repository sync for Kubernetes manifests (Deployments, Services, ConfigMaps, Secrets)
- **ArgoCD** for automated container updates
- GitOps repository structure and sync policies
- EBS CSI Driver setup with encryption at rest
- MongoDB deployment using StatefulSets
- PersistentVolumes (PV), PersistentVolumeClaims (PVC), StorageClass configuration

**Learning Outcome:** Production-grade networking with automatic scalability &nd GitOps-based continuous delivery

---

## Day-4: Disaster Recovery + Secrets Management

**Topics Covered:**

- **Velero** installation for Kubernetes backup and restore
- S3 integration for cluster snapshots
- Scheduled backups with retention policies
- **AWS Secret Manager** uses for k8s secrets to rotational secrets

**Learning Outcome:** disaster recovery & enterprise-grade secrets management

---

## Day-5: Runtime Security

**Topics Covered:**

- **Pod Security Standards (PSS)** implementation (Restricted/Baseline)
- **Network Policies** with Calico for pod-to-pod communication control
- **Falco** installation for runtime threat detection
- **Route53** DNS management and health checks
- Real-time security monitoring and anomaly detection
- Security incident response workflow

**Learning Outcome:** Runtime security and

---

## Day-6: Full-Stack Observability + Monitoring + DAST

**Topics Covered:**

- **OpenTelemetry (OTEL)** for **Distributed Tracing (OTEL + Jaeger)** across microservices
- **Prometheus** setup with ServiceMonitor and PodMonitor
- **Grafana** dashboards for system health visualization
- **CloudWatch Container Insights** or ELK Stack for log aggregation
- End-to-end request tracing: React Frontend → Node Backend → MongoDB
- **Prometheus AlertManager** configuration with **Slack** integration
- **DAST:** **OWASP ZAP** scans to find runtime vulnerabilities (XSS, SQLi)
- Custom metrics and alerting rules
- Performance optimization based on metrics

**Learning Outcome:** Complete observability and proactive monitoring

---

## Day-7: End-to-End Demo + Documentation + Cleanup

**Topics Covered:**

- Complete walkthrough: Git push to production-grade secured application
- Security audit report generation
- Architecture diagrams creation
- Deployment runbooks and documentation
- Cost optimization strategies implementation
- **Terraform destroy** for complete resource cleanup

**Learning Outcome:** Complete DevSecOps workflow understanding and cost management

---

## 🎯 What You'll Build:

Production-ready MERN application with:

- ✅ Automated CI/CD pipeline
- ✅ Multiple security layers (SAST, SCA, DAST, Runtime)
- ✅ GitOps-based deployment
- ✅ Auto-scaling capabilities
- ✅ Complete observability
- ✅ Disaster recovery
- ✅ Enterprise-grade secrets management

---

## 🔗 Blog Series Navigation:

- **Day-1:** CI Pipeline with Shift-Left Security
- **Day-2:** Infrastructure as Code
- **Day-3:** Production Networking & Scaling
- **Day-4:** Storage, Backup & GitOps
- **Day-5:** Runtime Security & Secrets
- **Day-6:** Observability, Monitoring & DAST
- **Day-7:** Complete Demo & Cleanup

---

**Happy Learning! 🚀**
