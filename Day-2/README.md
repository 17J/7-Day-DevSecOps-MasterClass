## Day-2: Infrastructure as Code

<!-- ---

## What You Will Learn Today -->
# Day 1: Building a Secure CI Pipeline with Shift-Left Security — Complete Step-by-Step Guide

![Cover Image - DevSecOps Pipeline](cover-image-placeholder)

Welcome to Day 1 of my **7-Day DevSecOps MasterClass**! This isn't just another "here's what I built" article. This is a **complete, step-by-step guide** where I'll show you **exactly** how to build a production-grade DevSecOps pipeline from scratch.

**By the end of this guide, you'll have:**
- ✅ A fully functional CI/CD pipeline
- ✅ 6 integrated security scanning tools
- ✅ Automated vulnerability detection
- ✅ Container image security
- ✅ AWS ECR integration
- ✅ Break-the-build logic for critical issues

**Time Required:** 2-3 hours  
**Cost:** ~$5/month (using spot instances)  
**Difficulty:** Intermediate

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Infrastructure Setup](#infrastructure-setup)
3. [Tools Installation](#tools-installation)
4. [Jenkins Configuration](#jenkins-configuration)
5. [SonarQube Setup](#sonarqube-setup)
6. [Nexus Configuration](#nexus-configuration)
7. [Jenkins Pipeline Creation](#jenkins-pipeline-creation)
8. [Testing & Results](#testing-results)

---

# 🎯 What We're Building

A complete CI/CD pipeline that:
- **Scans for secrets** before code is committed (Gitleaks)
- **Analyzes code quality** with SonarQube (SAST)
- **Checks dependencies** for vulnerabilities (Snyk, OWASP)
- **Generates SBOM** for supply chain security (Syft)
- **Lints Docker images** for best practices (Dockle)
- **Breaks the build** if critical issues are found
- **Pushes secure images** to AWS ECR

## 🛠️ Tech Stack Overview

| Category | Tool | Purpose |
|----------|------|---------|
| **CI/CD** | Jenkins 2.479.2 | Pipeline orchestration |
| **Code Quality** | SonarQube 9.9 | SAST analysis |
| **Artifact Storage** | Nexus 3.x | npm & Docker registry |
| **Container Runtime** | Docker 28.2.2 | Build & run containers |
| **SCA** | Snyk | Dependency scanning |
| **Secret Scanning** | Gitleaks | Find exposed credentials |
| **Vulnerability DB** | OWASP Dependency-Check | CVE database scanning |
| **SBOM** | Syft | Software Bill of Materials |
| **Container Linting** | Dockle | Docker best practices |
| **Cloud** | AWS ECR | Container registry |

---

# 📦 Prerequisites

Before starting, ensure you have:

- [ ] **AWS Account** (free tier works)
- [ ] **GitHub Account** 
- [ ] **Basic Linux knowledge**
- [ ] **2-3 hours of focused time**

**Required API Keys** (free):
- Snyk API Key → [Sign up here](https://snyk.io/)
- NVD API Key → [Get it here](https://nvd.nist.gov/developers/request-an-api-key)

---

# 🚀 Part 1: Infrastructure Setup

## Step 1.1: Launch EC2 Spot Instance

**Why Spot Instance?**
- 💰 **62% cheaper** than on-demand ($0.0312/hour vs $0.0832/hour)
- ⚡ Perfect for CI/CD workloads (interruptions are acceptable)

### Launch Steps:

1. Open **AWS EC2 Console** → **Spot Requests**
2. Click **"Request Spot Instances"**

3. **Configuration:**
   ```yaml
   AMI: Ubuntu Server 24.04 LTS
   Architecture: 64-bit (x86)
   Instance Type: t3.large
   vCPUs: 2
   Memory: 8 GB
   Storage: 30 GB GP3 SSD
   ```

4. **Network Settings:**
   - VPC: Default
   - Subnet: Any availability zone
   - Auto-assign Public IP: **Enable**

5. **Key Pair:** Create new or use existing

6. Click **"Launch"**

![Spot Instance Request](./images/spot_instances_request.png)

✅ **Success!** Two spot instances active and running.

**💡 Pro Tip:** Enable "Persistent request" so AWS automatically launches a new instance if interrupted.

---

## Step 1.2: Configure Security Group

**This is CRITICAL** — without proper ports, nothing will work!

1. Go to **EC2 → Security Groups**
2. Select your instance's security group
3. Click **"Edit inbound rules"**
4. Add these rules:

```yaml
Type            Port Range      Source          Description
─────────────────────────────────────────────────────────────
Custom TCP      8080           0.0.0.0/0        Jenkins UI
Custom TCP      9000           0.0.0.0/0        SonarQube UI
Custom TCP      8081           0.0.0.0/0        Nexus UI
Custom TCP      3000-10000     0.0.0.0/0        Application Ports
Custom TCP      30000-42000    0.0.0.0/0        NodePort Range
SSH             22             0.0.0.0/0        SSH Access
HTTP            80             0.0.0.0/0        HTTP
HTTPS           443            0.0.0.0/0        HTTPS
SMTP            25             0.0.0.0/0        Email
SMTPS           465            0.0.0.0/0        Secure Email
```

![Security Group Inbound Rules](./images/SG-Inbound-Rules.png)

⚠️ **Security Warning:** In production, replace `0.0.0.0/0` with your organization's IP range!

---

## Step 1.3: Connect to Instance

```bash
# Replace with your key file and public IP
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@<YOUR-EC2-PUBLIC-IP>
```

---

# 🔧 Part 2: Automated Tools Installation

## Step 2.1: Clone the Repository

I've created an automated script that installs everything. Let's get it:

```bash
# Clone the repository
git clone https://github.com/17J/7-Day-DevSecOps-MasterClass.git
cd 7-Day-DevSecOps-MasterClass/Day-1
```

## Step 2.2: Run the Installation Script

```bash
# Make it executable
chmod +x install-tools.sh

# Run the installation (takes 5-10 minutes)
./install-tools.sh
```

**What this script installs:**
1. ✅ Docker 28.2.2
2. ✅ Jenkins 2.479.2
3. ✅ SonarQube (via Docker)
4. ✅ Nexus Repository (via Docker)
5. ✅ Dockle (Container linter)
6. ✅ Gitleaks (Secret scanner)
7. ✅ Syft (SBOM generator)

The script will **automatically reboot** your instance. Wait 2 minutes, then reconnect.

---

## Step 2.3: Verify Installation

After reconnect, verify everything:

### ✅ Docker

```bash
docker --version
# Expected: Docker version 28.2.2

docker ps
# Should show: sonarqube and nexus containers
```

![Docker Version](./images/docker_version_screenshot.png)

![Docker Containers Running](./images/docker_container_running.png)

**Perfect!** All containers running:
- Container ID: `680c19cf0473` - Jenkins (port 8080)
- Container ID: `8c36f2644825` - Nexus (port 8081)
- Container ID: `d991e4484db` - SonarQube (port 9000)

### ✅ Jenkins

```bash
sudo systemctl status jenkins
```

![Jenkins Status](./images/jenkins_status.png)

✅ Jenkins is **active (running)** since 08:23:05 UTC!

### ✅ Security Tools

```bash
gitleaks version      # Should show v8.18.0
dockle --version      # Should show latest version
syft version          # Should show latest version
```

---

# 🔐 Part 3: Jenkins Initial Setup

## Step 3.1: Access Jenkins

Open browser: `http://<YOUR-EC2-PUBLIC-IP>:8080`

### Get Initial Admin Password

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Copy the password and paste it in Jenkins.

## Step 3.2: Install Plugins

1. Select **"Install suggested plugins"**
2. Wait for installation (5-10 minutes)
3. Create your admin user:
   ```
   Username: admin
   Password: <your-secure-password>
   Full name: Your Name
   Email: your-email@example.com
   ```
4. Keep the default Jenkins URL
5. Click **"Start using Jenkins"**

## Step 3.3: Install Additional Required Plugins

Go to **Dashboard → Manage Jenkins → Plugins → Available Plugins**

Search and install these (one by one or all together):

```
✅ SonarQube Scanner
✅ NodeJS
✅ Docker Pipeline
✅ OWASP Dependency-Check
✅ Blue Ocean (optional, for better visualization)
```

**Important:** Click **"Install without restart"** then check **"Restart Jenkins when installation is complete"**

Wait for Jenkins to restart (2-3 minutes).

---

# ⚙️ Part 4: Configure Jenkins Tools

## Step 4.1: Configure Node.js

1. Go to **Dashboard → Manage Jenkins → Tools**
2. Scroll to **"NodeJS installations"**
3. Click **"Add NodeJS"**

**Configuration:**
```yaml
Name: nodejs-23.10.0
Version: NodeJS 23.10.0
Global npm packages to install: (leave empty)
Global npm packages refresh hours: 72
```

4. Click **"Save"**

**💡 Why Node.js 23.10.0?** Latest LTS version with security patches and performance improvements.

## Step 4.2: Configure Snyk

1. In the same **Tools** page
2. Scroll to **"Snyk installations"**
3. Click **"Add Snyk"**

**Configuration:**
```yaml
Name: snyk
Install automatically: ✅ (checked)
Version: Latest
```

4. Click **"Save"**

---

# 🔑 Part 5: Configure Jenkins Credentials

This is **crucial** — we'll store all our API keys and secrets securely.

## Step 5.1: Add SonarQube Token

### First, Generate SonarQube Token:

1. Open `http://<YOUR-EC2-PUBLIC-IP>:9000`
2. **Default credentials:**
   ```
   Username: admin
   Password: admin
   ```
3. You'll be forced to change password — use a secure one!
4. Go to **My Account → Security → Generate Token**
   ```
   Token Name: jenkins
   Type: User Token
   Expiration: No expiration
   ```
5. **Copy the token** (you won't see it again!)

### Add Token to Jenkins:

1. **Dashboard → Manage Jenkins → Credentials**
2. Click **(global)** domain
3. Click **"Add Credentials"**

**Configuration:**
```yaml
Kind: Secret text
Scope: Global
Secret: <paste-your-sonarqube-token>
ID: sonar-cred
Description: SonarQube authentication token
```

4. Click **"Create"**

## Step 5.2: Add Snyk API Key

### Get Snyk API Key:

1. Go to [snyk.io](https://snyk.io/)
2. Sign up / Log in
3. Go to **Account Settings → General**
4. Copy your **API Token**

### Add to Jenkins:

**Dashboard → Manage Jenkins → Credentials → Add Credentials**

```yaml
Kind: Secret text
Scope: Global
Secret: <paste-your-snyk-api-key>
ID: snyk-cred
Description: Snyk API key for vulnerability scanning
```

## Step 5.3: Add NVD API Key

### Get NVD API Key:

1. Go to [NVD API Key Request](https://nvd.nist.gov/developers/request-an-api-key)
2. Fill the form and submit
3. Check your email for the API key

### Add to Jenkins:

```yaml
Kind: Secret text
Scope: Global
Secret: <paste-your-nvd-api-key>
ID: nvd-api-key
Description: National Vulnerability Database API key
```

## Step 5.4: Add AWS Credentials

### Create IAM User:

1. Go to **AWS IAM → Users → Create User**
2. Username: `jenkins-ecr-user`
3. Attach policy: `AmazonEC2ContainerRegistryPowerUser`
4. **Create access key** → **CLI**
5. Copy **Access Key ID** and **Secret Access Key**

### Add to Jenkins:

```yaml
Kind: Secret text
Scope: Global
Secret: <AWS_ACCESS_KEY_ID>
ID: aws-access-key
Description: AWS Access Key ID

Kind: Secret text
Scope: Global
Secret: <AWS_SECRET_ACCESS_KEY>
ID: aws-secret-key
Description: AWS Secret Access Key
```

**Or use AWS Credentials type:**

```yaml
Kind: AWS Credentials
Scope: Global
Access Key ID: <your-access-key-id>
Secret Access Key: <your-secret-access-key>
ID: aws-cred
Description: AWS ECR credentials
```

## Step 5.5: Add Nexus Credentials

### Get Nexus Password:

```bash
# SSH to your EC2 instance
docker exec nexus cat /nexus-data/admin.password
```

### Change Nexus Password:

1. Open `http://<YOUR-EC2-PUBLIC-IP>:8081`
2. Click **"Sign In"**
   ```
   Username: admin
   Password: <password-from-above-command>
   ```
3. Complete setup wizard:
   - Change password to something secure
   - **Disable anonymous access** ✅
   - Finish wizard

### Add to Jenkins:

```yaml
Kind: Username with password
Scope: Global
Username: admin
Password: <your-new-nexus-password>
ID: nexus-auth-id
Description: Nexus repository authentication
```

![Jenkins Credentials Complete](./images/jenkins_creds.png)

**✅ Perfect!** All 5 credentials configured:
- `sonar-cred` - SonarQube
- `nvd-api-key` - NVD Database
- `snyk-cred` - Snyk scanning
- `aws-cred` - AWS ECR
- `nexus-auth-id` - Nexus repository

---

# 🔍 Part 6: SonarQube Configuration

## Step 6.1: Configure SonarQube Server in Jenkins

1. **Dashboard → Manage Jenkins → System**
2. Scroll to **"SonarQube servers"**
3. Click **"Add SonarQube"**

**Configuration:**
```yaml
Name: sonar
Server URL: http://<YOUR-PRIVATE-IP>:9000
Server authentication token: sonar-cred (select from dropdown)
```

**💡 Use Private IP here**, not public IP! Find it:
```bash
hostname -I | awk '{print $1}'
```

4. Click **"Save"**

## Step 6.2: Create Quality Gate in SonarQube

1. Open SonarQube UI: `http://<YOUR-EC2-PUBLIC-IP>:9000`
2. Go to **Quality Gates**
3. Click **"Create"**

**Configuration:**
```yaml
Name: DevSecOps-Gate
Conditions:
  - Security Issues: E rating → Fail
  - Bugs: C rating → Fail
  - Code Smells: Maintainability Rating D → Fail
```

4. Set as **Default**

![SonarQube Results](./images/sonarqube_result.png)

Our analysis results:
- **Security**: 1 issue (E rating)
- **Reliability**: 16 issues (C rating)  
- **Maintainability**: 74 issues (A rating) ✅
- **Coverage**: 0.0% (need tests!)
- **Duplications**: 0.9% (excellent!)
- **8.2K lines** analyzed

---

# 📦 Part 7: Nexus Repository Configuration

## Step 7.1: Create NPM Hosted Repository

1. Open Nexus: `http://<YOUR-EC2-PUBLIC-IP>:8081`
2. Sign in with admin credentials
3. Click ⚙️ **Settings** → **Repositories**
4. Click **"Create repository"**

**Select:** `npm (hosted)`

**Configuration:**
```yaml
Name: npm-hosted
Online: ✅
Storage:
  Blob store: default
  Strict Content Type Validation: ✅
Hosted:
  Deployment policy: Allow redeploy
Cleanup Policies: None (for now)
```

5. Click **"Create repository"**

![Nexus Dashboard](./images/nexus_ui.png)

Dashboard showing:
- **Components**: 0/40,000
- **Requests/Day**: 0/100,000
- **System Health**: ✅ Green

![NPM Hosted Repository](./images/npm_hosted_ui.png)

After builds, we'll see packages here:
- `vite-react-shadcnts-1.0.0.tgz`
- `showmoore-server-1.0.0.tgz`

## Step 7.2: Configure NPM Auth in Jenkins

1. **Dashboard → Manage Jenkins → Managed files**
2. Click **"Add a new Config"**
3. Select **"NPM config file"**

**Configuration:**
```yaml
ID: npmrc-nexus-config
Name: NPM Nexus Configuration
Comment: NPM registry configuration for Nexus
```

**Content:**
```ini
registry=http://<YOUR-PRIVATE-IP>:8081/repository/npm-hosted/
//<YOUR-PRIVATE-IP>:8081/repository/npm-hosted/:_auth=${NPM_AUTH}
always-auth=true
```

4. In **"Server Credentials"** section:
   - Click **"Add"**
   - Select `nexus-auth-id`

5. Click **"Submit"**

![Nexus Config in Jenkins](./images/nexus_config_file_jenkins.png)

---

# 🏗️ Part 8: Create Jenkins Pipeline

## Step 8.1: Create ECR Repositories

First, create AWS ECR repositories for our Docker images:

```bash
# Replace with your AWS region
aws ecr create-repository \
    --repository-name ecom/frontend-ecommerce-mern \
    --region ap-south-1

aws ecr create-repository \
    --repository-name ecom/backend-ecommerce-mern \
    --region ap-south-1
```

![ECR Repositories](./images/ECR_View.png)

✅ Two repositories created:
- `ecom/frontend-ecommerce-mern`
- `ecom/backend-ecommerce-mern`

Both with **AES-256 encryption** and **mutable tags**.

## Step 8.2: Create Pipeline Job

1. **Dashboard → New Item**
2. **Name:** `Gitops-Ecomm-CI-Pipeline`
3. **Type:** Pipeline
4. Click **"OK"**

## Step 8.3: Configure Pipeline

### General Settings:
```yaml
Description: Complete DevSecOps CI Pipeline with Shift-Left Security
Discard old builds: ✅
  Days to keep builds: 7
  Max # of builds to keep: 10
GitHub project: https://github.com/17J/7-Day-DevSecOps-MasterClass.git
```

### Build Triggers:
```yaml
✅ GitHub hook trigger for GITScm polling
```

### Pipeline Configuration:

**Definition:** Pipeline script from SCM

```yaml
SCM: Git
Repository URL: https://github.com/17J/7-Day-DevSecOps-MasterClass.git
Branch: */main
Script Path: Day-1/Jenkinsfile
```

## Step 8.4: Configure GitHub Webhook

1. Go to your GitHub repository
2. **Settings → Webhooks → Add webhook**

**Configuration:**
```yaml
Payload URL: http://<YOUR-EC2-PUBLIC-IP>:8080/github-webhook/
Content type: application/json
Secret: (leave empty for now)
Which events: Just the push event
Active: ✅
```

3. Click **"Add webhook"**

---

# 🚀 Part 9: Run the Pipeline!

## Step 9.1: Trigger Build

1. Go to your pipeline: **Dashboard → Gitops-Ecomm-CI-Pipeline**
2. Click **"Build Now"**

![Jenkins Dashboard](./images/jenkins_dashboard_two.png)

## Step 9.2: Watch the Magic Happen! ✨

![Pipeline Stages Visualization](./images/Pipeline_stages_view_graph.png)

**Pipeline Execution:**

```
Stage 1: Declarative: Tool Install (208ms)
  ├─ Install Node.js 23.10.0
  └─ Install Snyk

Stage 2: Initial Checks (2s)
  ├─ Git checkout
  └─ Environment validation

Stage 3: Security & Syntax (14s)
  ├─ Gitleaks - Secret scanning
  ├─ Snyk - Dependency scanning (Frontend)
  ├─ Snyk - Dependency scanning (Backend)
  └─ Syntax validation

Stage 4: Build & Unit Tests (12s)
  ├─ npm install (Frontend)
  ├─ npm install (Backend)
  ├─ npm test (Frontend)
  └─ npm test (Backend)

Stage 5: SonarQube & Nexus (34s)
  ├─ SonarQube analysis
  ├─ Wait for Quality Gate
  ├─ Upload to Nexus (Frontend)
  └─ Upload to Nexus (Backend)

Stage 6: Docker & SCA (33s)
  ├─ Build Docker images (multi-stage)
  ├─ Dockle linting (Frontend)
  ├─ Dockle linting (Backend)
  ├─ Syft SBOM (Frontend)
  └─ Syft SBOM (Backend)

Stage 7: Final Security Scan (4m 14s)
  ├─ OWASP Dependency-Check
  ├─ AWS ECR Login
  ├─ Push Frontend image
  └─ Push Backend image

Stage 8: Post Actions (757ms)
  ├─ Archive artifacts
  ├─ Generate reports
  └─ Send notifications
```

**Total Duration:** ~5 minutes

---

# 📊 Part 10: Analyzing the Results

## ✅ Build Artifacts Generated

![All Build Artifacts](./images/all_report_screenshots.png)

Every build produces:
- `snyk-frontend.json` (43.19 KB) - Frontend vulnerabilities
- `snyk-backend.json` (22.44 KB) - Backend vulnerabilities
- `sbom-frontend.json` (411.87 KB) - Frontend SBOM
- `sbom-backend.json` (653.85 KB) - Backend SBOM
- `gitleaks-report.json` (994 B) - Secret scan results
- `dockle-frontend.json` (4.50 KB) - Frontend Docker lint
- `dockle-backend.json` (616 B) - Backend Docker lint

## 🔒 Security Scan Results

### OWASP Dependency-Check Report

![OWASP Report](./images/OWASP_Dependency_report.png)

**Vulnerability Breakdown:**
- 🔴 **Critical**: 1
- 🟠 **High**: 9
- 🟡 **Medium**: 18
- 🟢 **Low**: 6

**Total:** 34 vulnerabilities

**Key Findings:**
```
@babel/runtime@7.25.9
  ├─ GH-SA-s5bp-4wwm-cqcø (Medium)
  ├─ GH-SA-xffm-g5w6-qug7 (Medium)
  └─ GH-SA-zwos-qujq-huix (High)

axios
  └─ CVE-2025-56754 (High)

@eslint/plugin-kit@0.2.3
  └─ GH-SA-4nij-wvwv-csxuj (High)
```

### Dependency Trend

![Dependency Trend](./images/dp_report_view.png)

Tracking across builds #26, #27, #28:
- ✅ No new critical vulnerabilities
- ✅ Stable vulnerability count
- ✅ Consistent security posture

## 📈 Available Reports

![Pipeline Reports Sidebar](./images/pipeline_side_report.png)

Jenkins provides:
- ✅ Dependency-Check reports
- ✅ Pipeline Overview
- ✅ Blue Ocean visualization
- ✅ Git Build Data
- ✅ Console Output

## 🐳 Docker Images Created

![Docker Images](./images/images_container.png)

**Local Images:**
```
REPOSITORY                                                    TAG    SIZE
381492102582.dkr.ecr.ap-south-1.amazonaws.com/ecom/backend   28     178MB
381492102582.dkr.ecr.ap-south-1.amazonaws.com/ecom/backend   27     178MB
381492102582.dkr.ecr.ap-south-1.amazonaws.com/ecom/frontend  27     63.4MB
381492102582.dkr.ecr.ap-south-1.amazonaws.com/ecom/frontend  28     63.4MB
```

**Why the size difference?**
- **Backend (178MB)**: Node.js runtime + dependencies
- **Frontend (63.4MB)**: Nginx Alpine + static React build

## ☁️ Images Pushed to ECR

### Backend Repository

![Backend ECR](./images/backend_ecr.png)

**2 Images Pushed:**
- Tag 28: 54.94 MB (pushed 17:53:07 UTC)
- Tag 27: 54.94 MB (pushed 17:46:22 UTC)

### Frontend Repository

![Frontend ECR](./images/frontend_Ecr.png)

**1 Image with 2 Tags:**
- Tags 27, 28: 26.36 MB (pushed 17:46:14 UTC)

**Why smaller in ECR?**
- Images are compressed during push
- ECR deduplicates layers
- Multi-stage builds remove build artifacts

---

# 🎓 Understanding the Pipeline Architecture

## 🏗️ Complete Pipeline Flow

```
┌──────────────────────────────────────────────────┐
│  1. TOOL INSTALLATION (208ms)                    │
│  ├─ Install Node.js 23.10.0                      │
│  └─ Install Snyk CLI                             │
├──────────────────────────────────────────────────┤
│  2. INITIAL CHECKS (2s)                          │
│  ├─ Git checkout from GitHub                     │
│  ├─ Validate repository structure                │
│  └─ Check environment variables                  │
├──────────────────────────────────────────────────┤
│  3. SECURITY & SYNTAX (14s)                      │
│  ├─ Gitleaks: Scan for exposed secrets          │
│  ├─ Snyk: Frontend dependency scan              │
│  ├─ Snyk: Backend dependency scan               │
│  └─ Syntax validation (ESLint, TSC)             │
├──────────────────────────────────────────────────┤
│  4. BUILD & UNIT TESTS (12s)                     │
│  ├─ npm install (Frontend)                       │
│  ├─ npm install (Backend)                        │
│  ├─ npm test (Frontend)                          │
│  └─ npm test (Backend)                           │
├──────────────────────────────────────────────────┤
│  5. SONARQUBE & NEXUS (34s)                      │
│  ├─ SonarQube Scanner (Frontend + Backend)      │
│  ├─ Wait for Quality Gate result                │
│  ├─ npm pack (Frontend)                         │
│  ├─ npm pack (Backend)                          │
│  ├─ Upload to Nexus (Frontend .tgz)             │
│  └─ Upload to Nexus (Backend .tgz)              │
├──────────────────────────────────────────────────┤
│  6. DOCKER & SCA (33s)                           │
│  ├─ Build multi-stage Dockerfile (Frontend)     │
│  ├─ Build multi-stage Dockerfile (Backend)      │
│  ├─ Dockle lint (Frontend image)                │
│  ├─ Dockle lint (Backend image)                 │
│  ├─ Syft SBOM generation (Frontend)             │
│  └─ Syft SBOM generation (Backend)              │
├──────────────────────────────────────────────────┤
│  7. FINAL SECURITY SCAN (4m 14s)                 │
│  ├─ OWASP Dependency-Check (full CVE scan)      │
│  ├─ AWS ECR authentication                       │
│  ├─ Tag images with build number                │
│  ├─ Push Frontend image to ECR                  │
│  └─ Push Backend image to ECR                   │
├──────────────────────────────────────────────────┤
│  8. POST ACTIONS (757ms)                         │
│  ├─ Archive JSON reports                         │
│  ├─ Publish OWASP Dependency-Check report       │
│  ├─ Generate build summary                      │
│  └─ Send notifications (if configured)          │
└──────────────────────────────────────────────────┘
```

## 🚨 Break-the-Build Logic

The pipeline **automatically fails** if:

```yaml
❌ Gitleaks finds exposed secrets
❌ Snyk finds Critical vulnerabilities
❌ SonarQube Quality Gate fails
❌ Unit tests fail
❌ Dockle finds Critical issues (CIS violations)
❌ OWASP finds Critical CVEs
```

**This ensures:**
- No secrets reach the repository
- No vulnerable dependencies are deployed
- Code quality standards are maintained
- Docker images follow best practices
- Known CVEs are addressed before production

---

# 🔐 Security Best Practices Implemented

## Docker Security

### ✅ Multi-Stage Builds

```dockerfile
# Stage 1: Builder (discarded in final image)
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Stage 2: Runtime (final image)
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

**Benefits:**
- ⬇️ 60% smaller image size
- 🔒 No build tools in production
- 🚀 Faster deployments

### ✅ Non-Root User

```dockerfile
FROM node:18-alpine
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
USER nodejs
```

**Why?**
- Prevents privilege escalation attacks
- Follows principle of least privilege
- Required by many Kubernetes policies

### ✅ .dockerignore

```
node_modules/
.git/
.env
.env.local
*.log
coverage/
.DS_Store
```

**Prevents:**
- Secrets in images
- Large unnecessary files
- Development dependencies

## Pipeline Security

### ✅ Credential Management

All secrets stored in **Jenkins Credentials Store**:
- Never in code
- Never in logs
- Encrypted at rest
- Access controlled

### ✅ Secret Scanning

**Gitleaks** scans every commit for:
```
- AWS keys
- API tokens
- Private keys
- Passwords
- Database URLs
```

### ✅ SBOM Generation

**Syft** creates complete inventory:
```json
{
  "artifacts": [
    {
      "name": "express",
      "version": "4.18.2",
      "type": "npm",
      "licenses": ["MIT"],
      "cpes": ["cpe:2.3:a:..."]
    }
  ]
}
```

**Why SBOM matters:**
- Respond quickly to new vulnerabilities
- License compliance
- Supply chain security

---

# 📊 Key Metrics & Results

| Metric | Before Optimization | After Optimization |
|--------|-------------------|-------------------|
| **Build Time** | 8m 32s | 4m 59s ⚡ |
| **Docker Image Size** (Backend) | 312 MB | 178 MB ⬇️ |
| **Docker Image Size** (Frontend) | 98 MB | 63.4 MB ⬇️ |
| **ECR Image Size** (Backend) | - | 54.94 MB |
| **ECR Image Size** (Frontend) | - | 26.36 MB |
| **Vulnerabilities Found** | Unknown | 34 (1 Critical) |
| **Code Coverage** | 0% | 0% (needs tests!) |
| **SonarQube Rating** | - | A (Maintainability) |
| **Security Tools** | 0 | 6 ✅ |

---

# 💡 Lessons Learned & Pro Tips

## 1. Always Use Spot Instances for CI/CD

**Cost Savings:**
```
On-Demand: $0.0832/hour × 730 hours = $60.74/month
Spot: $0.0312/hour × 730 hours = $22.78/month
SAVINGS: $37.96/month (62%!)
```

## 2. Multi-Stage Builds Are Essential

**Before:**
```dockerfile
FROM node:18
COPY . .
RUN npm install
RUN npm run build
CMD ["npm", "start"]
```
**Result:** 312 MB image with dev dependencies!

**After:**
```dockerfile
FROM node:18 AS builder
RUN npm run build

FROM node:18-alpine
COPY --from=builder /app/dist ./dist
CMD ["node", "dist/index.js"]
```
**Result:** 178 MB image, no dev dependencies!

## 3. Cache Dependencies for Faster Builds

```groovy
stage('Build') {
    steps {
        // Cache node_modules between builds
        cache(path: 'frontend/node_modules', key: 'npm-${HASH}') {
            sh 'npm install'
        }
    }
}
```

## 4. Parallel Stages Speed Things Up

```groovy
stage('Security Scanning') {
    parallel {
        stage('Snyk Frontend') {
            steps { sh 'snyk test frontend' }
        }
        stage('Snyk Backend') {
            steps { sh 'snyk test backend' }
        }
    }
}
```

## 5. Break-the-Build Requires Thresholds

Too strict = developers ignore  
Too loose = vulnerabilities slip through

**Our sweet spot:**
```yaml
Critical: Always fail ❌
High: Fail if > 5
Medium: Fail if > 20
Low: Warning only ⚠️
```

---

# 🚧 Challenges & Solutions

## Challenge 1: Jenkins Running Out of Memory

**Problem:** Jenkins OOM killed during OWASP scan

**Solution:**
```bash
# Edit Jenkins config
sudo nano /etc/default/jenkins

# Add these Java options
JAVA_OPTS="-Xmx2048m -Xms512m"

# Restart Jenkins
sudo systemctl restart jenkins
```

## Challenge 2: SonarQube Quality Gate Timeout

**Problem:** Pipeline waiting forever for SonarQube

**Solution:**
```groovy
timeout(time: 5, unit: 'MINUTES') {
    waitForQualityGate abortPipeline: true
}
```

## Challenge 3: Nexus Disk Space

**Problem:** Nexus filled 30GB disk in 2 weeks!

**Solution:**
1. **Nexus → Settings → Cleanup Policies**
2. Create policy:
   ```yaml
   Name: cleanup-old-artifacts
   Criteria:
     - Component Age: 30 days
     - Last Downloaded: 60 days
   ```
3. Apply to `npm-hosted` repository

## Challenge 4: ECR Push Failures

**Problem:** Intermittent "denied: Your Authorization Token has expired"

**Solution:**
```groovy
// Re-authenticate before each push
def ecrLogin = sh(
    script: 'aws ecr get-login-password --region ap-south-1',
    returnStdout: true
).trim()

sh """
    echo ${ecrLogin} | docker login \
        --username AWS \
        --password-stdin \
        381492102582.dkr.ecr.ap-south-1.amazonaws.com
"""
```

---

# 🎯 What's Next? Day 2 Preview

Tomorrow, we'll take these Docker images and deploy them to **Kubernetes** using:

- ✅ **Helm Charts** for templating
- ✅ **ArgoCD** for GitOps
- ✅ **Argo Rollouts** for progressive delivery
- ✅ **Canary deployments** with automatic rollback
- ✅ **Service mesh** with Istio

**Plus:** Monitoring with Prometheus & Grafana!

---

# 📚 Complete Resource List

## Official Documentation
- [Jenkins Pipeline Docs](https://www.jenkins.io/doc/book/pipeline/)
- [SonarQube Quality Gates](https://docs.sonarqube.org/latest/user-guide/quality-gates/)
- [Snyk CLI Reference](https://docs.snyk.io/snyk-cli)
- [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/)
- [Docker Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [AWS ECR User Guide](https://docs.aws.amazon.com/ecr/)

## Security Tools
- [Gitleaks GitHub](https://github.com/gitleaks/gitleaks)
- [Dockle GitHub](https://github.com/goodwithtech/dockle)
- [Syft GitHub](https://github.com/anchore/syft)
- [Snyk Website](https://snyk.io/)
- [NVD API](https://nvd.nist.gov/developers)

## My GitHub Repository
- [7-Day DevSecOps MasterClass](https://github.com/17J/7-Day-DevSecOps-MasterClass)
  - Day-1 code and scripts
  - Jenkinsfile
  - Dockerfiles
  - Complete setup guides

---

# 🤝 Let's Connect & Learn Together!

## Did This Help You?

If you found this guide valuable:
- 👏 **Clap for this article** (you can clap up to 50 times!)
- 💬 **Comment** with your questions or experiences
- 🔗 **Share** with your DevSecOps network
- 👤 **Follow** me for Day 2 tomorrow at 10 PM IST

## Questions? I'm Here to Help!

Drop your questions in the comments. I reply to every single one! Common questions I can already help with:

**Q: Can I use this in production?**  
A: Yes! But add monitoring, logging, and disaster recovery first (covered in Days 3-5).

**Q: What if I don't have AWS?**  
A: Use GCP Container Registry or Azure Container Registry. The concepts are identical.

**Q: My build fails at X stage. Help?**  
A: Comment below with the error message, and I'll troubleshoot with you!

## Your Homework Before Day 2

- ✅ Get your pipeline green (all stages passing)
- ✅ Fix at least 5 Critical/High vulnerabilities
- ✅ Increase code coverage to at least 50%
- ✅ Set up email notifications for build failures

## Share Your Progress!

Tweet your pipeline screenshot with:
```
#DevSecOps #7DayChallenge #Day1Complete
@17J
```

I'll retweet the best ones! 🚀

---

# 🏆 Achievement Unlocked!

**You've successfully:**
- ✅ Built a complete DevSecOps CI pipeline
- ✅ Integrated 6 security tools
- ✅ Configured Jenkins with 5 credentials
- ✅ Set up SonarQube quality gates
- ✅ Created Nexus artifact repository
- ✅ Pushed secure images to AWS ECR
- ✅ Implemented break-the-build logic
- ✅ Generated SBOM for compliance

**Total Lines of Configuration:** ~500  
**Security Tools Mastered:** 6  
**Time Invested:** 2-3 hours  
**Value Created:** Priceless! 🎉

---

*This is Part 1 of my 7-Day DevSecOps MasterClass series.*

**Tomorrow at 10 PM IST:** [Day 2 - Kubernetes & GitOps Deployment →](#)

**Follow the series:**
- Day 1: CI Pipeline + Shift-Left Security ✅ (You are here!)
- Day 2: Kubernetes & GitOps (Tomorrow!)
- Day 3: Monitoring & Observability
- Day 4: Runtime Security
- Day 5: Infrastructure as Code Security
- Day 6: Incident Response Automation
- Day 7: Compliance & Governance

---

**Tags:** #DevSecOps #CI/CD #Jenkins #Docker #Security #AWS #Kubernetes #DevOps #CloudSecurity #ShiftLeft #SonarQube #Snyk #OWASP #GitOps #Tutorial

---

**Author:** [17J](https://github.com/17J)  
**Date:** January 30, 2026  
**Reading Time:** 25 minutes  
**Skill Level:** Intermediate  

---

*All code and configurations available at:*  
🔗 **https://github.com/17J/7-Day-DevSecOps-MasterClass**

**Star the repo if this helped you!** ⭐