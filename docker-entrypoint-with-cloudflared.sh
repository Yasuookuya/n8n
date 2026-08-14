#!/bin/sh
# =============================================================================
# Combined entrypoint: starts cloudflared (background) and n8n (foreground)
#
# The n8n image's original entrypoint (docker-entrypoint.sh) is invoked at
# the end to preserve n8n's certificate-handling behaviour.
# =============================================================================

# --- Cloudflared tunnel -------------------------------------------------------
if [ -n "$CLOUDFLARED_TOKEN" ]; then
  echo "[entrypoint] Starting cloudflared tunnel in the background..."
  /usr/local/bin/cloudflared tunnel --no-autoupdate run --token "$CLOUDFLARED_TOKEN" \
    >/tmp/cloudflared.log 2>&1 &
  CLOUDFLARED_PID=$!
  echo "[entrypoint] cloudflared started (PID ${CLOUDFLARED_PID}), logs: /tmp/cloudflared.log"
else
  echo "[entrypoint] CLOUDFLARED_TOKEN not set — skipping cloudflared."
fi

# --- n8n ----------------------------------------------------------------------
# Delegate to the original n8n entrypoint (cert handling + n8n launch).
exec /docker-entrypoint.sh "$@"