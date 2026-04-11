---
title: Zero Trust
title_pt: Zero Trust
layer: security
type: concept
priority: high
version: 1.0.0
tags:
  - Security
  - ZeroTrust
  - Architecture
description: Security model that assumes no implicit trust.
description_pt: Modelo de segurança que não assume confiança implícita.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Zero Trust

## Description

Zero Trust is a security model that assumes no implicit trust - every request must be verified, regardless of whether it comes from inside or outside the network.

Principles:
- Never trust, always verify
- Assume breach
- Verify explicitly
- Least privilege access
- Continuous verification

## Purpose

**When Zero Trust is valuable:**
- For perimeter-less environments (cloud, remote work)
- For organizations with sensitive data
- When traditional VPN-based security is insufficient
- For compliance requirements

**When traditional security may suffice:**
- Small, simple networks
- On-premise only environments
- Limited attack surface

**The key question:** Should we trust this request based on its origin, or verify every time?

## Examples

```python
# Zero Trust implementation
def verify_request(request, context):
    # Verify identity
    if not verify_identity(request.token):
        return False
    
    # Verify device
    if not verify_device(request.device):
        return False
    
    # Verify location
    if not verify_location(request.location):
        return False
    
    # Verify behavior
    if not verify_behavior(request):
        return False
    
    return True
```

## Failure Modes

- **Trust based on network location** → internal network traffic not verified → lateral movement after perimeter breach → verify every request regardless of source network location
- **Incomplete micro-segmentation** → large network segments allow lateral movement → attacker moves freely after initial breach → implement fine-grained network segmentation with per-service policies
- **Continuous verification not implemented** → one-time authentication at login → compromised sessions go undetected → implement continuous authentication with behavioral analysis and session monitoring
- **Zero Trust without user experience planning** → excessive verification frustrates users → workarounds that bypass security → balance security with usability through risk-based adaptive authentication
- **Missing device health verification** → compromised devices granted access → malware on trusted device → verify device health, patch level, and security posture before granting access
- **Encryption gaps in internal traffic** → internal service communication unencrypted → eavesdropping on internal network → encrypt all traffic including internal service-to-service communication
- **Zero Trust as technology purchase only** → buying tools without changing processes → old habits persist with new tools → combine technology with process changes and security culture transformation

## Related Topics

- [[Security MOC]]
- [[IAM]]
- [[NetworkSecurity]]
- [[ServiceMesh]]
- [[Firewall]]

## Anti-Patterns

### 1. Trust Based on Network Location

**Bad:** Treating all traffic from the internal network as trusted while only verifying external requests
**Why it's bad:** Once an attacker breaches the perimeter (phishing, compromised device), they move laterally without resistance — the internal network becomes a free-for-all
**Good:** Verify every request regardless of source — internal traffic should be authenticated and authorized just like external traffic

### 2. Zero Trust as a Technology Purchase

**Bad:** Buying Zero Trust tools (micro-segmentation software, identity providers) without changing processes or security culture
**Why it's bad:** The tools are configured to replicate old trust assumptions — you have new technology with old habits, and the security posture is unchanged
**Good:** Combine technology with process changes — update incident response, access review processes, and security training alongside tool deployment

### 3. Missing Device Health Verification

**Bad:** Granting access based on identity alone without verifying the device's security posture
**Why it's bad:** A valid user on a compromised, unpatched, or jailbroken device becomes an attack vector — identity verification without device verification is incomplete
**Good:** Verify device health, patch level, encryption status, and security software before granting access — deny or restrict access for non-compliant devices

### 4. Zero Trust Without UX Planning

**Bad:** Implementing continuous verification that prompts users for credentials every few minutes
**Why it's bad:** Users become frustrated and find workarounds — shadow IT, shared accounts, or disabling security features — the security model collapses under user resistance
**Good:** Balance security with usability through risk-based adaptive authentication — low-risk actions are seamless, high-risk actions require additional verification

## Best Practices

1. **Verify every request** - No trust based on location
2. **Implement micro-segmentation** - Limit lateral movement
3. **Use strong authentication** - MFA for all access
4. **Monitor continuously** - Detect anomalies in real-time
5. **Encrypt all traffic** - Both internal and external

## Key Takeaways

- Zero Trust assumes no implicit trust—every request must be verified regardless of origin, following "never trust, always verify"
- Valuable for perimeter-less environments (cloud, remote work), organizations with sensitive data, or when VPN-based security is insufficient
- Traditional security may suffice for small simple networks, on-premise only environments, or limited attack surfaces
- Tradeoff: comprehensive security through continuous verification versus implementation complexity and potential user experience friction
- Main failure mode: trusting based on network location allows lateral movement after perimeter breach since internal traffic goes unverified
- Best practice: verify every request regardless of source, implement micro-segmentation to limit lateral movement, use MFA for all access, verify device health before granting access, encrypt all traffic including internal service-to-service, and balance security with usability through risk-based adaptive authentication
- Related: IAM, network security, service mesh, firewall