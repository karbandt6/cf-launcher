#!/usr/bin/env bash

set -e

PORT=20128

# Palet Warna Modern (256-colors)
C_DEF="\e[0m"
C_CYAN="\e[38;5;51m"
C_MAGENTA="\e[38;5;207m"
C_GREEN="\e[38;5;46m"
C_YELLOW="\e[38;5;226m"
C_RED="\e[38;5;196m"
C_GRAY="\e[38;5;240m"
C_BOLD="\e[1m"

clear

# Banner Keren (CFROUTE)
echo -e "${C_CYAN}${C_BOLD}"
cat <<'EOF'
  ____ _____ ____  ___  _   _ _____ _____ 
 / ___|  ___|  _ \/ _ \| | | |_   _| ____|
| |   | |_  | |_)| | | | | | | | | |  _|  
| |___|  _| |  _ < |_| | |_| | | | | |___ 
 \____|_|   |_| \_\___/ \___/  |_| |_____|
                                          
EOF
echo -e "${C_MAGENTA}       ▶ CLOUDFLARE TUNNEL LAUNCHER ◀${C_DEF}\n"

ARCH=$(uname -m)

# Membuka Kotak Dashboard
echo -e "${C_GRAY}╭──────────────────────────────────────────────────╮${C_DEF}"
echo -e "${C_GRAY}│${C_DEF}  ${C_CYAN}🖥️  System Arch  ${C_DEF}: ${C_BOLD}${ARCH}${C_DEF}"

# Mengecek dan menginstal Cloudflared di latar belakang (tanpa output berantakan)
if command -v cloudflared >/dev/null 2>&1; then
    # Mengambil hanya angka versinya saja
    CF_VER=$(cloudflared --version | awk '{print $3}')
    echo -e "${C_GRAY}│${C_DEF}  ${C_GREEN}☁️  Cloudflared  ${C_DEF}: ${C_BOLD}v${CF_VER}${C_DEF}"
else
    echo -ne "${C_GRAY}│${C_DEF}  ${C_YELLOW}☁️  Cloudflared  ${C_DEF}: ${C_BOLD}Installing...${C_DEF}"
    
    case "$ARCH" in
        x86_64|amd64) PKG="cloudflared-linux-amd64.deb" ;;
        aarch64|arm64) PKG="cloudflared-linux-arm64.deb" ;;
        armv7l|armhf) PKG="cloudflared-linux-arm.deb" ;;
        *) 
            echo -e "\r${C_GRAY}│${C_DEF}  ${C_RED}❌ Error: Unsupported architecture${C_DEF}"
            echo -e "${C_GRAY}╰──────────────────────────────────────────────────╯${C_DEF}"
            exit 1 
            ;;
    esac

    # Proses download dan install diam-diam
    curl -fsSL "https://github.com/cloudflare/cloudflared/releases/latest/download/$PKG" -o /tmp/cloudflared.deb > /dev/null 2>&1
    dpkg -i /tmp/cloudflared.deb > /dev/null 2>&1 || apt-get install -f -y > /dev/null 2>&1
    rm -f /tmp/cloudflared.deb

    # Menimpa baris "Installing..." menjadi "Installed"
    echo -e "\r${C_GRAY}│${C_DEF}  ${C_GREEN}☁️  Cloudflared  ${C_DEF}: ${C_BOLD}Installed ✅   ${C_DEF}"
fi

echo -e "${C_GRAY}│${C_DEF}  ${C_CYAN}🚀 Service      ${C_DEF}: ${C_BOLD}CFRoute${C_DEF}"
echo -e "${C_GRAY}│${C_DEF}  ${C_CYAN}🔌 Local Port   ${C_DEF}: ${C_BOLD}${PORT}${C_DEF}"
echo -e "${C_GRAY}╰──────────────────────────────────────────────────╯${C_DEF}\n"

# Animasi Loading
echo -ne "${C_YELLOW}⚡ Initializing Secure Tunnel ${C_DEF}"
for i in {1..3}; do
    echo -ne "${C_YELLOW}.${C_DEF}"
    sleep 0.3
done
echo -e "\n"

# Instruksi akhir
echo -e "${C_GREEN}${C_BOLD}✅ Tunnel is live! Copy the ${C_MAGENTA}'.trycloudflare.com'${C_GREEN} link below:${C_DEF}"
echo -e "${C_GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_DEF}\n"

# Menjalankan Tunnel
cloudflared tunnel --url "http://127.0.0.1:$PORT"

