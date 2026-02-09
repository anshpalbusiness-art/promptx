#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$ROOT_DIR/docker-compose.yml"
EXTRA_COMPOSE_FILE="$ROOT_DIR/docker-compose.extra.yml"
IMAGE_NAME="${PROMPTX_IMAGE:-promptx:local}"
EXTRA_MOUNTS="${PROMPTX_EXTRA_MOUNTS:-}"
HOME_VOLUME_NAME="${PROMPTX_HOME_VOLUME:-}"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing dependency: $1" >&2
    exit 1
  fi
}

require_cmd docker
if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose not available (try: docker compose version)" >&2
  exit 1
fi

PROMPTX_CONFIG_DIR="${PROMPTX_CONFIG_DIR:-$HOME/.promptx}"
PROMPTX_WORKSPACE_DIR="${PROMPTX_WORKSPACE_DIR:-$HOME/.promptx/workspace}"

mkdir -p "$PROMPTX_CONFIG_DIR"
mkdir -p "$PROMPTX_WORKSPACE_DIR"

export PROMPTX_CONFIG_DIR
export PROMPTX_WORKSPACE_DIR
export PROMPTX_GATEWAY_PORT="${PROMPTX_GATEWAY_PORT:-18789}"
export PROMPTX_BRIDGE_PORT="${PROMPTX_BRIDGE_PORT:-18790}"
export PROMPTX_GATEWAY_BIND="${PROMPTX_GATEWAY_BIND:-lan}"
export PROMPTX_IMAGE="$IMAGE_NAME"
export PROMPTX_DOCKER_APT_PACKAGES="${PROMPTX_DOCKER_APT_PACKAGES:-}"
export PROMPTX_EXTRA_MOUNTS="$EXTRA_MOUNTS"
export PROMPTX_HOME_VOLUME="$HOME_VOLUME_NAME"

if [[ -z "${PROMPTX_GATEWAY_TOKEN:-}" ]]; then
  if command -v openssl >/dev/null 2>&1; then
    PROMPTX_GATEWAY_TOKEN="$(openssl rand -hex 32)"
  else
    PROMPTX_GATEWAY_TOKEN="$(python3 - <<'PY'
import secrets
print(secrets.token_hex(32))
PY
)"
  fi
fi
export PROMPTX_GATEWAY_TOKEN

COMPOSE_FILES=("$COMPOSE_FILE")
COMPOSE_ARGS=()

write_extra_compose() {
  local home_volume="$1"
  shift
  local -a mounts=("$@")
  local mount

  cat >"$EXTRA_COMPOSE_FILE" <<'YAML'
services:
  promptx-gateway:
    volumes:
YAML

  if [[ -n "$home_volume" ]]; then
    printf '      - %s:/home/node\n' "$home_volume" >>"$EXTRA_COMPOSE_FILE"
    printf '      - %s:/home/node/.promptx\n' "$PROMPTX_CONFIG_DIR" >>"$EXTRA_COMPOSE_FILE"
    printf '      - %s:/home/node/.promptx/workspace\n' "$PROMPTX_WORKSPACE_DIR" >>"$EXTRA_COMPOSE_FILE"
  fi

  for mount in "${mounts[@]}"; do
    printf '      - %s\n' "$mount" >>"$EXTRA_COMPOSE_FILE"
  done

  cat >>"$EXTRA_COMPOSE_FILE" <<'YAML'
  promptx-cli:
    volumes:
YAML

  if [[ -n "$home_volume" ]]; then
    printf '      - %s:/home/node\n' "$home_volume" >>"$EXTRA_COMPOSE_FILE"
    printf '      - %s:/home/node/.promptx\n' "$PROMPTX_CONFIG_DIR" >>"$EXTRA_COMPOSE_FILE"
    printf '      - %s:/home/node/.promptx/workspace\n' "$PROMPTX_WORKSPACE_DIR" >>"$EXTRA_COMPOSE_FILE"
  fi

  for mount in "${mounts[@]}"; do
    printf '      - %s\n' "$mount" >>"$EXTRA_COMPOSE_FILE"
  done

  if [[ -n "$home_volume" && "$home_volume" != *"/"* ]]; then
    cat >>"$EXTRA_COMPOSE_FILE" <<YAML
volumes:
  ${home_volume}:
YAML
  fi
}

VALID_MOUNTS=()
if [[ -n "$EXTRA_MOUNTS" ]]; then
  IFS=',' read -r -a mounts <<<"$EXTRA_MOUNTS"
  for mount in "${mounts[@]}"; do
    mount="${mount#"${mount%%[![:space:]]*}"}"
    mount="${mount%"${mount##*[![:space:]]}"}"
    if [[ -n "$mount" ]]; then
      VALID_MOUNTS+=("$mount")
    fi
  done
fi

if [[ -n "$HOME_VOLUME_NAME" || ${#VALID_MOUNTS[@]} -gt 0 ]]; then
  write_extra_compose "$HOME_VOLUME_NAME" "${VALID_MOUNTS[@]}"
  COMPOSE_FILES+=("$EXTRA_COMPOSE_FILE")
fi
for compose_file in "${COMPOSE_FILES[@]}"; do
  COMPOSE_ARGS+=("-f" "$compose_file")
done
COMPOSE_HINT="docker compose"
for compose_file in "${COMPOSE_FILES[@]}"; do
  COMPOSE_HINT+=" -f ${compose_file}"
done

ENV_FILE="$ROOT_DIR/.env"
upsert_env() {
  local file="$1"
  shift
  local -a keys=("$@")
  local tmp
  tmp="$(mktemp)"
  declare -A seen=()

  if [[ -f "$file" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      local key="${line%%=*}"
      local replaced=false
      for k in "${keys[@]}"; do
        if [[ "$key" == "$k" ]]; then
          printf '%s=%s\n' "$k" "${!k-}" >>"$tmp"
          seen["$k"]=1
          replaced=true
          break
        fi
      done
      if [[ "$replaced" == false ]]; then
        printf '%s\n' "$line" >>"$tmp"
      fi
    done <"$file"
  fi

  for k in "${keys[@]}"; do
    if [[ -z "${seen[$k]:-}" ]]; then
      printf '%s=%s\n' "$k" "${!k-}" >>"$tmp"
    fi
  done

  mv "$tmp" "$file"
}

upsert_env "$ENV_FILE" \
  PROMPTX_CONFIG_DIR \
  PROMPTX_WORKSPACE_DIR \
  PROMPTX_GATEWAY_PORT \
  PROMPTX_BRIDGE_PORT \
  PROMPTX_GATEWAY_BIND \
  PROMPTX_GATEWAY_TOKEN \
  PROMPTX_IMAGE \
  PROMPTX_EXTRA_MOUNTS \
  PROMPTX_HOME_VOLUME \
  PROMPTX_DOCKER_APT_PACKAGES

echo "==> Building Docker image: $IMAGE_NAME"
docker build \
  --build-arg "PROMPTX_DOCKER_APT_PACKAGES=${PROMPTX_DOCKER_APT_PACKAGES}" \
  -t "$IMAGE_NAME" \
  -f "$ROOT_DIR/Dockerfile" \
  "$ROOT_DIR"

echo ""
echo "==> Onboarding (interactive)"
echo "When prompted:"
echo "  - Gateway bind: lan"
echo "  - Gateway auth: token"
echo "  - Gateway token: $PROMPTX_GATEWAY_TOKEN"
echo "  - Tailscale exposure: Off"
echo "  - Install Gateway daemon: No"
echo ""
docker compose "${COMPOSE_ARGS[@]}" run --rm promptx-cli onboard --no-install-daemon

echo ""
echo "==> Provider setup (optional)"
echo "WhatsApp (QR):"
echo "  ${COMPOSE_HINT} run --rm promptx-cli channels login"
echo "Telegram (bot token):"
echo "  ${COMPOSE_HINT} run --rm promptx-cli channels add --channel telegram --token <token>"
echo "Discord (bot token):"
echo "  ${COMPOSE_HINT} run --rm promptx-cli channels add --channel discord --token <token>"
echo "Docs: https://docs.openclaw.ai/channels"

echo ""
echo "==> Starting gateway"
docker compose "${COMPOSE_ARGS[@]}" up -d promptx-gateway

echo ""
echo "Gateway running with host port mapping."
echo "Access from tailnet devices via the host's tailnet IP."
echo "Config: $PROMPTX_CONFIG_DIR"
echo "Workspace: $PROMPTX_WORKSPACE_DIR"
echo "Token: $PROMPTX_GATEWAY_TOKEN"
echo ""
echo "Commands:"
echo "  ${COMPOSE_HINT} logs -f promptx-gateway"
echo "  ${COMPOSE_HINT} exec promptx-gateway node dist/index.js health --token \"$PROMPTX_GATEWAY_TOKEN\""
