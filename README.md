# 🚀 10-Day DevSecOps Masterclass:

---

## Day-0: The Blueprint – Architecture & Plan

## **Prerequisites:**

### 🛠️ Prerequisites & Environment Setup

Ensure you have the following tools installed and configured before starting the Masterclass:

- **Cloud Provider:**
- **AWS Account** - [Create Free Tier Account](https://aws.amazon.com/free/)
- **AWS CLI v2** - [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (Run `aws configure` after install)
- **Infrastructure & Orchestration:**
- **Terraform** - [Installation Guide](https://developer.hashicorp.com/terraform/install) (To provision VPC & EKS)
- **eksctl** - [Installation Guide](https://www.google.com/search?q=https://eksctl.io/introduction/%23installation) (Official CLI for Amazon EKS)
- **kubectl** - [Installation Guide](https://kubernetes.io/docs/tasks/tools/) (To interact with the cluster)
- **Automation & Containerization:**
- **Jenkins** - [Installation Guide](https://www.jenkins.io/doc/book/installing/) (CI/CD Server - Recommended on an EC2 t3.medium)
- **Docker** - [Get Docker](https://www.google.com/search?q=https://docs.docs.docker.com/get-docker/) (To build and scan MERN images)
- **Version Control:**
- **Git** - [Download & Install](https://git-scm.com/downloads) (To manage your DevSecOps repository)

* IAM user with AdministratorAccess configured
* Billing alerts configured in AWS account

**Day-0 Topics:**

- Project Overview: Why MERN Stack for DevSecOps?
- Understanding Enterprise Architecture: VPC, EKS, ALB, and Database layers.
- The DevSecOps Toolchain: Introduction to Terraform, Jenkins, ArgoCD, Nexus, SonarQube, Snyk, Trivy, and Velero.
- **Terraform Backend Setup:** Configuring S3 bucket and DynamoDB table for remote state management and locking.
- **Cost Estimation:** Understanding AWS pricing for EKS, EC2, ECR, and S3.

---

## Day-1: IaC – Provisioning a Hardened EKS Cluster

- Infrastructure as Code (IaC) with **Terraform**.
- Designing a Multi-AZ VPC with Public and Private subnets, NAT Gateways, and Route Tables.
- Provisioning Amazon **EKS** with Managed Node Groups and IAM OIDC Provider.
- Implementing **EKS Security Best Practices:** Enabling envelope encryption, private endpoint access, and audit logging.
- **Security Scan:** Running `Checkov` or `Terrascan` on Terraform manifests to detect misconfigurations.
- **Terraform State Management:** Implementing remote backend with state locking.

---

## Day-2: Containerization & Zero-Vulnerability Images

- Dockerizing MERN: Multi-stage Dockerfiles for React (Frontend) and Node.js (Backend).
- Optimizing images: Using Distroless/Alpine images to reduce attack surface.
- **Best Practices:** Implementing `.dockerignore`, non-root users, and minimal layers.
- **Multi-Architecture Builds:** Building x86_64 images for cost optimization on instances.
- **Image Scanning:** Integrating **Trivy** to identify OS-level and application vulnerabilities.
- Pushing secure images to **Amazon ECR** with lifecycle policies.
- **Container Security:** Implementing image signing and verification.

---

## Day-3: CI Pipeline – Automation & Shift-Left Security

- Setting up the **Jenkins** CI Server on EC2 with proper IAM roles.
- Configuring Jenkins Pipelines with Shared Libraries and parameterized builds.
- **Secret Scanning:** Integrating **Gitleaks** to prevent credential leaks in source code.
- **SAST:** Implementing **SonarQube** for Static Application Security Testing and Quality Gates.
- **Artifact Management:** Setting up Sonatype Nexus as a centralized repository for build artifacts.
- **Pipeline Security:** Securing Jenkins with RBAC, credentials management, and audit logs.
- **Webhook Integration:** Automating builds on Git push events.

---

## Day-4: Supply Chain Security – SCA & Artifact Lifecycle

- What is Software Composition Analysis (SCA)?
- Integrating **Snyk** in the pipeline.
- Scanning `package.json` and `package-lock.json` for vulnerable NPM libraries.
- **SBOM Generation:** Creating Software Bill of Materials for compliance.
- Automating "Break the Build" logic for High/Critical vulnerabilities.
- **Dependency Management:** Implementing automated dependency updates with security checks.

---

## Day-5: Persistence & Disaster Recovery with Velero

- Kubernetes Storage: Setting up **EBS CSI Driver** for MongoDB with encryption at rest.
- Managing State: PersistentVolumes (PV), PersistentVolumeClaims (PVC), and StorageClasses.
- **StatefulSets:** Deploying MongoDB with proper volume management.
- **Disaster Recovery:** Installing **Velero** for EKS backups with AWS S3 integration.
- **Demo:** Backing up cluster snapshots to **Amazon S3** and performing a complete recovery test.
- **Backup Strategies:** Implementing scheduled backups and retention policies.

---

## Day-6: GitOps Excellence – Continuous Delivery with ArgoCD, Scalability & Performance Optimization

- Introduction to GitOps: Push vs. Pull deployment models and benefits.
- Installing and configuring **ArgoCD** on EKS with HA setup.
- Syncing K8s Manifests (Deployments, Services, ConfigMaps, Secrets) from Git.
- **Automation:** Implementing **ArgoCD Image Updater** for seamless container updates.
- **GitOps Best Practices:** Repository structure, sync policies, and health checks.
- **Horizontal Pod Autoscaling (HPA):** Configuring CPU and memory-based autoscaling.
- **RBAC in ArgoCD:** Implementing role-based access control for team collaboration.

---

## Day-7: Production Networking – ALB Ingress & IAM (IRSA)

- Exposing the MERN app: Setting up **AWS Load Balancer Controller** (formerly ALB Ingress Controller).
- Path-based routing: Routing `/` to Frontend and `/api` to Backend with health checks.
- **Security:** Implementing **IAM Roles for Service Accounts (IRSA)** for least-privilege access to AWS services.
- SSL/TLS Termination using **AWS Certificate Manager (ACM)** with automatic certificate renewal.
- **Network Security:** Implementing security groups and NACLs for defense in depth.
- **DNS Management:** Configuring Route53 for domain routing and health checks.

---

## Day-8: Runtime Security & Secrets Management

- **DAST:** Running **OWASP ZAP** scans against the live application for vulnerability detection.
- **Pod Security Standards:** Implementing PSS (Restricted/Baseline) for pod-level security controls.
- Advanced Secrets: Moving from K8s Secrets to **AWS Secrets Manager** with automatic rotation.
- **Secrets Management:** Integrating External Secrets Operator for dynamic secret injection.
- **Network Policies:** Restricting Pod-to-Pod communication within the cluster using Calico.
- **Runtime Threat Detection:** Installing **Falco** for real-time security monitoring and anomaly detection.

---

## Day-9: Full-Stack Observability – OTEL & Monitoring

- Introduction to **OpenTelemetry (OTEL)** for Distributed Tracing across microservices.
- Setting up **Prometheus** for metrics collection with ServiceMonitor and PodMonitor.
- Visualizing system health with **Grafana** Dashboards and custom panels.
- **Log Aggregation:** Implementing CloudWatch Container Insights or ELK Stack for centralized logging.
- Tracing a complete request: React Frontend → Node Backend → MongoDB.
- **Alerting:** Configuring Prometheus AlertManager with SNS integration for critical alerts.

---

## Day-10: The Grand Finale – E2E Demo & Cleanup

- **Complete Walkthrough:** From `git push` to a live, secured production-grade application.
- **Security Audit Report:** Generating comprehensive security posture assessment.
- **Documentation:** Creating runbooks, architecture diagrams, and deployment guides.
- **Cost Optimization:** Reviewing AWS Cost Explorer and implementing cost-saving strategies.
- **Cleanup:** Running `terraform destroy` to properly teardown all AWS resources and avoid charges.

---
