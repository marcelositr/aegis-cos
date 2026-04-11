---
title: Information Theory
title_pt: Teoria da Informação
layer: foundations
type: concept
priority: high
version: 1.0.0
tags:
  - Foundations
  - InformationTheory
description: Study of quantification, storage, and communication of information.
description_pt: Estudo de quantificação, armazenamento e comunicação de informação.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Information Theory

## Description

Information theory studies how information can be quantified, stored, and communicated. It provides mathematical framework for understanding:
- Data compression
- Channel capacity
- Error detection/correction
- Entropy

Key concepts:
- **Entropy**: Measure of uncertainty/information (bits)
- **Channel capacity**: Maximum data rate
- **Redundancy**: Repetition for reliability
- **Encoding**: Converting data for transmission



## Purpose

**When this is valuable:**
- For understanding and applying the concept
- For making architectural decisions
- For team communication

**When this may not be needed:**
- For quick reference
- For simple implementations
- When basics are well understood

**The key question:** How does this concept help us build better software?

## Entropy

```python
import math
from collections import Counter

def calculate_entropy(text: str) -> float:
    """Calculate Shannon entropy in bits."""
    if not text:
        return 0
    
    # Count frequencies
    freq = Counter(text)
    length = len(text)
    
    # Calculate entropy
    entropy = 0
    for count in freq.values():
        p = count / length
        entropy -= p * math.log2(p)
    
    return entropy

# Example
text = "hello world"
entropy = calculate_entropy(text)
print(f"Entropy: {entropy:.2f} bits")

# Higher entropy = more random = more information
# Lower entropy = more predictable = less information
```

## Compression

```python
import zlib
import base64

def compress_data(data: str) -> bytes:
    """Compress using zlib (DEFLATE)."""
    return zlib.compress(data.encode('utf-8'))

def decompress_data(data: bytes) -> str:
    """Decompress zlib-compressed data."""
    return zlib.decompress(data).decode('utf-8')

def compression_ratio(original: str, compressed: bytes) -> float:
    """Calculate compression ratio."""
    return len(compressed) / len(original)

# Usage
text = "aaaaaaaaaabbbbbccccc"
compressed = compress_data(text)
ratio = compression_ratio(text, compressed)
print(f"Compressed to {ratio:.1%} of original size")
```

## Error Detection

```python
def parity_bit(data: str) -> str:
    """Add parity bit for odd parity."""
    ones = data.count('1')
    parity = '1' if ones % 2 == 0 else '0'
    return data + parity

def verify_parity(data_with_parity: str) -> bool:
    """Verify odd parity."""
    data = data_with_parity[:-1]
    parity = data_with_parity[-1]
    ones = data.count('1')
    expected = '1' if ones % 2 == 0 else '0'
    return parity == expected

# Example
data = "1011001"
data_with_parity = parity_bit(data)
print(f"Original: {data}")
print(f"With parity: {data_with_parity}")
print(f"Valid: {verify_parity(data_with_parity)}")
```

## Anti-Patterns

### 1. Compressing High-Entropy Data

**Bad:** Running compression algorithms on already-encrypted data, random bytes, or compressed formats like JPEG
**Why it's bad:** Compression adds overhead to incompressible data — the output is larger than the input, wasting CPU and storage
**Good:** Check data entropy before compression and skip it for high-entropy data; use compression only on low-entropy data like text

### 2. Lossy Compression for Critical Data

**Bad:** Using lossy compression (JPEG, MP3) on data that must be reconstructed exactly, like financial records or executable code
**Why it's bad:** Information is permanently lost — the decompressed output differs from the original, causing data integrity failures
**Good:** Use lossless compression (DEFLATE, LZ4, zstd) for any data where exact reconstruction is required

### 3. Ignoring Error Detection in Transmission

**Bad:** Sending data over networks or storing it on disk without checksums, CRCs, or parity bits
**Why it's bad:** Silent bit flips, network corruption, and disk errors go undetected — corrupted data is processed as if it were valid
**Good:** Always include error detection (checksums, CRCs, HMACs) for data in transit and at rest, especially for critical systems

### 4. Insufficient Entropy in Security Contexts

**Bad:** Using low-entropy random number generators (like `rand()` or `Math.random()`) for security tokens, keys, or salts
**Why it's bad:** Predictable random values make cryptographic systems trivially breakable — attackers can guess tokens and forge signatures
**Good:** Use cryptographically secure random number generators (`/dev/urandom`, `secrets` module, `crypto.randomBytes`) for all security-related randomness

## Best Practices

### 1. Understand Your Data

```python
# Not all data compresses well
random_data = os.urandom(1000)  # Won't compress
repeated_data = b"a" * 1000     # Compresses very well
```

### 2. Choose Right Encoding

```python
# Text encoding
utf8 = "hello".encode('utf-8')  # Variable length
ascii = "hello".encode('ascii') # Fixed for ASCII

# Binary protocols
# Protocol buffers, MessagePack for efficiency
```

### 3. Consider Channel Characteristics

```python
# Noisy channel? Add redundancy
# Reliable channel? Minimize overhead
```

## Failure Modes

- **Compressing already-encrypted or random data** → compression algorithm adds overhead → larger output than input → check data entropy before compression and skip for high-entropy data
- **Lossy compression for critical data** → using lossy algorithms on data that must be exact → data corruption and integrity failures → use lossless compression for any data where exact reconstruction is required
- **Ignoring error detection in transmission** → sending data without checksums or parity → silent corruption goes undetected → always include error detection for data in transit or storage
- **Channel capacity miscalculation** → assuming theoretical maximum throughput → network congestion and packet loss → account for protocol overhead, retransmissions, and real-world conditions
- **Insufficient entropy in random generation** → low-entropy random values for security purposes → predictable keys and tokens → use cryptographically secure random number generators for security-related randomness
- **Encoding mismatch causing data corruption** → interpreting UTF-8 as ASCII or vice versa → garbled text and parsing failures → explicitly declare and validate character encoding at all system boundaries
- **Not accounting for compression ratio variability** → sizing storage based on average compression → storage overflow with incompressible data → plan for worst-case storage requirements

## Related Topics

- [[Foundations MOC]]
- [[Complexity]]
- [[Computability]]
- [[DataStructures]]
- [[CryptographyBasics]]

## Key Takeaways

- Information theory provides the mathematical framework for quantifying, storing, and communicating information through entropy, compression, and error detection
- Valuable for understanding data compression limits, designing reliable communication systems, and ensuring sufficient entropy in security contexts
- Less relevant for routine application development where built-in libraries handle encoding and compression transparently
- Tradeoff: optimal data efficiency and reliability versus computational overhead and implementation complexity
- Main failure mode: insufficient entropy in random number generation for security contexts produces predictable keys and tokens that attackers can exploit
- Best practice: check data entropy before compressing, use lossless compression for exact-reconstruction requirements, always include error detection for data in transit, and use cryptographically secure RNGs for security-related randomness
- Related: complexity, computability, data structures, cryptography basics

## Additional Notes

## Examples

### Entropy in Practice

```python
# High entropy (hard to compress)
random_bytes = bytes([random.randint(0, 255) for _ in range(1000)])
# Entropy ~ 8 bits per byte (maximum)

# Low entropy (compresses well)
repeated_bytes = b"A" * 1000
# Entropy ~ 0.1 bits per byte
```

### Compression Tradeoffs

```python
# Text files compress well (low entropy)
# Binary files compress poorly (high entropy)
# Images: PNG (lossless), JPEG (lossy) - different use cases
```
