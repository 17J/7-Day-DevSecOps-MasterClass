#!/usr/bin/env bash
set -euo pipefail

echo "============================================================="
echo "  Installing SonarQube + Trivy + Gitleaks + Nexus + Syft"
echo "  (x86-64 / amd64 architecture - Ubuntu/Debian compatible)"
echo "============================================================="

# ───────────────────────────────────────────────
# 1. SonarQube (with Community Branch Plugin)
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
echo "Default credentials: admin / admin (change password on first login)"

# ───────────────────────────────────────────────
# 2. Trivy (vulnerability scanner)
# ───────────────────────────────────────────────
echo ""
echo "→ Installing Dockle..."

sudo apt-get update -qq
VERSION=$(curl --silent "https://api.github.com/repos/goodwithtech/dockle/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
curl -L -o dockle.deb https://github.com/goodwithtech/dockle/releases/download/v${VERSION}/dockle_${VERSION}_Linux-64bit.deb
sudo dpkg -i dockle.deb
rm dockle.deb


dockle --version | head -n 1
echo "Dcckle installed ✓"

# ───────────────────────────────────────────────
# 3. Gitleaks (secrets scanner) - latest for x86-64
# ───────────────────────────────────────────────
echo ""
echo "→ Installing latest Gitleaks (amd64)..."

GITLEAKS_VERSION=$(curl -s "https://api.github.com/repos/gitleaks/gitleaks/releases/latest" \
  | grep -Po '"tag_name": "\K[^"]+' | sed 's/^v//')

if [[ -z "$GITLEAKS_VERSION" ]]; then
  echo "Error: Could not fetch latest Gitleaks version"
  exit 1
fi

echo "Latest version: v${GITLEAKS_VERSION}"

wget -q "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" \
  -O gitleaks.tar.gz

sudo tar xf gitleaks.tar.gz -C /usr/local/bin gitleaks
sudo chmod +x /usr/local/bin/gitleaks

gitleaks version

rm -f gitleaks.tar.gz
echo "Gitleaks installed ✓"

# ───────────────────────────────────────────────
# 4. Sonatype Nexus Repository OSS (Docker)
# ───────────────────────────────────────────────
echo ""
echo "→ Installing Sonatype Nexus Repository OSS via Docker..."

docker stop nexus >/dev/null 2>&1 || true
docker rm nexus >/dev/null 2>&1 || true

docker pull sonatype/nexus3:latest

docker run -d \
  --name nexus \
  -p 8081:8081 \
  -v nexus-data:/nexus-data \
  sonatype/nexus3:latest

echo "Nexus is starting → http://localhost:8081"
echo "Default username: admin"

echo -n "→ Waiting 30 seconds for Nexus to initialize and generate admin password..."
sleep 30
echo " done"

if docker exec nexus test -f /nexus-data/admin.password; then
  echo "Initial admin password:"
  docker exec nexus cat /nexus-data/admin.password
  echo "(Use this password to log in → you will be forced to change it immediately)"
else
  echo "Warning: admin.password file not found yet."
  echo "Try again in 1-2 minutes with: docker exec nexus cat /nexus-data/admin.password"
  echo "Or check container logs: docker logs nexus"
fi

# ───────────────────────────────────────────────
# 5. Syft (SBOM generator from Anchore)
# ───────────────────────────────────────────────
echo ""
echo "→ Installing Syft (SBOM tool)..."

curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

if command -v syft >/dev/null 2>&1; then
  syft --version
  echo "Syft installed successfully ✓"
else
  echo "Warning: Syft installation may have failed. Check the curl output above."
fi

# ───────────────────────────────────────────────
# Final summary
# ───────────────────────────────────────────────
echo ""
echo "============================================================="
echo "               Installation Complete!"
echo ""
echo "Tools installed:"
echo "  • SonarQube          → http://localhost:9000          (admin / admin)"
echo "  • Trivy              → container/image vulnerability scanner"
echo "  • Gitleaks           → secrets/credential scanner"
echo "  • Nexus Repository   → http://localhost:8081           (admin / [generated password])"
echo "  • Syft               → SBOM generator"
echo ""
echo "Quick test commands:"
echo "  trivy image alpine:3.18"
echo "  gitleaks detect --source . --redact"
echo "  syft alpine:3.18               # generate SBOM"
echo "  curl -s localhost:8081         # check Nexus is responding"
echo "============================================================="