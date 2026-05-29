#!/usr/bin/env bash
#
# install.sh — sets up a patched Conduit (IR-only) on macOS or Linux.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/adpunt/conduit-ir-patch/main/install.sh | bash
#
# Or download and read it first (recommended), then:
#   bash install.sh
#
# This script:
#   1. Installs Go 1.24, git, and a C compiler if missing.
#   2. Clones the conduit-ir fork (ir-only branch) into ~/repos/conduit-ir.
#   3. Runs "make setup", which pulls the patched tunnel-core fork.
#   4. Builds the binary and confirms the IR-only restriction is in it.
#
# The IR-only restriction lives in the fork, not in this script: the
# ir-only branch of github.com/adpunt/conduit-ir builds against the
# ir-only branch of github.com/adpunt/psiphon-tunnel-core, which is
# upstream Psiphon plus one 8-line change (see ir-only.patch). There is
# no separate patch step anymore.
#
# It does NOT install a Psiphon config file. You still have to obtain one.
# It does NOT start the proxy. The script prints instructions when it's done.
#
# Safe to re-run.

set -euo pipefail

CONDUIT_REPO="https://github.com/adpunt/conduit-ir.git"
CONDUIT_BRANCH="ir-only"
REPOS_DIR="${HOME}/repos"
CONDUIT_DIR="${REPOS_DIR}/conduit-ir"

bold()  { printf "\033[1m%s\033[0m\n" "$*"; }
say()   { printf "  %s\n" "$*"; }
ok()    { printf "  \033[32m✓\033[0m %s\n" "$*"; }
warn()  { printf "  \033[33m!\033[0m %s\n" "$*"; }
fail()  { printf "  \033[31m✗\033[0m %s\n" "$*" >&2; exit 1; }

case "$(uname -s)" in
  Darwin) OS="macos" ;;
  Linux)  OS="linux" ;;
  *)      fail "Unsupported OS: $(uname -s). This script supports macOS and Linux (including WSL2)." ;;
esac

case "$(uname -m)" in
  x86_64|amd64) ARCH="amd64" ;;
  arm64|aarch64) ARCH="arm64" ;;
  *) fail "Unsupported CPU architecture: $(uname -m)." ;;
esac

bold "Detected: ${OS} / ${ARCH}"
echo

# ----- 1. Install tools -----
bold "Step 1/4: Checking tools..."

install_go_124_linux() {
  local url="https://go.dev/dl/go1.24.13.linux-${ARCH}.tar.gz"
  say "Downloading Go 1.24.13 from go.dev..."
  curl -fsSL "$url" -o /tmp/go-1.24.tar.gz
  say "Installing to /usr/local/go (will ask for your password)..."
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf /tmp/go-1.24.tar.gz
  rm /tmp/go-1.24.tar.gz
  if ! grep -q "/usr/local/go/bin" "${HOME}/.bashrc" 2>/dev/null; then
    echo 'export PATH=$PATH:/usr/local/go/bin' >> "${HOME}/.bashrc"
  fi
  export PATH="$PATH:/usr/local/go/bin"
}

if [ "$OS" = "macos" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    fail "Homebrew is not installed. Install it from https://brew.sh first, then re-run this script."
  fi
  ok "Homebrew is installed"

  if command -v go >/dev/null 2>&1 && go version | grep -qE "go1\.24\."; then
    ok "Go 1.24.x is installed ($(go version | awk '{print $3}'))"
  else
    say "Installing Go 1.24 via Homebrew..."
    brew install go@1.24 >/dev/null
    brew unlink go >/dev/null 2>&1 || true
    brew link --force go@1.24 >/dev/null
    ok "Installed $(go version | awk '{print $3}')"
  fi

  if command -v git >/dev/null 2>&1; then
    ok "git is installed"
  else
    say "Installing git..."
    brew install git >/dev/null
    ok "git installed"
  fi

else  # linux / wsl2
  say "On Linux/WSL2 the script needs sudo to install system packages."
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq
    sudo apt-get install -y -qq git make build-essential curl
    ok "apt packages installed (git, make, build-essential, curl)"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y -q git make gcc curl
    ok "dnf packages installed (git, make, gcc, curl)"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm --needed git make gcc curl
    ok "pacman packages installed (git, make, gcc, curl)"
  else
    fail "Could not detect your Linux package manager (apt, dnf, or pacman). Please install git, make, gcc, and curl manually, then re-run."
  fi

  if command -v go >/dev/null 2>&1 && go version | grep -qE "go1\.24\."; then
    ok "Go 1.24.x is installed ($(go version | awk '{print $3}'))"
  else
    install_go_124_linux
    ok "Installed $(go version | awk '{print $3}')"
  fi
fi
echo

# ----- 2. Clone the conduit-ir fork (ir-only branch) -----
bold "Step 2/4: Cloning the conduit-ir fork (ir-only branch)..."
mkdir -p "$REPOS_DIR"
if [ -d "$CONDUIT_DIR/.git" ]; then
  say "Already cloned — making sure it's on the ir-only branch and up to date..."
  cd "$CONDUIT_DIR"
  git fetch --quiet origin "$CONDUIT_BRANCH"
  git checkout --quiet -B "$CONDUIT_BRANCH" "origin/$CONDUIT_BRANCH"
  ok "conduit-ir ready at $CONDUIT_DIR ($CONDUIT_BRANCH)"
else
  git clone --quiet --branch "$CONDUIT_BRANCH" "$CONDUIT_REPO" "$CONDUIT_DIR"
  ok "Cloned $CONDUIT_BRANCH to $CONDUIT_DIR"
fi
echo

# ----- 3. make setup (pulls the patched tunnel-core fork) -----
bold "Step 3/4: Pulling the patched tunnel-core fork (this can take a few minutes)..."
cd "$CONDUIT_DIR/cli"
# 'make setup' clones adpunt/psiphon-tunnel-core@ir-only (set in the Makefile)
# into ./psiphon-tunnel-core and runs 'go mod tidy'. Re-running refreshes it.
make setup
ok "tunnel-core (ir-only) ready"
echo

# ----- 4. Build + verify the restriction is really in it -----
bold "Step 4/4: Building (this can take a minute or two)..."
cd "$CONDUIT_DIR/cli"
make build >/dev/null
BIN="$CONDUIT_DIR/cli/dist/conduit"
if [ ! -x "$BIN" ]; then
  fail "Build appeared to succeed but no binary at $BIN — please report this."
fi

# Safety check: confirm the IR-only restriction is actually compiled in.
# This is a censorship-circumvention tool for people in Iran; a build that
# silently lost the restriction would serve the whole world, so fail loudly.
PROXY="$CONDUIT_DIR/cli/psiphon-tunnel-core/psiphon/common/inproxy/proxy.go"
if ! grep -q "IR-only allowlist" "$PROXY"; then
  fail "IR-only restriction NOT found in tunnel-core source. Refusing to trust this build. Please report this."
fi
# Use grep -c (not grep -q): grep -q exits on the first match and closes the
# pipe, which makes `strings` die with SIGPIPE and trips `set -o pipefail`,
# producing a false negative. grep -c reads the whole stream.
marker_count="$(strings "$BIN" 2>/dev/null | grep -c "client region not allowed" || true)"
if [ "${marker_count:-0}" -lt 1 ]; then
  warn "Could not confirm the IR-only marker inside the binary (strings unavailable?). Source check passed, but double-check before relying on it."
fi
ok "Built: $BIN  (IR-only restriction confirmed)"
echo

# ----- Done -----
bold "✓ All set."
cat <<EOF

Your patched Conduit is built at:
  ${BIN}

Two things left to do — both manual:

  1. Get a Psiphon config file. Email conduit-oss@psiphon.ca and ask for
     a config to run Conduit from source. Save the file they send you as:
       ${CONDUIT_DIR}/cli/dist/psiphon_config.json

  2. Run it:
       cd ${CONDUIT_DIR}/cli/dist
       ./conduit start -c psiphon_config.json -m 10 -b 20

     -m 10 = at most 10 simultaneous users    (start small, raise later)
     -b 20 = at most 20 Mbps total bandwidth  (use -b -1 for unlimited)

  Stop the proxy at any time with Ctrl-C.

For more details and what to expect in the logs, see the README:
  https://github.com/adpunt/conduit-ir-patch
EOF
