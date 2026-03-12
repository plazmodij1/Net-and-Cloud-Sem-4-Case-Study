#!/bin/bash
# 1. Install WireGuard and IP tables silently
apt-get update
apt-get install -y wireguard iptables

# 2. Enable IP Forwarding (Crucial for VPN routing)
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# 3. Generate Server and Client Keys
wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key
wg genkey | tee /etc/wireguard/client_private.key | wg pubkey > /etc/wireguard/client_public.key

SERVER_PRIV=$(cat /etc/wireguard/server_private.key)
SERVER_PUB=$(cat /etc/wireguard/server_public.key)
CLIENT_PRIV=$(cat /etc/wireguard/client_private.key)
CLIENT_PUB=$(cat /etc/wireguard/client_public.key)

# Grab the Public IP and Default Network Interface (usually eth0 or ens5)
ENDPOINT=$(curl -s http://checkip.amazonaws.com)
ETH_IFACE=$(ip -o -4 route show to default | awk '{print $5}')

# 4. Create the Server Config
cat <<WGEOF > /etc/wireguard/wg0.conf
[Interface]
Address = 10.66.66.1/24
ListenPort = 51820
PrivateKey = $SERVER_PRIV
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $ETH_IFACE -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $ETH_IFACE -j MASQUERADE

[Peer]
PublicKey = $CLIENT_PUB
AllowedIPs = 10.66.66.2/32
WGEOF

# 5. Create the Client Config (for your laptop with the AWS DNS built-in!)
cat <<WGEOF > /home/ubuntu/mylaptop.conf
[Interface]
PrivateKey = $CLIENT_PRIV
Address = 10.66.66.2/24
DNS = 10.1.0.2

[Peer]
PublicKey = $SERVER_PUB
Endpoint = $ENDPOINT:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
WGEOF

# 6. Secure the client file and start the VPN
chown ubuntu:ubuntu /home/ubuntu/mylaptop.conf
chmod 600 /home/ubuntu/mylaptop.conf

systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0