---
title: VPN
title_pt: VPN (Virtual Private Network)
layer: network
type: concept
priority: high
version: 1.0.0
tags:
  - Network
  - Security
  - VPN
  - Remote Access
description: VPN setup, protocols, and configuration for secure remote access.
description_pt: Configuração de VPN, protocolos e configuração para acesso remoto seguro.
prerequisites:
  - Network
  - NetworkSecurity
estimated_read_time: 10 min
difficulty: intermediate
---

# VPN

## Description

A Virtual Private Network (VPN) creates an encrypted tunnel over public networks, allowing remote users to securely access corporate resources as if they were on the local network. VPNs are essential for remote work, branch office connectivity, and secure communication over untrusted networks.

VPN protocols include:
- **IPSec** - Industry standard, operates at network layer
- **OpenVPN** - Open source, highly configurable
- **WireGuard** - Modern, fast, simple
- **SSL VPN** - Browser-based access

## Purpose

**When VPN is needed:**
- Remote employee access
- Branch office connectivity
- Protecting public WiFi usage
- Bypassing geo-restrictions
- Site-to-site connectivity

## Rules

1. **Use strong encryption** - AES-256 minimum
2. **Implement MFA** - Add second authentication factor
3. **Use modern protocols** - Avoid deprecated ones
4. **Split tunneling carefully** - Only when necessary
5. **Monitor connections** - Log access attempts

## Examples

### WireGuard Server Setup

```bash
# Install WireGuard
sudo apt install wireguard

# Generate keys
wg genkey | tee privatekey | wg pubkey > publickey

# Server config /etc/wireguard/wg0.conf
[Interface]
PrivateKey = SERVER_PRIVATE_KEY
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -A FORWARD -o wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -D FORWARD -o wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = CLIENT_PUBLIC_KEY
AllowedIPs = 10.0.0.2/32
PersistentKeepalive = 25

# Enable and start
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

### OpenVPN Configuration

```bash
# Server config /etc/openvpn/server.conf
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist /var/log/openvpn/ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dh-option DNS 8.8.8.8"
keepalive 10 120
cipher AES-256-GCM
auth SHA256
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn/status.log
verb 3

# Client config client.ovpn
client
dev tun
proto udp
remote vpn.example.com 1194
resolv-retry infinite
nobind
user nobody
group nogroup
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-GCM
auth SHA256
verb 3
<ca>
# ca.crt contents
</ca>
<cert>
# client.crt contents
</cert>
<key>
# client.key contents
</key>
```

### IPsec with strongSwan

```bash
# /etc/ipsec.conf
config setup
    charondebug="all"
    uniqueids=never

conn %default
    ikelifetime=60m
    keylife=20m
    rekey=no
    left=%any
    ipcomp=no
    authby=secret
    forceencaps=yes

conn vpn.example.com
    leftid=@server
    right=client.example.com
    rightid=@client
    left=203.0.113.1
    rightsubnet=10.0.1.0/24
    auto=start
    type=tunnel
    ike=aes256gcm16-prfsha256-ecp256
    esp=aes256gcm16-prfsha256-ecp256
```

### AWS Client VPN

```yaml
# CloudFormation for Client VPN
Resources:
  ClientVPNEndpoint:
    Type: AWS::EC2::ClientVpnEndpoint
    Properties:
      ClientCidrBlock: 10.0.0.0/22
      ServerCertificateArn: !GetAtt ACMCertificate.Arn
      AuthenticationType: certificate-based-auth
      ClientCertificateArn: !GetAtt ACMClientCertificate.Arn
      SplitTunnel: false
      VpnPort: 443

  ClientVPNRoute:
    Type: AWS::EC2::ClientVpnRoute
    Properties:
      ClientVpnEndpointId: !Ref ClientVPNEndpoint
      DestinationCidrBlock: 10.1.0.0/16
      TargetVpcSubnetId: !Ref PrivateSubnet

  ClientVPNAuthorizationRule:
    Type: AWS::EC2::ClientVpnAuthorizationRule
    Properties:
      ClientVpnEndpointId: !Ref ClientVPNEndpoint
      Description: "Allow access to VPC"
      TargetNetworkCidr: 10.0.0.0/16
```

## Anti-Patterns

### 1. Weak Authentication

```ini
# BAD - Password only
auth-user-pass

# GOOD - Certificate + MFA
auth-by-cert
plugin /usr/lib/openvpn/plugin/lib/openvpn-auth-pam.so "login"
```

### 2. Using Deprecated Protocols

```ini
# BAD - Weak protocols
cipher DES-CBC
auth SHA1

# GOOD - Strong encryption
cipher AES-256-GCM
auth SHA256
```

## Failure Modes

- **Weak authentication** → unauthorized tunnel access → network compromise → require MFA and certificate-based authentication
- **Deprecated protocols** → known vulnerabilities exploited → data interception → disable PPTP/L2TP and use WireGuard or OpenVPN
- **Split tunneling misconfiguration** → traffic bypasses VPN → data leakage → carefully scope split tunnel routes or use full tunnel
- **No connection monitoring** → rogue access undetected → persistent breach → log all VPN connections and alert on anomalies
- **Key/cert compromise** → attacker gains persistent access → lateral movement → implement key rotation and revocation procedures
- **MTU issues** → packet fragmentation → connection instability or dropped packets → configure proper MTU/MSS clamping
- **DNS leak through VPN** → queries exposed to ISP → privacy breach → force DNS through VPN tunnel and test for leaks

## Best Practices

### Multi-Factor Authentication

```yaml
# OpenVPN with Duo MFA
plugin /opt/duo/openvpn_duo.so "ikey=DIXXXXXXXX" "skey=XXXXXXXX"
```

### Split Tunneling Decision

```
Full Tunnel (default):
- All traffic through VPN
- More secure, uses more bandwidth
- Use when: public WiFi, strict security

Split Tunnel:
- Only VPC traffic through VPN
- Better performance, less secure
- Use when: performance critical, known networks
```

## Related Topics

- [[Network MOC]]
- [[NetworkSecurity]]
- [[TlsSsl]]
- [[Firewall]]
- [[ZeroTrust]]

## Additional Notes

**Protocol Comparison:**
- WireGuard: Fastest, simplest
- OpenVPN: Most compatible
- IPsec: Enterprise grade

**Port Defaults:**
- OpenVPN: 1194/UDP
- WireGuard: 51820/UDP
- IPSec: 500/4500/UDP