# Easy WARP
this script installs and configurates Cloudflare WARP with Wireguard core on linux based devices

## Features

- Support for variety of cpu architectures
- Can add custom license key (WARP+ support)
- better and more efficent warp configuration compared to warp configuration via proxy (SOCKS5 port: 40000) 
- uses less resources and has more speed

## Install

**run the script as root**
1. run this command:
```bash
bash <(curl -Ls https://github.com/mikeesierrah/ez-warp/raw/master/ez-warp.sh)
```
2. check if WARP interface is running properly via running 'wg' command
```bash
wg
```

## Custom license
script asks for your custom license key , you can use it to enable WARP+.
**if you deny the script automatically installs WARP free**

## Tip
if you are using xray you should add this configuration to your 'outband': 
```json
{
  "tag": "warp",
  "protocol": "freedom",
  "streamSettings": {
    "sockopt": {
      "tcpFastOpen": true,
      "interface": "warp"
    }
  }
}
```
then set the routing properly as instructed by [XRAY documentation](https://xtls.github.io/en/config/routing.html)

## DONATION
if you want to appreciate me donate 5$ to a person in need
