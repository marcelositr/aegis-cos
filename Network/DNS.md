---
title: DNS
title_pt: DNS (Domain Name System)
layer: network
type: concept
priority: medium
version: 1.0.0
tags:
  - Network
  - DNS
  - Infrastructure
description: System that translates domain names to IP addresses.
description_pt: Sistema que traduz nomes de domínio para endereços IP.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# DNS

## Description

DNS (Domain Name System) is the hierarchical naming system for computers, services, or other resources connected to the Internet. It translates human-readable domain names (like example.com) into numerical IP addresses (like 192.168.1.1) that computers use to identify each other.

DNS is often called the "phone book of the Internet" because it provides a mapping between human-readable names and IP addresses. Without DNS, users would need to remember the IP address of every website they want to visit.

Key DNS concepts:
- **Domain Name** - Human-readable identifier (example.com)
- **IP Address** - Numerical identifier (192.168.1.1)
- **DNS Server** - Server that responds to DNS queries
- **Resolver** - Client-side DNS resolver
- **TLD (Top-Level Domain)** - .com, .org, .net, country codes

DNS lookup process:
1. Client queries resolver
2. Resolver checks cache
3. Resolver queries root server
4. Root directs to TLD server
5. TLD directs to authoritative server
6. Authoritative returns IP

Common record types:
- **A** - Maps domain to IPv4 address
- **AAAA** - Maps domain to IPv6 address
- **CNAME** - Alias to another domain
- **MX** - Mail server
- **TXT** - Text records (SPF, DKIM)
- **NS** - Nameserver

## Purpose

**When DNS knowledge is important:**
- For troubleshooting connectivity issues
- For configuring domains
- For understanding web architecture
- For security (DNS spoofing, cache poisoning)

**Common uses:**
- Web browsing
- Email delivery
- SSL certificate validation

## Rules

1. **Use short TTLs for changes** - Allow faster propagation
2. **Use multiple nameservers** - Redundancy
3. **Implement DNSSEC** - For security
4. **Cache strategically** - Reduce latency
5. **Monitor DNS health** - Detect issues

## Examples

### DNS Records

```bash
# A Record - IPv4 address
example.com.    IN A     192.168.1.1

# AAAA Record - IPv6 address
example.com.    IN AAAA  2001:db8::1

# CNAME Record - Alias
www.example.com. IN CNAME example.com.

# MX Record - Mail server
example.com.    IN MX    10 mail1.example.com.
example.com.    IN MX    20 mail2.example.com.

# TXT Record - SPF
example.com.    IN TXT   "v=spf1 include:_spf.example.com ~all"

# NS Record - Nameservers
example.com.    IN NS    ns1.example.com.
example.com.    IN NS    ns2.example.com.
```

### DNS Lookup

```python
# Python DNS lookup
import socket

# Get IP from hostname
ip = socket.gethostbyname('example.com')
print(f"IP: {ip}")

# Get all IP addresses
ips = socket.getaddrinfo('example.com', 80)
for ip in ips:
    print(ip)

# Using dnspython
import dns.resolver

# Query A record
result = dns.resolver.resolve('example.com', 'A')
for ip in result:
    print(ip.address)

# Query MX record
mx = dns.resolver.resolve('example.com', 'MX')
for record in mx:
    print(f"Priority: {record.preference}, Server: {record.exchange}")
```

### DNS Configuration

```yaml
# Kubernetes DNS policy
# /etc/resolv.conf
nameserver 10.96.0.10
search namespace.svc.cluster.local svc.cluster.local cluster.local
options ndots:5

# CoreDNS configuration
Corefile:
  .:53 {
    forward . 8.8.8.8 8.8.4.4
    cache 30
    log
  }
  
  example.com:53 {
    file db.example.com
    log
  }
```

### Using dig

```bash
# Basic lookup
dig example.com

# Query specific record type
dig example.com A
dig example.com MX
dig example.com TXT

# Trace DNS resolution
dig +trace example.com

# Query specific nameserver
dig @8.8.8.8 example.com

# Reverse lookup
dig -x 192.168.1.1
```

## Anti-Patterns

### 1. Single Nameserver

```yaml
# BAD - Single point of failure
nameserver: 8.8.8.8

# GOOD - Multiple nameservers
nameservers:
  - 8.8.8.8
  - 8.8.4.4
```

### 2. Long TTLs for Dynamic Records

```yaml
# BAD - Can't update quickly
example.com. 3600 IN A 1.2.3.4

# GOOD - Short TTL for dynamic
example.com 60 IN A 1.2.3.4
```

## Failure Modes

- **Single nameserver dependency** → DNS resolution failure → complete service outage → deploy multiple nameservers across providers
- **Long TTL on dynamic records** → slow failover → extended downtime during IP changes → use short TTLs for records that change frequently
- **DNS cache poisoning** → users redirected to malicious sites → credential theft → implement DNSSEC validation
- **Zone transfer misconfiguration** → full zone exposed → reconnaissance data for attackers → restrict zone transfers to authorized secondaries only
- **Missing DNS monitoring** → resolution failures undetected → silent service degradation → monitor DNS response times and error rates
- **DNSSEC key mismanagement** → validation failures → legitimate domains unreachable → automate key rotation with overlap periods
- **Recursive resolver abuse** → DNS amplification attacks → network congestion → disable open recursion and implement response rate limiting

## Best Practices

### DNSSEC

```bash
# Enable DNSSEC validation
# In bind named.conf
options {
    dnssec-validation auto;
    dnssec-lookaside auto;
};
```

### DNS Security

```python
# Python - Validate DNSSEC
import dns.resolver

result = dns.resolver.resolve('example.com', 'A', raise_on_no_answer=False)
if result.response.rcode() == 0:
    print("DNSSEC validation successful")
```

### Caching Strategy

```python
# Local DNS cache with TTL
class DNSCache:
    def __init__(self):
        self.cache = {}
    
    def get(self, hostname):
        if hostname in self.cache:
            ip, expires = self.cache[hostname]
            if time.time() < expires:
                return ip
            del self.cache[hostname]
        
        # Fetch and cache
        ip = socket.gethostbyname(hostname)
        self.cache[hostname] = (ip, time.time() + 300)  # 5 min TTL
        return ip
```

## Related Topics

- [[Network MOC]]
- [[NetworkSecurity]]
- [[CloudComputing]]
- [[RateLimiting]]
- [[Firewall]]

## Additional Notes

**DNS Record Types:**
- A - IPv4 address
- AAAA - IPv6 address
- CNAME - Canonical name (alias)
- MX - Mail exchange
- TXT - Text records
- NS - Nameservers
- SOA - Start of authority
- PTR - Reverse lookup

**Common DNS Providers:**
- Cloudflare
- Route 53 (AWS)
- Google Cloud DNS
- Azure DNS

**Troubleshooting:**
- `dig` - Query DNS
- `nslookup` - Lookup information
- `traceroute` - Trace route
- `host` - DNS lookup