#!/usr/bin/env bash

set -e

PORT=20128

C_DEF="\e[0m"
C_CYAN="\e[38;5;51m"
C_MAGENTA="\e[38;5;207m"
C_GREEN="\e[38;5;46m"
C_YELLOW="\e[38;5;226m"
C_RED="\e[38;5;196m"
C_GRAY="\e[38;5;240m"
C_BOLD="\e[1m"

clear

echo -e "${C_CYAN}${C_BOLD}"
cat <<'EOF'
  ____ _____ ____  ___  _   _ _____ _____
 / ___|  ___|  _ \/ _ \| | | |_   _| ____|
| |   | |_  | |_)| | | | | | | | | |  _|
| |___|  _| |  _ < |_| | |_| | | | | |___
 \____|_|   |_| \_\___/ \___/  |_| |_____|

EOF

echo -e "${C_MAGENTA}       ▶ CLOUDFLARE TUNNEL LAUNCHER ◀${C_DEF}"
echo


ARCH=$(uname -m)


echo -e "${C_GRAY}╭──────────────────────────────────────────────────╮${C_DEF}"
echo -e "${C_GRAY}│${C_DEF} 🖥️  System Arch  : ${C_BOLD}${ARCH}${C_DEF}"


# cek cloudflared
if command -v cloudflared >/dev/null 2>&1; then

    CF_VER=$(cloudflared --version | awk '{print $3}')

    echo -e "${C_GRAY}│${C_DEF} ☁️  Cloudflared  : ${C_GREEN}v${CF_VER}${C_DEF}"

else

    echo -e "${C_GRAY}│${C_DEF} ☁️  Cloudflared  : ${C_YELLOW}Installing...${C_DEF}"


    case "$ARCH" in

        x86_64|amd64)
            PKG="cloudflared-linux-amd64.deb"
        ;;

        aarch64|arm64)
            PKG="cloudflared-linux-arm64.deb"
        ;;

        armv7l|armhf)
            PKG="cloudflared-linux-arm.deb"
        ;;

        *)
            echo -e "${C_RED}Unsupported architecture${C_DEF}"
            exit 1
        ;;

    esac


    curl -fsSL \
    "https://github.com/cloudflare/cloudflared/releases/latest/download/$PKG" \
    -o /tmp/cloudflared.deb \
    >/dev/null 2>&1


    dpkg -i /tmp/cloudflared.deb >/dev/null 2>&1 || \
    apt-get install -f -y >/dev/null 2>&1


    rm -f /tmp/cloudflared.deb


    echo -e "${C_GRAY}│${C_DEF} ☁️  Cloudflared  : ${C_GREEN}Installed ✅${C_DEF}"

fi


echo -e "${C_GRAY}│${C_DEF} 🚀 Service       : ${C_BOLD}CFRoute${C_DEF}"
echo -e "${C_GRAY}│${C_DEF} 🔌 Local Port    : ${C_BOLD}${PORT}${C_DEF}"
echo -e "${C_GRAY}╰──────────────────────────────────────────────────╯${C_DEF}"


echo

echo -ne "${C_YELLOW}⚡ Initializing Secure Tunnel ${C_DEF}"

for i in 1 2 3
do
    echo -ne "."
    sleep 0.3
done

echo


echo -e "${C_GREEN}${C_BOLD}✅ Tunnel is starting...${C_DEF}"
echo -e "${C_GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_DEF}"


# logfile sementara
TMPLOG=$(mktemp)


# start cloudflared silent
cloudflared tunnel \
--no-autoupdate \
--url "http://127.0.0.1:$PORT" \
--logfile "$TMPLOG" \
--loglevel info \
>/dev/null 2>&1 &


CF_PID=$!


echo -ne "${C_YELLOW}⚡ Getting tunnel URL ${C_DEF}"


URL=""

for i in {1..30}
do

    URL=$(grep -oE 'https://[-a-zA-Z0-9]+\.trycloudflare\.com' "$TMPLOG" | head -1 || true)


    if [ -n "$URL" ]; then
        break
    fi


    echo -ne "."
    sleep 1

done


if [ -z "$URL" ]; then

    echo
    echo -e "${C_RED}❌ Failed get tunnel URL${C_DEF}"

    kill $CF_PID 2>/dev/null || true
    rm -f "$TMPLOG"

    exit 1

fi


echo
echo

echo -e "${C_GREEN}${C_BOLD}✅ Tunnel is live!${C_DEF}"
echo -e "${C_GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_DEF}"

echo -e "🖥️  Dashboard : ${C_CYAN}${URL}${C_DEF}"
echo -e "⚡ API Base  : ${C_CYAN}${URL}/v1${C_DEF}"

echo -e "${C_GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_DEF}"


rm -f "$TMPLOG"


# biarkan tunnel berjalan
wait $CF_PID
