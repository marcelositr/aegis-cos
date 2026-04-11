---
title: Job Control
title_pt: Controle de Jobs
layer: shell_engineering
type: concept
priority: high
version: 1.0.0
tags:
  - ShellEngineering
  - JobControl
description: Managing background processes and process groups in shell.
description_pt: Gerenciando processos em segundo plano e grupos de processos no shell.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Job Control

## Description

Job control manages running processes:
- Running in foreground/background
- Stopping/suspending processes
- Managing process groups



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

## Examples

```bash
# Run in background
long_running_command &

# List jobs
jobs

# Bring to foreground
fg %1

# Send to background (while running)
Ctrl+Z
bg

# Kill job
kill %1

# Kill process
kill -9 $(pgrep process_name)
```

## Background Processing

```bash
# Multiple background jobs
process_file file1.txt &
process_file file2.txt &
process_file file3.txt &

# Wait for all
wait

# Wait for specific
wait %1
```

## Failure Modes

- **Background jobs not waited for** → script exits before background jobs complete → orphaned processes and incomplete work → use wait for all background jobs before script exit
- **No output redirection for background jobs** → background job output mixes with terminal → garbled output and lost messages → redirect stdout and stderr to log files for background jobs
- **Zombie processes from unwaited children** → parent exits without collecting child status → zombie processes accumulate → always wait for child processes or use double-fork for daemons
- **Signal handling not implemented** → script cannot be gracefully interrupted → forced kill and resource leaks → implement signal handlers for SIGINT and SIGTERM with cleanup
- **Too many concurrent background jobs** → unbounded parallelism exhausts system resources → system becomes unresponsive → limit concurrent jobs with job control or semaphores
- **Job control in non-interactive scripts** → job control commands used in scripts without proper terminal → unexpected behavior and errors → disable job control in non-interactive scripts or use proper process management
- **Race conditions in parallel job output** → multiple jobs write to same file simultaneously → interleaved or corrupted output → use file locking or separate output files per job

## Anti-Patterns

### 1. Background Jobs Not Waited For

**Bad:** Launching background jobs with `&` but not using `wait` before the script exits
**Why it's bad:** The script exits and the background jobs become orphans — work is incomplete, and the jobs may continue consuming resources indefinitely
**Good:** Always `wait` for all background jobs before script exit — or trap EXIT to ensure waiting happens even on early termination

### 2. No Output Redirection for Background Jobs

**Bad:** Running background jobs without redirecting their stdout and stderr
**Why it's bad:** Output from multiple background jobs mixes with the terminal and each other — messages are garbled, lost, or interleaved with prompt text
**Good:** Redirect stdout and stderr to log files for every background job — `command > job.log 2>&1 &`

### 3. Unbounded Parallelism

**Bad:** Launching an unbounded number of background jobs (`for f in *.txt; do process "$f" & done`)
**Why it's bad:** Processing 10,000 files means 10,000 concurrent processes — the system becomes unresponsive, runs out of memory, or hits process limits
**Good:** Limit concurrent jobs using `xargs -P`, GNU `parallel`, or a job semaphore — process N jobs at a time, not all at once

### 4. Race Conditions in Parallel Job Output

**Bad:** Multiple background jobs writing to the same output file simultaneously
**Why it's bad:** Writes are interleaved at the byte level — output lines are garbled, data is corrupted, and the file is unusable
**Good:** Use separate output files per job and combine them afterward, or use file locking (`flock`) to serialize writes to shared files

## Best Practices

### 1. Use wait

```bash
# Wait for background jobs before exiting
background_job &
wait
```

### 2. Redirect Output

```bash
# Redirect to avoid terminal clutter
command > output.log 2>&1 &
```

## Related Topics

- [[Shell Engineering MOC]]
- [[Concurrency]]
- [[BashBestPractices]]
- [[JobControl]]
- [[Monitoring]]
