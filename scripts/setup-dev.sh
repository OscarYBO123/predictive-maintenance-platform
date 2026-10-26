#!/usr/bin/env bash
# =============================================================================
# setup-dev.sh — Development environment for the predictive maintenance project
#
# Installs: base utilities, Git, Java 25 (JDK), Maven, Node.js LTS (via nvm),
#           Angular CLI, Docker Engine + Docker Compose, and VS Code (optional).
#
# Usage:
#   chmod +x scripts/setup-dev.sh
#   ./scripts/setup-dev.sh
#
# Safe to run more than once: anything already installed is skipped.
# =============================================================================
set -euo pipefail

# ---------- Output helpers ----------
info()  { printf "\n\033[1;34m==> %s\033[0m\n" "$*"; }
ok()    { printf "\033[1;32m    ✔ %s\033[0m\n" "$*"; }
warn()  { printf "\033[1;33m    ! %s\033[0m\n" "$*"; }

if [[ $EUID -eq 0 ]]; then
  echo "Do not run this script with sudo; it will ask for your password when needed."
  exit 1
fi

. /etc/os-release
info "Detected system: ${PRETTY_NAME}"

# ---------- 1. Base utilities ----------
info "1/7 Updating packages and installing base utilities"
sudo apt-get update -y
sudo apt-get install -y \
  curl wget git unzip zip ca-certificates gnupg build-essential jq tree
ok "Base utilities ready"

# ---------- 2. Git ----------
info "2/7 Configuring Git"
if [[ -z "$(git config --global user.name || true)" ]]; then
  read -rp "    Your name for commits (e.g. Oscar Bautista): " GIT_NAME
  git config --global user.name "$GIT_NAME"
fi
if [[ -z "$(git config --global user.email || true)" ]]; then
  read -rp "    Your email (the same as your GitHub account): " GIT_EMAIL
  git config --global user.email "$GIT_EMAIL"
fi
git config --global init.defaultBranch main
git config --global pull.rebase false
ok "Git configured as: $(git config --global user.name) <$(git config --global user.email)>"

# ---------- 3. Java 25 ----------
info "3/7 Installing Java 25 (JDK)"
if java -version 2>&1 | grep -q 'version "25'; then
  ok "Java 25 was already installed"
elif sudo apt-get install -y openjdk-25-jdk; then
  ok "Java 25 installed from the Ubuntu repositories"
else
  warn "openjdk-25-jdk is not in your repositories; using Eclipse Temurin (Adoptium)"
  wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public \
    | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
  echo "deb https://packages.adoptium.net/artifactory/deb ${VERSION_CODENAME} main" \
    | sudo tee /etc/apt/sources.list.d/adoptium.list > /dev/null
  sudo apt-get update -y
  sudo apt-get install -y temurin-25-jdk
  ok "Java 25 (Temurin) installed"
fi

JAVA_BIN="$(readlink -f "$(command -v java)")"
JAVA_HOME_DIR="$(dirname "$(dirname "$JAVA_BIN")")"
if ! grep -q "JAVA_HOME" "$HOME/.bashrc"; then
  {
    echo ""
    echo "# Java"
    echo "export JAVA_HOME=\"${JAVA_HOME_DIR}\""
  } >> "$HOME/.bashrc"
fi
ok "JAVA_HOME=${JAVA_HOME_DIR}"

# ---------- 4. Maven ----------
info "4/7 Installing Maven"
sudo apt-get install -y maven
ok "Maven installed (projects also use the Maven Wrapper ./mvnw)"

# ---------- 5. Node.js LTS + Angular CLI ----------
info "5/7 Installing Node.js LTS with nvm and Angular CLI"
export NVM_DIR="$HOME/.nvm"
if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  NVM_TAG="$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r .tag_name)"
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_TAG}/install.sh" | bash
fi
# nvm is not compatible with strict mode (set -eu), so we disable it
# only while using nvm and restore it afterwards.
set +eu
# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'
set -eu
npm install -g @angular/cli
ok "Node $(node -v), npm $(npm -v), Angular CLI installed"

# ---------- 6. Docker Engine + Compose ----------
info "6/7 Installing Docker Engine and Docker Compose"
if command -v docker > /dev/null 2>&1; then
  ok "Docker was already installed"
else
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME:-$VERSION_CODENAME} stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin
  ok "Docker installed"
fi
sudo usermod -aG docker "$USER"
ok "Your user was added to the docker group (takes effect after logging out and back in)"

# ---------- 7. Editor (optional) ----------
info "7/7 Code editor"
if command -v code > /dev/null 2>&1; then
  ok "VS Code was already installed"
else
  read -rp "    Install VS Code? [Y/n]: " WANT_CODE
  if [[ "${WANT_CODE:-S}" =~ ^[SsYy]$ ]]; then
    sudo snap install code --classic
    ok "VS Code installed"
  else
    warn "Skipped. You can use IntelliJ IDEA if you prefer."
  fi
fi

# ---------- Summary ----------
info "Version summary"
echo "    Git:        $(git --version)"
echo "    Java:       $(java -version 2>&1 | head -n 1)"
echo "    Maven:      $(mvn -v 2>/dev/null | head -n 1)"
echo "    Node:       $(node -v)"
echo "    npm:        $(npm -v)"
echo "    Angular:    $(ng version 2>/dev/null | grep -m1 -i 'angular cli' || echo 'installed')"
echo "    Docker:     $(docker --version)"
echo "    Compose:    $(docker compose version)"

printf "\n\033[1;32mDone.\033[0m Log out and back in (or reboot) to use Docker without sudo.\n"
printf "Then run:  docker run hello-world\n\n"
