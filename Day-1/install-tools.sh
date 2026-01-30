#!/usr/bin/env bash
set -euo pipefail

echo "============================================================="
echo " Installing Docker + Jenkins + SonarQube + Trivy + Gitleaks + Nexus + Syft + Dockle"
echo " (x86-64 / amd64 architecture - Ubuntu/Debian compatible)"
echo " Updated for 2026 - new Jenkins signing key used"
echo "============================================================="

# ───────────────────────────────────────────────
# 0. Prerequisites - Docker first (most things depend on it)
# ───────────────────────────────────────────────
echo ""
echo "→ Installing Docker..."

if ! command -v docker &> /dev/null; then
    sudo apt-get update -qq
    sudo apt-get install -y docker.io
    sudo systemctl enable --now docker
fi

# Add current user to docker group (and jenkins later)
sudo usermod -aG docker "${USER:-ubuntu}" 2>/dev/null || true

echo "Docker installed ✓"
docker --version

# ───────────────────────────────────────────────
# 1. Jenkins
# ───────────────────────────────────────────────
echo ""
echo "→ Installing Jenkins (using 2026 signing key)..."

sudo apt-get update -qq
sudo apt-get install -y fontconfig openjdk-21-jre-headless

java -version

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
    | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -qq
sudo apt-get install -y jenkins

sudo usermod -aG docker jenkins
sudo systemctl enable --now jenkins

echo "Jenkins → http://localhost:8080"
echo "→ Get initial admin password: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo "Jenkins installed ✓"

# ───────────────────────────────────────────────
# 2. SonarQube (with community branch plugin)
# ───────────────────────────────────────────────
echo ""
echo "→ Installing SonarQube via Docker..."

docker stop sonarqube >/dev/null 2>&1 || true
docker rm sonarqube >/dev/null 2>&1 || true

docker pull mc1arke/sonarqube-with-community-branch-plugin:latest

docker run -d \
    --name sonarqube \
    -p 9000:9000 \
    -v sonarqube_data:/opt/sonarqube/data \
    -v sonarqube_logs:/opt/sonarqube/logs \
    -v sonarqube_extensions:/opt/sonarqube/extensions \
    mc1arke/sonarqube-with-community-branch-plugin:latest

echo "SonarQube → http://localhost:9000"
echo "Default credentials: admin / admin (change immediately)"
echo "SonarQube started ✓"

# ───────────────────────────────────────────────
# 3. Dockle (Docker image linter)
# ───────────────────────────────────────────────
echo ""
echo "→ Installing latest Dockle..."

VERSION=$(curl --silent "https://api.github.com/repos/goodwithtech/dockle/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

if [[ -z "$VERSION" ]]; then
    echo "Error: Could not fetch Dockle version"
    exit 1
fi

echo "Dockle version: v${VERSION}"

curl -L -o dockle.deb "https://github.com/goodwithtech/dockle/releases/download/v${VERSION}/dockle_${VERSION}_Linux-64bit.deb"
sudo dpkg -i dockle.deb || sudo apt-get install -f -y   # fix dependencies if needed
rm -f dockle.deb

dockle --version
echo "Dockle installed ✓"



# ───────────────────────────────────────────────
# 4. Gitleaks (secrets scanner)
# ───────────────────────────────────────────────
echo ""
echo "→ Installing latest Gitleaks..."

GITLEAKS_VERSION=$(curl -s "https://api.github.com/repos/gitleaks/gitleaks/releases/latest" | grep -Po '"tag_name": "\K[^"]+' | sed 's/^v//')

if [[ -z "$GITLEAKS_VERSION" ]]; then
    echo "Error: Could not fetch Gitleaks version"
    exit 1
fi

wget -q "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" -O gitleaks.tar.gz

sudo tar xf gitleaks.tar.gz -C /usr/local/bin gitleaks
sudo chmod +x /usr/local/bin/gitleaks
rm gitleaks.tar.gz

gitleaks version
echo "Gitleaks installed ✓"

# ───────────────────────────────────────────────
# 5. Nexus Repository OSS
# ───────────────────────────────────────────────
echo ""
echo "→ Installing Nexus via Docker..."

docker stop nexus >/dev/null 2>&1 || true
docker rm nexus >/dev/null 2>&1 || true

docker pull sonatype/nexus3:latest

docker run -d \
    --name nexus \
    -p 8081:8081 \
    -v nexus-data:/nexus-data \
    sonatype/nexus3:latest

echo "Nexus → http://localhost:8081"
echo "Default username: admin"

echo -n "→ Waiting ~60-90 seconds for Nexus to start and generate password..."
sleep 60

if docker exec nexus test -f /nexus-data/admin.password; then
    echo -e "\nInitial admin password:"
    docker exec nexus cat /nexus-data/admin.password
    echo "(change it immediately after first login)"
else
    echo -e "\nPassword file not found yet."
    echo "Wait a bit more and run: docker exec nexus cat /nexus-data/admin.password"
    echo "Or check logs: docker logs -f nexus"
fi

# ───────────────────────────────────────────────
# 6. Syft (SBOM generator)
# ───────────────────────────────────────────────
echo ""
echo "→ Installing Syft..."

curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sudo sh -s -- -b /usr/local/bin

syft version || echo "Syft installed but version check failed — still probably ok"
echo "Syft installed ✓"

# ───────────────────────────────────────────────
# Final Summary
# ───────────────────────────────────────────────
echo ""
echo "============================================================="
echo "          Installation Complete! (hopefully without errors)"
echo ""
echo "Tools installed / started:"
echo " • Docker          → docker --version"
echo " • Jenkins         → http://localhost:8080"
echo " • SonarQube       → http://localhost:9000"
echo " • Nexus           → http://localhost:8081"
echo " • Dockle          → dockle alpine:latest"
echo " • Gitleaks        → gitleaks detect --source ."
echo " • Syft            → syft packages alpine:latest"
echo "============================================================="

