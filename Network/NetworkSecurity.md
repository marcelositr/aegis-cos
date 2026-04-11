---
title: Network Security
title_pt: Segurança de Rede
layer: network
type: concept
priority: high
version: 1.0.0
tags:
  - Network
  - Security
  - Firewall
  - VPN
  - Zero Trust
description: Network security principles, firewalls, VPNs, and zero trust architecture.
description_pt: Princípios de segurança de rede, firewalls, VPNs e arquitetura de confiança zero.
prerequisites:
  - Network
  - Security
estimated_read_time: 12 min
difficulty: intermediate
---

# Network Security

## Description

Network security encompasses the policies, procedures, and technologies used to protect the underlying network infrastructure from unauthorized access, misuse, malfunction, modification, destruction, or improper disclosure. It involves implementing hardware and software mechanisms to defend against both external and internal threats.

The core objectives of network security are:
- **Confidentiality** - Ensuring only authorized parties can access data
- **Integrity** - Protecting data from unauthorized modification
- **Availability** - Ensuring services remain accessible to legitimate users

Modern network security has evolved from perimeter-based security (like a castle with walls) to zero trust architecture (never trust, always verify). This shift recognizes that threats can originate both externally and internally, and that network location alone should not determine trust.

## Purpose

**When network security is essential:**
- Protecting sensitive data in transit
- Defending against unauthorized access
- Complying with security regulations (GDPR, HIPAA, PCI-DSS)
- Preventing data breaches and cyber attacks

**Common network security challenges:**
- Distributed environments (cloud, hybrid)
- Remote workforce
- IoT devices
- Increasing attack surface

## Rules

1. **Implement defense in depth** - Multiple layers of security
2. **Apply least privilege** - Minimal access required
3. **Segment networks** - Limit lateral movement
4. **Monitor continuously** - Detect anomalies
5. **Encrypt traffic** - Protect data in transit

## Examples

### Firewall Rules (iptables)

```bash
# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH (limited attempts)
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP/HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow internal network
iptables -A INPUT -s 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -s 172.16.0.0/12 -j ACCEPT
iptables -A INPUT -s 192.168.0.0/16 -j ACCEPT

# Drop everything else
iptables -A INPUT -j DROP

# NAT for outgoing traffic
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

### Network Segmentation (VPC)

```yaml
# AWS VPC with subnets
Resources:
  # Public subnet (DMZ)
  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MainVPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: us-east-1a
      MapPublicIpOnLaunch: true

  # Private subnet (App tier)
  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MainVPC
      CidrBlock: 10.0.10.0/24
      AvailabilityZone: us-east-1a

  # Database subnet (Data tier)
  DatabaseSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MainVPC
      CidrBlock: 10.0.20.0/24
      AvailabilityZone: us-east-1a

  # Security Group for Application
  AppSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: "Application tier security group"
      VpcId: !Ref MainVPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 10.0.0.0/16

  # Security Group for Database
  DBSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: "Database tier security group"
      VpcId: !Ref MainVPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 5432
          ToPort: 5432
          SourceSecurityGroupId: !Ref AppSecurityGroup
```

### VPN Configuration (WireGuard)

```ini
# /etc/wireguard/wg0.conf - Server configuration

[Interface]
# Server's private key
PrivateKey = SERVER_PRIVATE_KEY_HERE
# Listen port
ListenPort = 51820
# Server's IP address in VPN network
Address = 10.0.0.1/24

# Post-up rules - NAT and routing
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -A FORWARD -o wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostUp = iptables -A INPUT -p udp --dport 51820 -j ACCEPT

# Post-down rules - cleanup
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -D FORWARD -o wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D INPUT -p udp --dport 51820 -j ACCEPT

# Client peer configuration
[Peer]
# Client's public key
PublicKey = CLIENT_PUBLIC_KEY_HERE
# Allowed IP addresses (client's VPN range)
AllowedIPs = 10.0.0.2/32
# Persist keepalive to maintain NAT mapping
PersistentKeepalive = 25
```

```ini
# /etc/wireguard/client.conf - Client configuration

[Interface]
# Client's private key
PrivateKey = CLIENT_PRIVATE_KEY_HERE
# Client's IP address in VPN network
Address = 10.0.0.2/24
# DNS server
DNS = 1.1.1.1

[Peer]
# Server's public key
PublicKey = SERVER_PUBLIC_KEY_HERE
# Server's endpoint
Endpoint = vpn.example.com:51820
# Routes to tunnel (0.0.0.0/0 for full tunnel)
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

### Intrusion Detection (Snort rules)

```
# Snort rules for detecting common attacks

# Detect SSH brute force attempts
alert tcp any any -> any 22 (msg:"SSH Brute Force Attempt"; \
    flow:to_server,established; \
    detection_filter:track by_src,count 5,seconds 60; \
    classtype:attempted-admin; sid:1000001; rev:1;)

# Detect potential SQL injection
alert tcp any any -> any any (msg:"Potential SQL Injection"; \
    flow:to_server; \
    content:"UNION"; nocase; \
    content:"SELECT"; nocase; \
    threshold:type limit,track by_src,seconds 60,count 3; \
    classtype:web-application-attack; sid:1000002; rev:1;)

# Detect port scanning
alert ip any any -> any any (msg:"Port Scan"; \
    flow:stateless; \
    detection_filter:track by_dst,count 20,seconds 30; \
    classtype:attempted-recon; sid:1000003; rev:1;)

# Detect suspicious outbound connections
alert tcp any any -> any $HOME_NET (msg:"Suspicious Outbound Connection"; \
    flow:to_server; \
    content:"|00|"; depth:1; \
    threshold:type limit,track by_src,seconds 300,count 5; \
    classtype:trojan-activity; sid:1000004; rev:1;)
```

### Zero Trust Policy (Policy as Code)

```python
# Zero Trust Policy Engine
from dataclasses import dataclass
from typing import List, Optional
from enum import Enum

class Action(Enum):
    ALLOW = "allow"
    DENY = "deny"
    MFA_REQUIRED = "mfa_required"
    LIMITED = "limited"

@dataclass
class Request:
    user: str
    resource: str
    action: str
    device_compliant: bool
    location: str
    time: str
    risk_score: float

class ZeroTrustPolicy:
    def evaluate(self, request: Request) -> Action:
        # 1. Device compliance check
        if not request.device_compliant:
            return Action.DENY
        
        # 2. Location-based risk
        high_risk_locations = ['unknown', 'tor', 'proxy']
        if request.location.lower() in high_risk_locations:
            if request.risk_score > 0.5:
                return Action.DENY
            return Action.MFA_REQUIRED
        
        # 3. Time-based access
        business_hours = self._is_business_hours(request.time)
        sensitive_resources = ['admin', 'finance', 'hr']
        
        if any(sr in request.resource.lower() for sr in sensitive_resources):
            if not business_hours:
                return Action.MFA_REQUIRED
        
        # 4. Risk-based access
        if request.risk_score > 0.8:
            return Action.DENY
        elif request.risk_score > 0.5:
            return Action.LIMITED
        
        # 5. Default allow with logging
        return Action.ALLOW
    
    def _is_business_hours(self, time_str: str) -> bool:
        hour = int(time_str.split(':')[0])
        return 9 <= hour <= 17

# Usage
policy = ZeroTrustPolicy()
request = Request(
    user="john@example.com",
    resource="/api/admin/users",
    action="read",
    device_compliant=True,
    location="office",
    time="14:30:00",
    risk_score=0.2
)

result = policy.evaluate(request)
print(f"Decision: {result.value}")
```

## Anti-Patterns

### 1. Trusting Internal Network

```python
# BAD - Internal network assumed to be safe
# Allow all traffic from internal network
security_group_ingress(cidr_block='10.0.0.0/8', port=ALL)

# GOOD - Zero trust, verify every request
# Each request verified regardless of source
# Apply MFA, device compliance, anomaly detection
```

### 2. Overly Permissive Firewalls

```bash
# BAD - Allow everything
iptables -P INPUT ACCEPT

# GOOD - Deny by default, explicit allows
iptables -P INPUT DROP
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```

### 3. No Network Monitoring

```python
# BAD - No logging or monitoring
# No visibility into network traffic

# GOOD - Comprehensive logging
logging.info(f"Connection from {ip} to {port} blocked")
# Use SIEM for analysis
# Set up alerts for anomalies
```

## Failure Modes

- **Trusting internal network** → lateral movement undetected → full network compromise → implement zero trust architecture with per-request verification
- **Flat network topology** → no segmentation → breach spreads instantly → segment networks into zones with strict access controls
- **Missing IDS/IPS** → attacks go unnoticed → prolonged breach → deploy intrusion detection/prevention at network boundaries
- **Outdated firewall rules** → stale allows create gaps → unauthorized access → regularly audit and prune firewall rule sets
- **No network monitoring** → anomalous traffic undetected → slow incident response → implement continuous traffic analysis with anomaly detection
- **Unencrypted internal traffic** → MITM within network → credential theft → enforce mTLS for all service-to-service communication
- **Default credentials on devices** → easy initial access → complete network takeover → change all defaults and enforce strong credential policies

## Best Practices

### Network Architecture

```
                    Internet
                        |
                ┌───────┴───────┐
                │   Edge Firewall│
                │  (WAF, DDoS)   │
                └───────┬───────┘
                        |
        ┌───────────────┼───────────────┐
        │               │               │
   ┌────┴────┐    ┌────┴────┐    ┌────┴────┐
   │DMZ Subnet│   │App Subnet│   │Data Subnet│
   │(Public)  │   │(Private) │   │(Private)  │
   └─────────┘    └──────────┘    └──────────┘
        │               │               │
   ┌────┴────┐    ┌────┴────┐    ┌────┴────┐
   │Web Servers│  │App Servers│  │Databases │
   └──────────┘   └───────────┘ └───────────┘
```

### Continuous Monitoring

```python
# Network traffic analysis
import pandas as pd
from sklearn.ensemble import IsolationForest

def detect_anomalies(network_logs: pd.DataFrame) -> list:
    """Detect anomalous network behavior"""
    
    features = network_logs[['bytes_in', 'bytes_out', 
                             'connections', 'duration']]
    
    # Train anomaly detector
    clf = IsolationForest(contamination=0.1)
    anomalies = clf.fit_predict(features)
    
    return network_logs[anomalies == -1].to_dict('records')
```

## Related Topics

- [[Network MOC]]
- [[Firewall]]
- [[VPN]]
- [[ZeroTrust]]
- [[TlsSsl]]

## Additional Notes

**Security Zones:**
- DMZ - Public-facing services
- Internal - Internal applications
- Database - Sensitive data
- Management - Admin access

**Key Technologies:**
- Next-generation firewalls
- IDS/IPS
- Network segmentation
- VPN (site-to-site, remote access)
- Zero trust network access (ZTNA)

**Compliance:**
- PCI-DSS for payment data
- HIPAA for healthcare
- SOC 2 for service organizations