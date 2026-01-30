pipeline {
    agent any
    
    tools {
        nodejs "nodejs-23.10.0"          // Node.js version configured in Jenkins Global Tools
        snyk "snyk"                      // Snyk CLI configured in Jenkins tools
    }
    
    environment {
        SCANNER_HOME = tool 'sonar-scanner'  // SonarQube scanner path from Jenkins tools
        FRONTEND_IMAGE_NAME = 'frontend-ecommerce-mern'
        BACKEND_IMAGE_NAME = 'backend-ecommerce-mern'
        IMAGE_TAG = "${BUILD_NUMBER}"        // Use Jenkins build number as image tag
        ECR_REGISTRY = '381492102582.dkr.ecr.ap-south-1.amazonaws.com'
        ECR_REPO_PREFIX = 'ecom'
    }
    
    stages {
        stage('Initial Checks') {
            steps {
                // Clean workspace and checkout the latest code from main branch
                cleanWs()
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/17J/GitOps-Ecom-CI.git'
                
                // Scan for leaked secrets/credentials using Gitleaks (non-blocking)
                sh 'gitleaks detect --no-git --verbose --redact --exit-code 0 --report-format json --report-path gitleaks-report.json'
            }
        }
        
        stage('Security & Syntax') {
            steps {
                script {
                    parallel(
                        "Frontend": {
                            dir('client') {
                                // Basic syntax check for JS/TS/JSX/TSX files (non-blocking)
                                sh 'find . -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" | xargs -I {} node --check {} || true'
                                
                                // Authenticate Snyk and scan frontend dependencies for high+ severity vulns
                                withCredentials([string(credentialsId: 'snyk-cred', variable: 'SNYK_TOKEN')]) {
                                    sh 'snyk auth $SNYK_TOKEN && snyk test --severity-threshold=high --json-file-output=snyk-frontend.json || true'
                                }
                            }
                        },
                        "Backend": {
                            dir('server') {
                                // Basic syntax check for JS/TS files (non-blocking)
                                sh 'find . -name "*.js" -o -name "*.ts" | xargs -I {} node --check {} || true'
                                
                                // Authenticate Snyk and scan backend dependencies for high+ severity vulns
                                withCredentials([string(credentialsId: 'snyk-cred', variable: 'SNYK_TOKEN')]) {
                                    sh 'snyk auth $SNYK_TOKEN && snyk test --severity-threshold=high --json-file-output=snyk-backend.json || true'
                                }
                            }
                        }
                    )
                }
            }
        }
        
        stage('Build & Unit Tests') {
            steps {
                script {
                    parallel(
                        "Frontend": {
                            dir('client') {
                                // Install dependencies and run unit tests with coverage (non-watch mode)
                                sh 'npm install && npm run test -- --coverage --watchAll=false --passWithNoTests'
                            }
                        },
                        "Backend": {
                            dir('server') {
                                // Install dependencies and run unit tests with coverage (non-watch mode)
                                sh 'npm install && npm run test -- --coverage --watchAll=false --passWithNoTests'
                            }
                        }
                    )
                }
            }
        }
        
        stage('SonarQube & Nexus') {
            steps {
                // Perform static code analysis with SonarQube (sources + coverage reports)
                withSonarQubeEnv('sonar') {
                    sh "$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectKey=gitops-pipeline -Dsonar.sources=client/src,server/ -Dsonar.exclusions=**/node_modules/**,**/coverage/**,**/dist/** -Dsonar.javascript.lcov.reportPaths=client/coverage/lcov.info,server/coverage/lcov.info"
                }
                
                // Wait for SonarQube quality gate result (timeout 10 min, blocking failure)
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
               
                // Publish packages to Nexus Repository (using temp .npmrc from config file)
                withCredentials([usernamePassword(credentialsId: 'nexus-auth-id', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    configFileProvider([configFile(fileId: 'npmrc-nexus-config', variable: 'NPMRC_TMP')]) {
                        script {
                            def encoded = "${USER}:${PASS}".bytes.encodeBase64().toString()
                            parallel(
                                "Nexus-Frontend": {
                                    dir('client') {
                                        sh "cp ${NPMRC_TMP} .npmrc"
                                        withEnv(["NPM_AUTH=${encoded}"]) {
                                            sh 'npm publish || true'  // Non-blocking publish
                                        }
                                    }
                                },
                                "Nexus-Backend": {
                                    dir('server') {
                                        sh "cp ${NPMRC_TMP} .npmrc"
                                        withEnv(["NPM_AUTH=${encoded}"]) {
                                            sh 'npm publish || true'  // Non-blocking publish
                                        }
                                    }
                                }
                            )
                        }
                    }
                }
            }
        }
        
        stage('Docker & SCA') {
            steps {
                // Login to AWS ECR using AWS credentials
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred']]) {
                    sh "aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                    
                    script {
                        parallel(
                            "Frontend Ops": {
                                // Build, lint (Dockle), generate SBOM (Syft), and push frontend Docker image
                                sh "docker build -t ${ECR_REGISTRY}/${ECR_REPO_PREFIX}/${FRONTEND_IMAGE_NAME}:${IMAGE_TAG} --file client/Dockerfile ./client"
                                sh "dockle --exit-code 0 --format json -o dockle-frontend.json ${ECR_REGISTRY}/${ECR_REPO_PREFIX}/${FRONTEND_IMAGE_NAME}:${IMAGE_TAG} || true"
                                sh "syft ${ECR_REGISTRY}/${ECR_REPO_PREFIX}/${FRONTEND_IMAGE_NAME}:${IMAGE_TAG} -o cyclonedx-json > sbom-frontend.json"
                                sh "docker push ${ECR_REGISTRY}/${ECR_REPO_PREFIX}/${FRONTEND_IMAGE_NAME}:${IMAGE_TAG}"
                            },
                            "Backend Ops": {
                                // Build, lint (Dockle), generate SBOM (Syft), and push backend Docker image
                                sh "docker build -t ${ECR_REGISTRY}/${ECR_REPO_PREFIX}/${BACKEND_IMAGE_NAME}:${IMAGE_TAG} --file server/Dockerfile ./server"
                                sh "dockle --exit-code 0 --format json -o dockle-backend.json ${ECR_REGISTRY}/${ECR_REPO_PREFIX}/${BACKEND_IMAGE_NAME}:${IMAGE_TAG} || true"
                                sh "syft ${ECR_REGISTRY}/${ECR_REPO_PREFIX}/${BACKEND_IMAGE_NAME}:${IMAGE_TAG} -o cyclonedx-json > sbom-backend.json"
                                sh "docker push ${ECR_REGISTRY}/${ECR_REPO_PREFIX}/${BACKEND_IMAGE_NAME}:${IMAGE_TAG}"
                            }
                        )
                    }
                }
            }
        }
        
        stage('Final Security Scan') {
            steps {
                parallel(
                    "Frontend ODC": {
                        dir('client') {
                            // Run OWASP Dependency-Check for frontend (using NVD API key)
                            withCredentials([string(credentialsId: 'nvd-api-key', variable: 'NVD_API_KEY')]) {
                                dependencyCheck additionalArguments: "--nvdApiKey ${NVD_API_KEY} --format HTML --scan ./ --project frontend", odcInstallation: 'owasp'
                            }
                        }
                    },
                    "Backend ODC": {
                        dir('server') {
                            // Run OWASP Dependency-Check for backend (using NVD API key)
                            withCredentials([string(credentialsId: 'nvd-api-key', variable: 'NVD_API_KEY')]) {
                                dependencyCheck additionalArguments: "--nvdApiKey ${NVD_API_KEY} --format HTML --scan ./ --project backend", odcInstallation: 'owasp'
                            }
                        }
                    }
                )
            }
        }
    }
   
    post {
        always {
            // Archive all security reports, SBOMs, and dependency-check HTML reports
            archiveArtifacts artifacts: '''
                gitleaks-report.json,
                client/snyk-frontend.json,
                server/snyk-backend.json,
                dockle-frontend.json,
                dockle-backend.json,
                **/sbom-*.json,
                **/dependency-check-report.html
            ''', allowEmptyArchive: true
            
            // Clean up local Docker images to save space
            sh "docker rmi ${FRONTEND_IMAGE_NAME}:${IMAGE_TAG} ${BACKEND_IMAGE_NAME}:${IMAGE_TAG} || true"
            
            // Clean workspace after pipeline completion
            cleanWs()
        }
    }
} 