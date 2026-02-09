#!/usr/bin/env bash
set -euo pipefail

cd /repo

export PROMPTX_STATE_DIR="/tmp/promptx-test"
export PROMPTX_CONFIG_PATH="${PROMPTX_STATE_DIR}/promptx.json"

echo "==> Build"
pnpm build

echo "==> Seed state"
mkdir -p "${PROMPTX_STATE_DIR}/credentials"
mkdir -p "${PROMPTX_STATE_DIR}/agents/main/sessions"
echo '{}' >"${PROMPTX_CONFIG_PATH}"
echo 'creds' >"${PROMPTX_STATE_DIR}/credentials/marker.txt"
echo 'session' >"${PROMPTX_STATE_DIR}/agents/main/sessions/sessions.json"

echo "==> Reset (config+creds+sessions)"
pnpm promptx reset --scope config+creds+sessions --yes --non-interactive

test ! -f "${PROMPTX_CONFIG_PATH}"
test ! -d "${PROMPTX_STATE_DIR}/credentials"
test ! -d "${PROMPTX_STATE_DIR}/agents/main/sessions"

echo "==> Recreate minimal config"
mkdir -p "${PROMPTX_STATE_DIR}/credentials"
echo '{}' >"${PROMPTX_CONFIG_PATH}"

echo "==> Uninstall (state only)"
pnpm promptx uninstall --state --yes --non-interactive

test ! -d "${PROMPTX_STATE_DIR}"

echo "OK"
