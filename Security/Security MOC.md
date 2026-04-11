---
title: Security MOC
title_pt: Segurança — Mapa de Conteúdo
layer: security
type: index
version: 1.0.0
tags:
  - Security
  - MOC
  - Index
description: Navigation hub for application security, authentication, cryptography, and vulnerability management.
description_pt: Hub de navegação para segurança de aplicações, autenticação, criptografia e gerenciamento de vulnerabilidades.
---

# Security MOC

## Authentication & Authorization

- [[Authentication]] — Verifying identity of users and systems
- [[Authorization]] — Controlling what authenticated users can access
- [[IAM]] — Identity and Access Management for managing user identities and permissions
- [[OAuth2]] — Authorization framework for delegated access
- [[OpenIDConnect]] — Authentication layer on top of OAuth2
- [[JWTTokens]] — Compact, URL-safe tokens for claims-based authentication

## Vulnerabilities & Attacks

- [[OWASPTop10]] — Ten most critical web application security risks
- [[XSS]] — Cross-Site Scripting — injecting malicious scripts into web pages
- [[SQLInjection]] — Injecting malicious SQL to manipulate databases
- [[CSRF]] — Cross-Site Request Forgery — tricking users into unintended actions
- [[InputValidation]] — Sanitizing and validating all external input

## Security Practices

- [[ThreatModeling]] — Systematically identifying and prioritizing potential threats
- [[SecureCoding]] — Writing code that resists attacks and minimizes vulnerabilities
- [[SecurityAudit]] — Comprehensive evaluation of system security posture
- [[VulnerabilityAssessment]] — Identifying, quantifying, and prioritizing vulnerabilities
- [[PenetrationTesting]] — Simulating attacks to find exploitable weaknesses
- [[SupplyChainSecurity]] — Securing dependencies, build pipelines, and third-party components

## Infrastructure Security

- [[CryptographyBasics]] — Encryption, hashing, and digital signatures fundamentals
- [[TlsSsl]] — Transport Layer Security for encrypted communication
- [[SecurityHeaders]] — HTTP headers that enhance browser-side security
- [[ZeroTrust]] — Security model that trusts no one by default
- [[MemorySafety]] — Preventing memory-related vulnerabilities
- [[SecretsManagement]] — Securely storing and rotating credentials and keys

## Reasoning Path

1. Foundation: [[CryptographyBasics]] → [[TlsSsl]]
2. Identity: [[Authentication]] → [[Authorization]] → [[IAM]]
3. Protocols: [[OAuth2]] → [[OpenIDConnect]] → [[JWTTokens]]
4. Vulnerabilities: [[OWASPTop10]] → [[XSS]] → [[SQLInjection]] → [[CSRF]] → [[InputValidation]]
5. Practices: [[ThreatModeling]] → [[SecureCoding]] → [[SecurityAudit]]
6. Testing: [[VulnerabilityAssessment]] → [[PenetrationTesting]] → [[Fuzzing]]
7. Infrastructure: [[SecurityHeaders]] → [[ZeroTrust]] → [[MemorySafety]] → [[SecretsManagement]]
8. Supply Chain: [[SupplyChainSecurity]]

## Cross-Domain Links

- [[Authentication]] → [[APIDesign]] → [[REST]]
- [[OAuth2]] → [[OpenIDConnect]] → [[JWTTokens]] → [[ApiGateway]] (planned)
- [[OWASPTop10]] → [[InputValidation]] → [[SecureCoding]] → [[Testing]]
- [[XSS]] → [[SecurityHeaders]] → [[HTTPS]]
- [[SQLInjection]] → [[SQL]] → [[DatabaseOptimization]]
- [[CSRF]] → [[SessionManagement]] → [[JWTTokens]]
- [[ThreatModeling]] → [[DistributedSystems]] → [[DistributedSystems]]
- [[SecurityAudit]] → [[VulnerabilityAssessment]] → [[PenetrationTesting]]
- [[TlsSsl]] → [[HTTPS]] → [[NetworkSecurity]]
- [[ZeroTrust]] → [[ServiceMesh]] → [[Firewall]]
- [[MemorySafety]] → [[Concurrency]] → [[CCPP]]
- [[SecretsManagement]] → [[InfrastructureAsCode]] → [[CiCd]]
- [[SupplyChainSecurity]] → [[CiCd]] → [[Docker]]
