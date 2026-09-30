set -eo pipefail

. "$HOME/.cargo/env"
. "$HOME/.gvm/scripts/gvm" || true
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh" || true
. "$HOME/.sdkman/bin/sdkman-init.sh" || true
export ASDF_DATA_DIR="$HOME/.asdf"
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$HOME/.local/bin:$ASDF_DATA_DIR/shims:$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"
export CARGO_BUILD_JOBS="${CARGO_BUILD_JOBS:-2}"
export CARGO_PROFILE_DEV_DEBUG=0

make run-examples
