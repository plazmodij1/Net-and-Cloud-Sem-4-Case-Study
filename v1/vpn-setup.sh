#!/bin/bash
# 1. Force wait for apt locks and install tools
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y wireguard wireguard-tools curl iptables

# 2. Enable IP Forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# 3. Generate Keys (Stored in files first to be safe)
mkdir -p /etc/wireguard
cd /etc/wireguard
wg genkey | tee server_private.key | wg pubkey > server_public.key
wg genkey | tee client_private.key | wg pubkey > client_public.key

# Read them into variables
S_PRIV=$(cat server_private.key)
S_PUB=$(cat server_public.key)
C_PRIV=$(cat client_private.key)
C_PUB=$(cat client_public.key)

# Get Public IP
ENDPOINT=$(curl -s http://checkip.amazonaws.com)
ETH_IFACE=$(ip -o -4 route show to default | awk '{print $5}')

# 4. Create Server Config
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = 10.66.66.1/24
ListenPort = 51820
PrivateKey = $S_PRIV
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $ETH_IFACE -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $ETH_IFACE -j MASQUERADE

[Peer]
PublicKey = $C_PUB
AllowedIPs = 10.66.66.2/32
EOF

# 5. Create Client Config (The one you download)
cat <<EOF > /home/ubuntu/mylaptop.conf
[Interface]
PrivateKey = $C_PRIV
Address = 10.66.66.2/24
DNS = 10.1.0.2

[Peer]
PublicKey = $S_PUB
Endpoint = $ENDPOINT:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

chown ubuntu:ubuntu /home/ubuntu/mylaptop.conf
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0