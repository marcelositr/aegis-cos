---
title: Reproducibility
layer: foundations
type: concept
priority: high
version: 2.0.0
tags:
  - Foundations
  - Determinism
  - Science
  - DevOps
  - ML
description: The ability to obtain the same results when repeating an experiment or computation with the same inputs -- a cornerstone of engineering rigor.
---

# Reproducibility

## Description

Reproducibility means that running the same computation with the same inputs produces the same outputs, regardless of who runs it, when, or where. It is distinct from (but related to):

- **Repeatability:** Same team, same setup, same results (a weaker guarantee).
- **Replicability:** Different team, different setup, same scientific conclusions (a stronger guarantee).

Reproducibility fails along multiple axes:
1. **Code axis:** Different commit, different dependency versions, different build flags.
2. **Data axis:** Non-deterministic data collection, race conditions in data pipeline, different random seeds.
3. **Environment axis:** Different OS, compiler, library versions, hardware architecture.
4. **Computation axis:** Non-deterministic algorithms (parallel reductions, GPU floating-point ordering, hash iteration).

In ML training, non-reproducibility is compounded by: random weight initialization, data shuffling order, GPU non-determinism (cuDNN nondeterministic algorithms), distributed training gradient aggregation order, and checkpoint restoration imprecision.

## Purpose

**When to use:**
- Scientific research and published results: reviewers and readers must be able to reproduce your results from your paper.
- ML model training pipelines: if you can't reproduce a model's training run, you can't debug it, improve it, or certify it.
- Debugging production incidents: if a bug is not reproducible, it cannot be reliably fixed. Every bug report should include reproduction steps.
- Compliance and auditing: SOX, HIPAA, and FDA-regulated software require reproducible builds and audit trails.
- Model versioning and deployment: you must be able to retrain the exact same model from a checkpoint to verify a production regression.
- Data pipeline validation: ETL pipelines must produce the same output from the same input so that data quality checks are meaningful.
- Security research: vulnerability reproduction is the foundation of patching. A non-reproducible exploit cannot be tested against a fix.

**When NOT to use:**
- Exploratory data analysis where you're trying many approaches and only the final result matters -- strict reproducibility overhead slows iteration.
- Real-time systems where determinism conflicts with latency SLAs (e.g., a load balancer that must distribute traffic based on current state, not a deterministic hash).
- Systems that intentionally use non-determinism for correctness (e.g., randomized consensus like Raft with randomized election timeouts to avoid livelock).
- One-off scripts or ad-hoc analysis where the output is consumed immediately and discarded.
- A/B testing and canary deployments where you intentionally want different behavior between two groups.

## Tradeoffs

| Approach | Reproducibility level | Effort | Overhead | Best for |
|---|---|---|---|---|
| Seed everything | Single-machine, same code | Minimal | Near zero | ML experiments, randomized algorithms |
| Lock dependencies (requirements.txt, lock files) | Same environment family | Low | Low | Application deployments |
| Containerize (Docker) | Same OS, same libs | Medium | Medium | CI/CD, multi-machine reproducibility |
| Pin everything (Nix, Guix) | Bitwise reproducibility | High | High | Research, security-critical builds |
| Record-and-replay (RR, UndoDB) | Instruction-level replay | Medium | 2-20x slowdown | Post-mortem debugging |

**The cost curve is exponential:** each level of reproducibility guarantee costs significantly more in engineering time. The key is matching the guarantee to the stakes.

## Alternatives

- **Deterministic builds without full containerization:** Use lock files (poetry.lock, Cargo.lock, package-lock.json) and hash verification. Lighter than Docker but less portable.
- **Snapshot-based environments:** Take VM or container snapshots before experiments. Cheaper than building from scratch each time but harder to version-control.
- **Data versioning without full pipeline reproducibility:** Use DVC or LakeFS to version data while accepting some pipeline non-determinism. Good tradeoff for ML feature engineering.
- **Statistical verification:** Instead of requiring bitwise identical outputs, require that key metrics are within confidence intervals. Acceptable for ML where minor non-determinism doesn't change conclusions.
- **Shadow execution:** Run the same computation twice and compare. Detects non-reproducibility without preventing it. Used in distributed systems (Byzantine fault tolerance) and competitive programming (judges verify submissions).

## Failure Modes

1. **Unseeded random number generators:** Python's `random`, NumPy's `np.random`, and framework-level RNGs (PyTorch, TensorFlow) each maintain independent state. Seeding one doesn't seed the others. **Mitigation:** Seed all RNGs at process start. In PyTorch:
   ```python
   import torch, numpy as np, random, os
   seed = 42
   random.seed(seed)
   np.random.seed(seed)
   torch.manual_seed(seed)
   torch.cuda.manual_seed_all(seed)
   os.environ['PYTHONHASHSEED'] = str(seed)
   torch.backends.cudnn.deterministic = True
   torch.backends.cudnn.benchmark = False
   ```

2. **Non-deterministic GPU operations:** Atomic additions in cuDNN (used in convolutions, scatter, gather) are non-deterministic because thread scheduling order varies. `torch.sum()` on GPU is non-deterministic for large tensors. **Mitigation:** Set `torch.use_deterministic_algorithms(True)` which replaces non-deterministic ops with deterministic (but slower) variants. Accept the 10-30% performance penalty. For production training, benchmark to decide if determinism is worth the cost.

3. **Parallel reduction non-associativity:** Floating-point addition is not associative: `(a + b) + c != a + (b + c)` due to rounding. When different threads/processes reduce in different orders, results differ. Example: `sum([0.1] * 1000)` gives different results with different chunk sizes. **Mitigation:** Use Kahan summation for exact reproducibility. Or use `math.fsum()` in Python which is exact but O(n). For ML gradients, this typically affects results at the 6th-8th decimal place -- usually acceptable.

4. **Temporal dependencies:** Code that uses `datetime.now()`, `time.time()`, or system clock as input produces different results each run. Example: a cache key that includes the current timestamp. **Mitigation:** Inject time as a dependency. In tests, use a mock clock. In production, use logical timestamps (Lamport clocks) for ordering.

5. **Hash iteration order:** Python's `hash()` is randomized per process (PYTHONHASHSEED). Dictionary iteration order in Python 3.7+ is insertion order, but set iteration order and dict order before 3.7 are non-deterministic. **Mitigation:** Set `PYTHONHASHSEED=0` for reproducibility. Sort dictionary keys before serializing: `json.dumps(data, sort_keys=True)`.

6. **Environment drift:** "Works on my machine" -- the dev environment has library version 1.2.3, production has 1.2.4, and the changelog doesn't mention a behavioral change in the comparison function. **Mitigation:** Use lock files in version control. Pin transitive dependencies. Run CI in the same container image used in production. Use `pip freeze` or `cargo tree --depth=0` in CI to detect drift.

7. **Non-deterministic external services:** Your test calls an API that returns data in a different order, or a database query without ORDER BY returns rows in index order today but hash order after a migration. **Mitigation:** Mock external services in tests. Always specify ORDER BY in SQL queries. Use contract testing (Pact) to detect API changes.

## Code Examples

### Example 1: Fully Reproducible ML Training Run

```python
"""
Reproducible PyTorch training run.
Every run with the same seed, same data, and same hyperparameters
produces bitwise-identical model weights.
"""
import os
import json
import hashlib
import torch
import torch.nn as nn
import numpy as np
import random
from pathlib import Path


def set_seed(seed: int = 42) -> None:
    """Seed all random number generators for reproducibility."""
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    os.environ['PYTHONHASHSEED'] = str(seed)
    # Enforce deterministic algorithms (may be slower)
    torch.use_deterministic_algorithms(True)
    # cuDNN: disable benchmarking (chooses fastest algo, which varies)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False
    # PyTorch DataLoader workers
    torch.manual_seed(seed)


def log_run_config(config: dict, output_dir: Path) -> Path:
    """Log the full run configuration for reproducibility."""
    import subprocess
    
    run_info = {
        **config,
        "python_version": str(tuple(sys.version_info)),
        "torch_version": torch.__version__,
        "cuda_version": torch.version.cuda if torch.cuda.is_available() else None,
        "cudnn_version": torch.backends.cudnn.version() if torch.cuda.is_available() else None,
    }
    
    # Git commit
    try:
        run_info["git_commit"] = subprocess.check_output(
            ["git", "rev-parse", "HEAD"], text=True
        ).strip()
        run_info["git_dirty"] = bool(subprocess.check_output(["git", "status", "--porcelain"]))
    except subprocess.CalledProcessError:
        run_info["git_commit"] = "unknown"
    
    config_path = output_dir / "run_config.json"
    config_path.write_text(json.dumps(run_info, indent=2, sort_keys=True))
    return config_path


def verify_reproducibility(
    train_fn, seed: int = 42, num_runs: int = 2
) -> dict[str, float]:
    """
    Run training multiple times and verify weight-level reproducibility.
    
    train_fn: callable that takes a seed and returns model state_dict
    Returns: dict of metric_name -> max_difference_across_runs
    """
    all_weights = []
    for i in range(num_runs):
        set_seed(seed)
        weights = train_fn(seed)
        all_weights.append(weights)
    
    # Compare all runs to the first
    max_diffs = {}
    for key in all_weights[0]:
        tensors = [w[key].cpu().float() for w in all_weights]
        diffs = [
            (t - tensors[0]).abs().max().item()
            for t in tensors[1:]
        ]
        max_diffs[key] = max(diffs) if diffs else 0.0
    
    overall_max = max(max_diffs.values()) if max_diffs else 0.0
    print(f"Max weight difference across {num_runs} runs: {overall_max:.2e}")
    assert overall_max < 1e-10, f"Non-reproducible! Max diff: {overall_max}"
    return max_diffs


# Usage
config = {
    "seed": 42,
    "epochs": 10,
    "batch_size": 32,
    "learning_rate": 0.001,
    "model": "resnet18",
}

output_dir = Path("runs") / f"seed{config['seed']}"
output_dir.mkdir(parents=True, exist_ok=True)
log_run_config(config, output_dir)

# In CI, run verify_reproducibility to catch non-determinism early
```

### Example 2: Reproducible Build with Nix

```nix
# default.nix -- Reproducible Python environment
# Running `nix-build` always produces the same binary output
# because every dependency is pinned by hash.

{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/a1b2c3d4.tar.gz";
    sha256 = "0abc123def456...";  # Pin the nixpkgs commit
  }) {}
}:

pkgs.python3Packages.buildPythonApplication {
  pname = "my-ml-project";
  version = "1.0.0";
  
  src = ./.;
  
  propagatedBuildInputs = with pkgs.python3Packages; [
    numpy
    pandas
    scikit-learn
    torch
  ];
  
  # Deterministic build
  PYTHONHASHSEED = "0";
  
  checkPhase = ''
    python -c "
import my_project
print('Import successful')
assert my_project.version == '${version}'
"
  '';
}
```

### Example 3: Detecting Non-Determinism in a Data Pipeline

```python
"""
Non-determinism detector: run a pipeline N times and check
that all outputs are identical. Useful for catching subtle bugs
in ETL pipelines that appear only occasionally.
"""
import hashlib
import json
from typing import Callable, Any


def sha256_obj(obj: Any) -> str:
    """Deterministic hash of any JSON-serializable object."""
    return hashlib.sha256(
        json.dumps(obj, sort_keys=True, default=str).encode()
    ).hexdigest()


def detect_non_determinism(
    pipeline: Callable[[], Any],
    n_runs: int = 5,
) -> dict[str, Any]:
    """
    Run pipeline n_runs times and check all outputs match.
    
    Returns: {
        "deterministic": bool,
        "hashes": list of output hashes,
        "first_output": the output from the first run,
        "divergence_run": index of first divergent run (or None)
    }
    """
    results = []
    hashes = []
    
    for i in range(n_runs):
        output = pipeline()
        output_hash = sha256_obj(output)
        results.append(output)
        hashes.append(output_hash)
        print(f"Run {i+1}: {output_hash[:16]}...")
    
    first_hash = hashes[0]
    divergence = None
    for i, h in enumerate(hashes[1:], 1):
        if h != first_hash:
            divergence = i
            break
    
    return {
        "deterministic": divergence is None,
        "hashes": hashes,
        "first_output": results[0],
        "divergence_run": divergence,
    }


# Example: catching a non-deterministic pipeline
def buggy_pipeline():
    import random
    data = list(range(100))
    random.shuffle(data)  # Not seeded!
    return {"processed": data[:10]}  # Returns different 10 each time


result = detect_non_determinism(buggy_pipeline)
if not result["deterministic"]:
    print(f"NON-DETERMINISTIC: Run {result['divergence_run']} diverged")
    print(f"Hashes: {result['hashes']}")
```

### Example 4: Deterministic Parallel Processing

```python
"""
Demonstrating how to make parallel processing deterministic
by controlling the order of result aggregation.
"""
from concurrent.futures import ProcessPoolExecutor
import numpy as np


def non_deterministic_parallel_sum(data: list[int]) -> int:
    """
    BAD: Results depend on which worker finishes first.
    The order of partial sums affects floating-point rounding.
    """
    with ProcessPoolExecutor() as executor:
        # Submit chunks in arbitrary order of completion
        chunk_size = len(data) // 4
        chunks = [data[i:i + chunk_size] for i in range(0, len(data), chunk_size)]
        futures = [executor.submit(sum, chunk) for chunk in chunks]
        # as_completed returns in completion order (non-deterministic)
        from concurrent.futures import as_completed
        total = 0
        for future in as_completed(futures):
            total += future.result()  # Non-deterministic aggregation order
        return total


def deterministic_parallel_sum(data: list[int]) -> int:
    """
    GOOD: Results are collected in submission order, ensuring
    deterministic aggregation regardless of completion order.
    """
    with ProcessPoolExecutor() as executor:
        chunk_size = len(data) // 4
        chunks = [data[i:i + chunk_size] for i in range(0, len(data), chunk_size)]
        futures = [executor.submit(sum, chunk) for chunk in chunks]
        # Collect in submission order (deterministic)
        partials = [f.result() for f in futures]
        return sum(partials)  # Always same order, always same result


# Verify
data = list(range(1, 10001))
assert deterministic_parallel_sum(data) == deterministic_parallel_sum(data)
# This assertion always passes. The non_deterministic version
# might fail on floating-point data with enough runs.
```

## Best Practices

- **Seed everything at the entry point.** All RNGs: Python `random`, NumPy, PyTorch/TensorFlow, hash seeds, and any library-specific RNG. Do this in a single `set_seed()` function called at the start of `main()`.
- **Log the full environment:** OS, library versions, git commit, build flags, hardware. If you can't reproduce a bug report, you'll need this information.
- **Use lock files religiously.** `poetry.lock`, `Cargo.lock`, `package-lock.json`, `Gemfile.lock` -- commit them. They are the cheapest form of reproducibility insurance.
- **Containerize for anything that crosses team boundaries.** Docker is the baseline. Nix/Guix for stronger guarantees.
- **Verify reproducibility in CI.** Run critical pipelines twice and diff the outputs. If they differ, fail the build. This catches non-determinism before it reaches production.
- **Accept probabilistic reproducibility for ML.** In large-scale ML, bitwise reproducibility may be impractical. Instead, verify that key metrics (accuracy, loss) are within a tight tolerance across runs.
- **Document known sources of non-determinism.** Every project should have a REPRODUCIBILITY.md listing what is and isn't deterministic, and why.

## Related Topics

- [[Principles/Determinism]] -- Reproducibility is determinism applied to pipelines and experiments
- [[FormalVerification]] -- The highest level of correctness; reproducibility is a prerequisite
- [[DevOps]] -- Reproducible builds, infrastructure as code, containerization
- [[Programming]] -- Deterministic algorithms, seeding RNGs, parallel processing
- [[DataStructures]] -- Hash iteration order, set non-determinism
- [[Quality]] -- Reproducible testing is a prerequisite for quality assurance
- [[Performance]] -- The tension between determinism and performance (deterministic GPU ops are slower)
- [[BigO]] -- Complexity guarantees must be reproducible to be meaningful
