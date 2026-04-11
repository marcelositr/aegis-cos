---
title: Network MOC
title_pt: Rede — Mapa de Conteúdo
layer: network
type: index
version: 1.0.0
tags:
  - Network
  - MOC
  - Index
description: Navigation hub for networking protocols, web technologies, and network security.
description_pt: Hub de navegação para protocolos de rede, tecnologias web e segurança de rede.
---

# Network MOC

## Protocols

- [[HTTP]] — Hypertext Transfer Protocol — foundation of web communication
- [[HTTPS]] — HTTP over TLS — encrypted web communication
- [[REST]] — Representational State Transfer — architectural style for web APIs
- [[WebSockets]] — Full-duplex communication channels over a single TCP connection
- [[DNS]] — Domain Name System — translating domain names to IP addresses

## Infrastructure

- [[LoadBalancing]] — Distributing traffic across multiple servers
- [[CDN]] — Content Delivery Networks for edge caching
- [[NetworkSecurity]] — Protecting network infrastructure
- [[Firewall]] — Network security system that monitors and controls traffic
- [[VPN]] — Virtual Private Network — secure tunnel over public networks

## Reasoning Path

1. Understand transport: [[HTTP]] → [[HTTPS]] → [[DNS]]
2. Design APIs: [[REST]] → [[WebSockets]] for real-time
3. Scale: [[LoadBalancing]] → [[CDN]] → [[PerformanceOptimization]]
4. Secure: [[NetworkSecurity]] → [[Firewall]] → [[VPN]]

## Cross-Domain Links

- [[HTTP]] → [[REST]] → [[APIDesign]]
- [[HTTPS]] → [[TlsSsl]] → [[CryptographyBasics]]
- [[REST]] → [[APIDesign]] → [[GraphQLArchitecture]]
- [[WebSockets]] → [[RealTimeArchitecture]] → [[EventArchitecture]]
- [[LoadBalancing]] → [[DistributedSystems]] → [[AutoScaling]]
- [[CDN]] → [[PerformanceOptimization]] → [[Caching]]
- [[DNS]] → [[CloudComputing]] → [[RateLimiting]]
- [[NetworkSecurity]] → [[Firewall]] → [[ZeroTrust]] → [[SecurityHeaders]]
- [[VPN]] → [[TlsSsl]] → [[NetworkSecurity]]
- [[HTTP]] → [[Caching]] → [[PerformanceOptimization]]
