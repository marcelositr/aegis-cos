---
title: Portability
title_pt: Portabilidade
layer: quality
type: concept
priority: high
version: 2.0.0
tags:
  - Quality
  - Portability
  - Compatibility
  - CrossPlatform
  - Containers
description: The degree to which software can be transferred from one environment to another -- OS, architecture, cloud provider, runtime version -- without modification.
description_pt: O grau em que software pode ser transferido de um ambiente para outro -- SO, arquitetura, provedor de nuvem, versao de runtime -- sem modificacao.
prerequisites:
  - [[Architecture]]
  - [[DevOps]]
estimated_read_time: 15 min
difficulty: intermediate
---

# Portability

## Description

Portability measures how much effort is required to move software from one execution environment to another. An environment is defined by:

- **Operating system**: Linux, macOS, Windows, FreeBSD
- **CPU architecture**: x86_64, ARM64, RISC-V
- **Runtime version**: Node.js 18 vs. 20, Python 3.11 vs. 3.12, JVM 17 vs. 21
- **Cloud provider**: AWS, GCP, Azure, on-premises
- **Dependency ecosystem**: Package managers, system libraries, kernel features

Portability exists on a spectrum:

| Level | Description | Example |
|---|---|---|
| **Source portable** | Compiles/runs on multiple platforms from the same source | Go, Rust, Java (with JVM) |
| **Binary portable** | Same binary runs on multiple platforms | WebAssembly, statically-linked Go binaries |
| **Container portable** | Same container image runs anywhere with a container runtime | Docker images on any OCI-compatible runtime |
| **Infrastructure portable** | Same deployment manifests work across cloud providers | Kubernetes YAML on EKS, GKE, AKS |
| **Cloud portable** | Same code deploys to multiple clouds without modification | Multi-cloud serverless (rarely achieved) |

Full portability (write once, run anywhere) is a myth in practice. Every abstraction layer leaks at the edges. The goal is **pragmatic portability**: portable where it matters, platform-specific where it provides value.

Portability failures are among the most expensive bugs because they are discovered late -- at deployment time, often on production-adjacent infrastructure. "Works on my machine" is a portability failure.

## When to Use

- **Open-source software**: Users run on diverse platforms. Portable software reaches a wider audience. Non-portable software excludes potential users and contributors.
- **Multi-cloud or cloud-agnostic strategies**: Organizations that want to avoid vendor lock-in must write portable infrastructure code (Terraform with multiple providers, Kubernetes over managed services).
- **Cross-platform applications**: Desktop apps (Electron, Tauri), mobile apps (React Native, Flutter), and CLIs that must run on Linux, macOS, and Windows.
- **Edge computing**: Code deployed to edge locations (Cloudflare Workers, AWS Lambda@Edge) runs on different hardware and OS than the central infrastructure.
- **Embedded and IoT**: Software must run on ARM devices with varying Linux kernel versions, limited resources, and different filesystem layouts.
- **Long-lived systems**: Software expected to run for 5+ years must survive OS upgrades, runtime deprecations, and hardware migrations (e.g., AWS Graviton, Apple Silicon).

## When NOT to Use

- **Platform-specific optimizations outweigh portability needs**: A CUDA kernel for NVIDIA GPUs is inherently non-portable but provides 10-100x speedups over portable alternatives. Accept non-portability when the performance payoff is quantified.
- **Internal tools with a single deployment target**: A CI pipeline that only runs on GitHub Actions (Ubuntu) does not need to support Windows or macOS. The portability investment has no return.
- **When cloud-native features provide significant value**: Using AWS DynamoDB Streams, GCP Pub/Sub, or Azure Service Bus directly (instead of abstracting behind a portable interface) reduces complexity and leverages platform capabilities. The lock-in is intentional and valuable.
- **Prototypes and proofs-of-concept**: Portability is a production concern. Prototyping on a single platform is faster. Add portability when the prototype graduates to production.
- **When the portability abstraction is leaky and expensive**: A "universal cloud SDK" that only covers 70% of each cloud provider's features forces developers to drop through the abstraction for the remaining 30%, learning both the abstraction and the native APIs. The abstraction costs more than it saves.

## Tradeoffs

| Aspect | High Portability | Low Portability (Platform-Specific) |
|---|---|---|
| Development cost | Higher: test on multiple platforms, abstract platform differences | Lower: use platform features directly |
| Market reach | Wider: runs on more platforms | Narrower: tied to specific platform |
| Performance | May sacrifice platform-specific optimizations | Can use platform-specific optimizations |
| Vendor lock-in | Low: can migrate between platforms | High: migration requires rewrite |
| Testing complexity | Higher: test matrix grows with platforms | Lower: single platform to test |
| Maintenance | Higher: keep multiple platform paths working | Lower: one platform to maintain |
| Cloud costs | May pay for abstraction layer overhead | Direct use of cheapest platform options |
| Team expertise | Broader: understand multiple platforms | Deeper: expert in one platform |

The central decision is **strategic**: is platform independence a business requirement (e.g., selling software to enterprises with heterogeneous infrastructure), or is it an engineering preference? If the business only deploys to AWS, investing in cloud portability is insurance against a scenario that may never occur.

## Alternatives

- **Containers (OCI)**: Package the application with its runtime dependencies. The container is the portability unit. Works across any OCI-compatible runtime (Docker, containerd, Podman, Kubernetes). This is the dominant portability strategy for server-side applications.
- **WebAssembly (Wasm)**: Portable binary format that runs in a sandboxed runtime. Emerging for server-side work (Wasmtime, WasmEdge) and dominant for browser-side plugins. Provides near-universal portability with performance close to native.
- **Virtual machines**: Full OS virtualization provides maximum isolation but heavy resource usage. Largely superseded by containers for application portability, but still used for full environment portability (Vagrant, Packer).
- **Cross-platform frameworks**: Electron, Qt, Flutter abstract OS differences for desktop/mobile apps. Trade native performance and look-and-feel for single-codebase portability.
- **Cloud abstraction layers**: Terraform, Pulumi, Crossplane provide portable infrastructure definitions. Trade platform-specific feature access for multi-cloud capability.
- **Accept lock-in**: Intentionally use platform-specific features (AWS Lambda, GCP BigQuery, Azure Functions) because the capabilities outweigh the lock-in cost. Document the lock-in explicitly.

## Failure Modes

1. **Path separator and case sensitivity assumptions**: Code using `C:\Users\app\data` or `src/Config.ts` (capitalized) works on Windows (case-insensitive, backslash paths) but fails on Linux (case-sensitive, forward slash paths). The CI runs on Ubuntu and passes; the customer's Windows server fails. Mitigation: use `path.join()` or `path/filepath` for all path construction. Test on case-sensitive filesystems. Use lowercase-only filenames.

2. **Architecture-specific assumptions (x86 vs. ARM)**: Code assuming little-endian byte order, specific alignment, or x86-specific intrinsics fails on ARM64 (AWS Graviton, Apple Silicon). Docker images built for `linux/amd64` fail to pull on ARM runners. Mitigation: use multi-arch builds (`docker buildx build --platform linux/amd64,linux/arm64`). Avoid architecture-specific code or guard it with `#ifdef`/`cfg(target_arch)`. Test on ARM CI runners.

3. **System library version dependencies**: Application links against `libssl.so.1.1` which is available on Ubuntu 20.04 but removed in 22.04 (replaced by `libssl.so.3`). The application fails to start on newer systems. Mitigation: statically link critical libraries, or bundle them with the application. Use containers to fix the dependency tree. Document minimum system requirements.

4. **Shell script non-portability**: A `#!/bin/bash` script using `[[ ]]`, `source`, and process substitution (`<(cmd)`) works in bash but fails in `/bin/sh` (dash on Ubuntu, ash in Alpine). Mitigation: use `#!/usr/bin/env bash` and document the bash requirement, or write POSIX-compliant `sh` scripts. Better: replace shell scripts with Python/Go for cross-platform reliability.

5. **Environment variable assumptions**: Code relying on `$HOME`, `$USER`, or `$PATH` fails in minimal container images (distroless, scratch) where these are unset. Code using `os.tmpdir()` returns `/tmp` on Linux but `C:\Users\...\AppData\Local\Temp` on Windows. Mitigation: never assume environment variables in containers; set them explicitly in the Dockerfile. Use language-standard paths (`os.tmpdir()`, `Path.GetTempPath()`) not hardcoded `/tmp`.

6. **File permission and ownership assumptions**: Code using `chmod 755`, `chown root:root`, or POSIX ACLs works on Linux but fails on Windows (no equivalent permission model) or in rootless containers (no chown capability). Mitigation: abstract file permission operations. Test in rootless container environments. Use language-level file APIs that handle cross-platform differences.

7. **Cloud provider API assumptions hidden as "standard" interfaces**: Code using "S3-compatible" storage works with AWS S3 but fails with MinIO, Ceph, or GCP interoperability because each has subtle differences (pagination format, error codes, multipart upload behavior). The "S3-compatible" abstraction is leaky. Mitigation: test against the actual target storage implementations, not just AWS S3. Use the official SDK for each provider when the "universal" SDK has gaps. Document the tested implementations.

## Code Examples

### Multi-platform Go CLI (no external dependencies)

```go
// main.go -- compiles and runs on Linux, macOS, Windows, ARM, x86_64
// No CGO required, no system library dependencies
package main

import (
    "fmt"
    "os"
    "os/user"
    "path/filepath"
    "runtime"
)

func main() {
    // Cross-platform home directory detection
    homeDir, err := os.UserHomeDir()
    if err != nil {
        // Fallback for minimal environments where UserHomeDir fails
        homeDir = getFallbackHome()
    }

    // Cross-platform path construction
    configPath := filepath.Join(homeDir, ".myapp", "config.yaml")

    fmt.Printf("Platform: %s/%s\n", runtime.GOOS, runtime.GOARCH)
    fmt.Printf("Config: %s\n", configPath)

    // Architecture-specific optimization (optional)
    switch runtime.GOARCH {
    case "amd64":
        runOptimized()
    case "arm64":
        runStandard()
    default:
        runStandard()
    }
}

func getFallbackHome() string {
    // Try $HOME first (works in most Unix environments)
    if home := os.Getenv("HOME"); home != "" {
        return home
    }
    // Try $USERPROFILE (Windows)
    if home := os.Getenv("USERPROFILE"); home != "" {
        return home
    }
    // Last resort: current directory
    dir, _ := os.Getwd()
    return dir
}

func runOptimized() {
    // AMD64-specific optimization (e.g., use specific SIMD instructions)
    fmt.Println("Running with AMD64 optimizations")
}

func runStandard() {
    // Generic implementation
    fmt.Println("Running standard implementation")
}

// Build commands for all platforms:
// GOOS=linux GOARCH=amd64 go build -o myapp-linux-amd64
// GOOS=linux GOARCH=arm64 go build -o myapp-linux-arm64
// GOOS=darwin GOARCH=arm64 go build -o myapp-darwin-arm64
// GOOS=windows GOARCH=amd64 go build -o myapp-windows-amd64.exe
```

### Multi-arch Docker build

```dockerfile
# Dockerfile -- portable application image
FROM --platform=$TARGETPLATFORM golang:1.22-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
# CGO_ENABLED=0 produces a static binary with no libc dependency
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /myapp .

# Minimal runtime image
FROM --platform=$TARGETPLATFORM scratch
COPY --from=builder /myapp /myapp
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# No shell, no package manager, no OS -- just the binary
ENTRYPOINT ["/myapp"]

# Build for multiple architectures:
# docker buildx build --platform linux/amd64,linux/arm64 \
#   -t myorg/myapp:latest --push .
#
# The resulting image works on any OCI-compatible container runtime
# regardless of the host architecture.
```

### Portable infrastructure with Terraform (abstraction over cloud providers)

```hcl
# main.tf -- portable infrastructure definition
# Works with AWS, GCP, or Azure by switching the provider configuration

variable "cloud_provider" {
  type    = string
  default = "aws"
  validation {
    condition     = contains(["aws", "gcp", "azure"], var.cloud_provider)
    error_message = "Supported providers: aws, gcp, azure"
  }
}

# Portable compute abstraction
# Each provider module implements the same interface:
# - A compute instance with the specified CPU and memory
# - A public IP address
# - Health check endpoint

module "compute" {
  source = "./modules/${var.cloud_provider}/compute"

  instance_type  = var.cloud_provider == "aws" ? "t3.medium" : var.cloud_provider == "gcp" ? "e2-medium" : "Standard_B2s"
  cpu_cores      = 2
  memory_gb      = 4
  base_image     = var.cloud_provider == "aws" ? "ami-0c55b159cbfafe1f0" : null
  machine_type   = var.cloud_provider == "gcp" ? "e2-medium" : null
  vm_size        = var.cloud_provider == "azure" ? "Standard_B2s" : null
}

# Portable storage abstraction
module "storage" {
  source = "./modules/${var.cloud_provider}/storage"

  bucket_name  = "myapp-data-${var.environment}"
  region       = var.region
  encryption   = true
  versioning   = true
}

# The provider-specific modules implement the same outputs:
# module.compute.outputs: instance_id, public_ip, health_check_url
# module.storage.outputs: bucket_url, access_key, secret_key
#
# The application code uses these outputs, not provider-specific identifiers.
```

## Best Practices

- **Use containers as the portability unit**: Package the application with its runtime dependencies in OCI containers. This eliminates most OS-level and library-level portability issues. Use multi-arch builds for ARM and x86_64 support.
- **Test on every target platform**: Do not assume portability. Run CI on Linux, macOS, and Windows (GitHub Actions provides all three). Test on ARM runners if targeting ARM (AWS Graviton, Apple Silicon).
- **Abstract at the right layer**: Abstract cloud provider APIs only if multi-cloud is a business requirement. Abstracting OS differences (via containers or cross-platform languages) is almost always worthwhile. Abstracting database differences is worthwhile if you genuinely support multiple databases.
- **Avoid platform-specific code unless justified**: When you must use a platform-specific feature (e.g., Windows Registry, Linux-specific syscalls), isolate it behind a platform-independent interface and document the limitation prominently.
- **Use language ecosystems with strong cross-platform support**: Go, Rust, Java, and Python compile/run on most platforms. Node.js is cross-platform but has native module issues (rebuild for each platform). C/C++ requires the most portability effort.
- **Document platform requirements explicitly**: State the supported OS versions, architectures, runtime versions, and system dependencies. A "Supported Platforms" section in the README is a portability contract.
- **Plan for platform migration**: Hardware migrations happen every 5-7 years (x86 to ARM, on-prem to cloud). Software outlives its original platform. Design with the assumption that the platform will change.
- **Use feature detection, not platform detection**: Instead of `if OS == 'windows'`, check for the specific capability you need: `if supports_symlinks()`. This handles edge cases (e.g., WSL on Windows, Cygwin, minimal containers) that platform detection misses.

## Related Topics

- [[Architecture]] -- system design decisions affecting portability (microservices vs. monolith, cloud-native patterns)
- [[DevOps]] -- container images, CI/CD pipeline portability, multi-arch builds
- [[Configuration]] -- environment-specific configuration as a portability mechanism
- [[Security]] -- security implications of portable vs. platform-specific code
- [[QualityGates]] -- portability testing as a gate in the deployment pipeline
- [[Performance]] -- tradeoff between portable code and platform-optimized performance
- [[DeveloperExperience]] -- portable development environments (devcontainers, Docker Compose)
- [[Composability]] -- portable components that compose across environments
- [[TypeSafety]] -- type systems as a portability mechanism (compile-time guarantees across platforms)
