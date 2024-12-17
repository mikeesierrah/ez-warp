#!/bin/bash
set -e

#necessary functions 
architecture() {
  case "$(uname -m)" in
    'i386' | 'i686') arch='386' ;;
    'x86_64') arch='amd64' ;;
    'armv5tel') arch='armv5' ;;
    'armv6l') arch='armv6' ;;
    'armv7' | 'armv7l') arch='armv7' ;;
    'aarch64') arch='arm64' ;;
    'mips64el') arch='mips64le_softfloat' ;;
    'mips64') arch='mips64_softfloat' ;;
    'mipsel') arch='mipsle_softfloat' ;;
    'mips') arch='mips_softfloat' ;;
    's390x') arch='s390x' ;;
    *) echo "error: The architecture is not supported."; return 1 ;;
  esac
  echo "$arch"
}

#check user status
if [ "$(id -u)" -ne 0 ]; then
    echo "This script requires root privileges. Please run it as root."
    exit 1
fi
#installing necessary packages

apt update && apt upgrade
ubuntu_major_version=$(grep DISTRIB_RELEASE /etc/lsb-release | cut -d'=' -f2 | cut -d'.' -f1)
if [[ "$ubuntu_major_version" == "24" ]]; then
  sudo apt install -y wireguard
else
  sudo apt install -y wireguard-dkms wireguard-tools resolvconf
fi



#checking packages
if ! command -v wg-quick &> /dev/null
then
    echo "something went wrong with wireguard package installation"
    exit 1
fi
if ! command -v resolvconf &> /dev/null
then
    echo "something went wrong with resolvconf package installation"
    exit 1
fi

clear
#downloading assets
arch=$(architecture)
wget -O "/usr/bin/wgcf" https://github.com/ViRb3/wgcf/releases/download/v2.2.23/wgcf_2.2.23_linux_$arch
chmod +x /usr/bin/wgcf



clear
# removing files that might cause problems

rm -rf wgcf-account.toml &> /dev/null || true
rm -rf /etc/wireguard/warp.conf &> /dev/null || true
# main dish

wgcf register
read -rp "Do you want to use your own key? (Y/n): " response
if [[ $response =~ ^[Yy]$ ]]; then
    read -rp "ENTER YOUR LICENSE: " LICENSE_KEY
    sed -i "s/license_key = '.*'/license_key = '$LICENSE_KEY'/" wgcf-account.toml
    wgcf update
fi

wgcf generate



#creating config in the wireguard directory

# this algorithm is  deprecated

# PRIVATE_KEY=$(grep -oP 'PrivateKey\s*=\s*\K.*' wgcf-profile.conf)
# cat << EOF > "/etc/wireguard/warp.conf"
# [Interface]
# PrivateKey = $PRIVATE_KEY
# Address = 172.16.0.2/32
# Address = 2606:4700:110:8a1a:85ef:da37:b891:8d01/128
# DNS = 1.1.1.1
# MTU = 1280
# Table = off
# [Peer]
# PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
# AllowedIPs = 0.0.0.0/0
# AllowedIPs = ::/0
# Endpoint = engage.cloudflareclient.com:2408
# EOF

# the better algorithm

sed -i '/\[Peer\]/i Table = off' wgcf-profile.conf
mv wgcf-profile.conf /etc/wireguard/warp.conf

systemctl disable --now wg-quick@warp &> /dev/null || true
systemctl enable --now wg-quick@warp

echo "Wireguard warp is up and running"
