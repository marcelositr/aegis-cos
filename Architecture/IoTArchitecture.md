---
title: IoT Architecture
title_pt: Arquitetura IoT
layer: architecture
type: concept
priority: medium
version: 1.0.0
tags:
  - Architecture
  - IoT
  - Internet of Things
description: Architecture for Internet of Things systems.
description_pt: Arquitetura para sistemas de Internet das Coisas.
prerequisites:
  - EdgeComputing
  - Serverless
---

# IoT Architecture

## Description

IoT architecture describes how devices, sensors, and cloud services communicate and process data. It typically includes:
- **Device Layer** - Sensors and actuators
- **Edge Layer** - Local processing
- **Cloud Layer** - Backend services
- **Application Layer** - User interfaces

## Purpose

**When this is valuable:**
- Building large-scale sensor networks
- Real-time monitoring systems
- Industrial automation
- Smart city infrastructure

**When this may not be needed:**
- Simple single-device applications
- Non-connected embedded systems
- When basics are well understood

**The key question:** How do we reliably collect, process, and act on data from thousands of distributed devices?

## Examples

### Smart Building System

```python
class TemperatureSensor:
    def __init__(self, device_id: str):
        self.device_id = device_id
    
    def read(self) -> dict:
        return {
            "device_id": self.device_id,
            "temperature": get_temperature(),
            "timestamp": get_timestamp()
        }

class EdgeGateway:
    def __init__(self):
        self.sensors = []
    
    def collect(self) -> dict:
        readings = [s.read() for s in self.sensors]
        avg = sum(r['temperature'] for r in readings) / len(readings)
        return {"avg_temperature": avg, "count": len(readings)}
    
    def send_to_cloud(self, data):
        cloud_client.publish("building/temperature", data)
```

### MQTT Message Flow

```
Device → MQTT Broker → Edge Processing → Cloud Storage
         (mosquitto)    (filter/aggregate)  (TimeSeries DB)
```

## Failure Modes

- **Unauthenticated device connections** → rogue devices join network and inject false data → system integrity compromised → implement device certificates, mutual TLS, and hardware-based identity
- **Protocol mismatch causing data loss** → MQTT QoS 0 used for critical telemetry → messages silently dropped → use QoS 1 or 2 for critical data and implement application-level acknowledgments
- **Firmware update failures bricking devices** → OTA update interrupted mid-flash → device becomes unrecoverable → use A/B partition updates with rollback capability
- **Battery exhaustion from excessive transmissions** → devices send data too frequently → premature battery death → implement adaptive reporting intervals and edge-side data aggregation
- **Scale limitations from centralized architecture** → all device traffic routes through single broker → broker becomes bottleneck → use hierarchical broker topology with edge gateways
- **No device lifecycle management** → cannot provision, monitor, or decommission devices at scale → orphaned devices and security gaps → implement device registry with health monitoring
- **Insecure default credentials on devices** → factory passwords never changed → botnet recruitment → enforce credential rotation on first boot

## Anti-Patterns

### 1. Cloud-First Everything

**Bad:** Sending all raw sensor data to the cloud for processing, even simple threshold checks
**Why it's bad:** Wastes bandwidth, increases latency, raises cloud costs, and fails when connectivity drops
**Good:** Process simple rules at the edge (e.g., alert if temperature > threshold) and only send aggregated or anomalous data to the cloud

### 2. Polling Instead of Event-Driven

**Bad:** Devices constantly polling a server for updates on a fixed interval
**Why it's bad:** Drains battery, wastes network bandwidth, and introduces unnecessary latency for time-critical commands
**Good:** Use publish/subscribe protocols like MQTT where devices subscribe to topics and receive messages pushed to them

### 3. Homogeneous Device Assumption

**Bad:** Designing architecture that assumes all devices have the same capabilities, connectivity, and power sources
**Why it's bad:** Real IoT deployments mix battery-powered sensors, mains-powered gateways, and devices with varying protocol support
**Good:** Design for heterogeneity — abstract device capabilities, support multiple protocols, and handle graceful degradation for low-power devices

### 4. Ignoring Device Lifecycle

**Bad:** Provisioning devices once and never managing firmware updates, credential rotation, or decommissioning
**Why it's bad:** Devices become security liabilities, drift from expected behavior, and orphaned devices consume resources
**Good:** Implement full device lifecycle management: provisioning, monitoring, OTA updates, and secure decommissioning

### 5. Flat Network Topology

**Bad:** All devices connect directly to a central cloud broker with no hierarchy
**Why it's bad:** Single point of failure, doesn't scale beyond thousands of devices, and all traffic traverses the WAN
**Good:** Use hierarchical topology with edge gateways aggregating local devices and forwarding to regional cloud brokers

## Best Practices

1. **Process at edge when possible** - Reduce latency and bandwidth
2. **Use appropriate protocols** - MQTT for devices, HTTP for cloud
3. **Implement secure provisioning** - TLS, certificates for devices
4. **Plan for offline** - Buffer data when connectivity fails
5. **Monitor device health** - Battery, connectivity, error rates

## Related Topics

- [[Architecture MOC]]
- [[EdgeComputing]]
- [[MessageQueues]]
- [[EventArchitecture]]
- [[SecureCoding]]

## Key Takeaways

- IoT architecture connects devices, sensors, and cloud services across device, edge, cloud, and application layers for reliable data collection and action
- Essential for large-scale sensor networks, real-time monitoring, industrial automation, and smart city infrastructure
- Avoid for simple single-device applications or non-connected embedded systems
- Tradeoff: distributed intelligence and real-time response versus device management complexity, security surface area, and protocol heterogeneity
- Main failure mode: unauthenticated device connections allow rogue devices to inject false data and compromise system integrity
- Best practice: process at edge when possible, use MQTT for devices with appropriate QoS levels, implement mutual TLS provisioning, and manage full device lifecycle including OTA updates
- Related: edge computing, message queues, event-driven architecture, security

## Additional Notes