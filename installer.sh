#!/usr/bin/env bash
set -euo pipefail

# ==== CONFIG ====
APP_NAME="ai-web-agent"
APP_USER="aiagent"
APP_DIR="/opt/${APP_NAME}"
VENV_DIR="${APP_DIR}/.venv"
SERVICE_NAME="aiwebagent"
TARBALL_URL="https://raw.github.com/aukiman/ai-web-agent/main/ai-web-agent.tar.gz"
PYTHON_BIN="python3"
# =================

echo "[*] Installing ${APP_NAME}..."

# 1) OS deps
echo "[*] Installing OS dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y --no-install-recommends           ca-certificates curl wget unzip jq tar           ${PYTHON_BIN} python3-venv python3-pip           systemd

# 2) App user
if ! id -u "${APP_USER}" >/dev/null 2>&1; then
  echo "[*] Creating system user ${APP_USER}..."
  useradd --system --create-home --home-dir "${APP_DIR}" --shell /usr/sbin/nologin "${APP_USER}"
fi

# 3) App dir
mkdir -p "${APP_DIR}"
chown -R "${APP_USER}:${APP_USER}" "${APP_DIR}"

# 4) Fetch tarball
TMPDIR="$(mktemp -d)"
echo "[*] Downloading release tarball..."
wget -qO "${TMPDIR}/${APP_NAME}.tar.gz" "${TARBALL_URL}"

echo "[*] Unpacking into ${APP_DIR}..."
tar -xzf "${TMPDIR}/${APP_NAME}.tar.gz" -C "${APP_DIR}" --strip-components=1
rm -rf "${TMPDIR}"

# 5) Python venv + deps
echo "[*] Creating virtualenv..."
sudo -u "${APP_USER}" ${PYTHON_BIN} -m venv "${VENV_DIR}"
sudo -u "${APP_USER}" "${VENV_DIR}/bin/pip" install --upgrade pip wheel

echo "[*] Installing Python requirements..."
sudo -u "${APP_USER}" "${VENV_DIR}/bin/pip" install -r "${APP_DIR}/requirements.txt"

echo "[*] Installing Playwright & browser deps..."
# Install OS deps as root
"${VENV_DIR}/bin/python" -m playwright install-deps chromium
# Install browser binaries into the venv as the app user
sudo -u "${APP_USER}" "${VENV_DIR}/bin/python" -m playwright install chromium


# 6) Config files (create if missing)
if [ ! -f "${APP_DIR}/config.yaml" ]; then
  echo "[*] Creating config.yaml from sample..."
  cp "${APP_DIR}/config.yaml.sample" "${APP_DIR}/config.yaml"
fi

if [ ! -f "${APP_DIR}/.env" ]; then
  echo "[*] Creating .env from sample..."
  cp "${APP_DIR}/.env.sample" "${APP_DIR}/.env"
fi

chown -R "${APP_USER}:${APP_USER}" "${APP_DIR}"

# 7) Systemd units
echo "[*] Installing systemd units..."
cp "${APP_DIR}/systemd/aiwebagent.service" "/etc/systemd/system/${SERVICE_NAME}.service"
cp "${APP_DIR}/systemd/aiwebagent.timer"   "/etc/systemd/system/${SERVICE_NAME}.timer"

systemctl daemon-reload
systemctl enable "${SERVICE_NAME}.service"
systemctl enable "${SERVICE_NAME}.timer"
systemctl start "${SERVICE_NAME}.timer"

echo "[*] Installation complete."
echo "    • Edit ${APP_DIR}/.env and ${APP_DIR}/config.yaml"
echo "    • Then: sudo systemctl restart ${SERVICE_NAME}.service"
echo "    • Logs: journalctl -u ${SERVICE_NAME}.service -f"
