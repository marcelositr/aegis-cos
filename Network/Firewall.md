---
title: Firewall
title_pt: Firewall
layer: network
type: concept
priority: high
version: 1.0.0
tags:
  - Network
  - Security
  - Firewall
  - Security
description: Network firewall configuration and best practices.
description_pt: Configuração de firewall de rede e melhores práticas.
prerequisites:
  - Network
  - NetworkSecurity
estimated_read_time: 10 min
difficulty: intermediate
---

# Firewall

## Description

A firewall is a network security system that monitors and controls incoming and outgoing network traffic based on predetermined security rules. It establishes a barrier between trusted internal networks and untrusted external networks, filtering traffic based on IP addresses, ports, protocols, and application-level content.

Firewalls have evolved from simple packet-filtering devices to sophisticated next-generation appliances that include:
- **Stateful inspection** - Tracks connection state
- **Deep packet inspection** - Examines payload
- **Application awareness** - Understands protocols
- **Threat intelligence** - Blocks known threats

## Purpose

**When firewalls are essential:**
- Protecting internal networks from external threats
- Segmenting network zones
- Controlling access to services
- Logging network activity for audit

## Rules

1. **Deny by default** - Block everything unless explicitly allowed
2. **Least privilege** - Only allow necessary traffic
3. **Log everything** - Maintain audit trail
4. **Regular review** - Update rules based on changes
5. **Test rules** - Validate firewall behavior

## Examples

### iptables Basic Configuration

```bash
# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F

# Set default policies (deny all incoming)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH (rate limited)
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP/HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow internal network
iptables -A INPUT -s 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -s 172.16.0.0/12 -j ACCEPT

# Log dropped packets
iptables -A INPUT -j LOG --log-prefix "IPTABLES-DROP: "
```

### UFW (Uncomplicated Firewall)

```bash
# Enable UFW
sudo ufw enable

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH
sudo ufw allow ssh

# Allow specific ports
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow from specific IP
sudo ufw allow from 192.168.1.100

# Allow port range
sudo ufw allow 6000:6005/tcp

# Deny specific IP
sudo ufw deny from 10.0.0.1

# View status
sudo ufw status verbose

# View numbered rules
sudo ufw status numbered

# Delete rule
sudo ufw delete 2

# Check logs
sudo ufw logging low
tail -f /var/log/ufw.log
```

### Cloud Security Groups (AWS)

```yaml
# AWS Security Group - Web Server
Resources:
  WebServerSG:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: "Web server security group"
      SecurityGroupIngress:
        # HTTP from anywhere
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
        # HTTPS from anywhere
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0
        # SSH from specific IP only
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 203.0.113.0/32
      SecurityGroupEgress:
        # Allow all outbound
        - IpProtocol: -1
          CidrIp: 0.0.0.0/0

# Database security group
  DatabaseSG:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: "Database security group"
      SecurityGroupIngress:
        # MySQL from app tier only
        - IpProtocol: tcp
          FromPort: 3306
          ToPort: 3306
          SourceSecurityGroupId: !Ref WebServerSG
```

### nftables Configuration

```bash
# /etc/nftables.conf
#!/usr/sbin/nft -f

# Flush ruleset
flush ruleset

# Define tables
table inet filter {
    # Input chain
    chain input {
        type filter hook input priority 0; policy drop;
        
        # Allow loopback
        iif lo accept
        
        # Allow established
        ct state established,related accept
        
        # Allow ICMP
        ip protocol icmp accept
        
        # Allow SSH
        tcp dport 22 accept
        
        # Allow HTTP/HTTPS
        tcp dport { 80, 443 } accept
        
        # Log and drop
        counter drop
    }
    
    # Forward chain
    chain forward {
        type filter hook forward priority 0; policy drop;
        # Allow established forwarding
        ct state established,related accept
    }
    
    # Output chain
    chain output {
        type filter hook output priority 0; policy accept;
    }
}
```

## Anti-Patterns

### 1. Allowing All Traffic

```bash
# BAD - Too permissive
iptables -A INPUT -j ACCEPT  # Allow everything!

# GOOD - Explicit rules
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/8 -j ACCEPT
```

### 2. Not Logging

```bash
# BAD - No logging
iptables -A INPUT -j DROP

# GOOD - Log before dropping
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "DROP: "
iptables -A INPUT -j DROP
```

## Failure Modes

- **Overly permissive rules** → unauthorized access → data breach → follow deny-by-default and least privilege principles
- **Missing logging on drops** → no audit trail → undetected intrusion attempts → log all dropped packets with rate limiting
- **Rule order mistakes** → broader rules shadow specific ones → unintended access → order rules from specific to general
- **Stale rules accumulation** → rule sprawl → accidental exposure → regularly audit and remove unused rules
- **No backup before changes** → broken firewall → complete network outage → backup configs before any rule modifications
- **Single firewall device** → hardware failure → no network protection → deploy redundant firewalls with failover
- **Misconfigured NAT** → traffic misrouted → service unreachable → verify NAT translations after every change

## Best Practices

### Rule Ordering

```
1. Loopback interface (lo)
2. Established connections
3. Specific services (SSH, HTTP, HTTPS)
4. Specific sources
5. Drop everything else
```

### Regular Review

```bash
# Script to audit firewall rules
#!/bin/bash
echo "=== Current iptables rules ==="
iptables -L -n -v --line-numbers

echo "=== Rules by source IP ==="
iptables -L -n | grep -E "^[0-9]+.*ACCEPT" | awk '{print $4}' | sort | uniq -c | sort -rn

echo "=== Port usage ==="
iptables -L -n | grep -oP 'dpt:\d+' | sort | uniq -c | sort -rn
```

## Related Topics

- [[Network MOC]]
- [[NetworkSecurity]]
- [[ZeroTrust]]
- [[VPN]]
- [[ServiceMesh]]

## Additional Notes

**Firewall Types:**
- Packet filtering - Basic inspection
- Stateful - Connection tracking
- Application - Protocol-aware
- Next-generation - Threat-focused

**Key Ports:**
- 22 - SSH
- 80 - HTTP
- 443 - HTTPS
- 3306 - MySQL
- 5432 - PostgreSQL
- 6379 - Redis