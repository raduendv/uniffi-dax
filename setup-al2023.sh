set -eo pipefail

sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y libicu unzip zip

if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi
if ! command -v rustup >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
    . "$HOME/.cargo/env"
fi
rustup default stable
rustup target add wasm32-unknown-unknown

export PATH="$HOME/.local/bin:$PATH"
if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

if [ ! -s "$HOME/.gvm/scripts/gvm" ]; then
    curl -s -o- https://raw.githubusercontent.com/moovweb/gvm/HEAD/binscripts/gvm-installer | bash
fi
. "$HOME/.gvm/scripts/gvm" || true
if [ ! -d "$HOME/.gvm/gos/go1.26.0" ]; then
    gvm install go1.26.0 -B
fi
gvm use go1.26.0 --default

export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
. "$NVM_DIR/nvm.sh" || true
nvm install 24
nvm alias default 24
nvm use 24

if [ ! -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    curl -s "https://get.sdkman.io" | bash
fi
. "$HOME/.sdkman/bin/sdkman-init.sh" || true
sdk install java 21.0.2-open || true
sdk default java 21.0.2-open
sdk install maven 3.9.11 || true
sdk default maven 3.9.11

mkdir -p "$HOME/.local/bin"
GOBIN="$HOME/.local/bin" go install github.com/asdf-vm/asdf/cmd/asdf@v0.20.2
export ASDF_DATA_DIR="$HOME/.asdf"
export PATH="$HOME/.local/bin:$ASDF_DATA_DIR/shims:$PATH"
asdf plugin add kotlin || true
asdf install kotlin 1.9.22
asdf set -u kotlin 1.9.22

export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"
if [ ! -x "$DOTNET_ROOT/dotnet" ]; then
    curl -LsSf https://dot.net/v1/dotnet-install.sh -o "$HOME/.local/bin/dotnet-install.sh"
    bash "$HOME/.local/bin/dotnet-install.sh" --version 8.0.405 --install-dir "$DOTNET_ROOT"
fi
