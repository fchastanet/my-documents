---
title: 'Happier Developers, Faster Teams: Why Prek Beats Pre-commit'
description: A Rust-powered alternative to pre-commit that scale from small repos to massive projects.
weight: 20
categories: [documentation]
tags: [Prek, pre-commit, tooling]
backup:
  author: Benito Martin
  authorUrl: https://substack.com/@benitomartin
  originalUrl: https://aiechoes.substack.com/p/happier-developers-faster-teams-why
  date: 2025-10-09
version: '1.0'
date: '2023-03-18T08:00:00+01:00'
lastmod: '2026-02-27T08:00:00+01:00'
---

## 1. A Rust-powered alternative to pre-commit that scale from small repos to massive projects

![Benito Martin's avatar](https://substackcdn.com/image/fetch/$s_!yXLW!,w_36,h_36,c_fill,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F3578e402-7ebb-4ed4-a2e4-7bce1f6d747a_3213x3213.jpeg)

[Benito Martin](https://substack.com/@benitomartin)

![Pre-Commit Workflows](https://substackcdn.com/image/fetch/$s_!h-pb!,w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fdc668ae1-8448-4aa8-a5bf-455bc1f40f73_878x688.png "Pre-Commit Workflows")

Pre-Commit Workflows

If you’ve been using pre-commit in your Python projects, you know the drill: you make a small change, hit commit, and
then... wait. And wait. While pre-commit has become the de facto standard for managing git hooks in the Python
ecosystem, its performance characteristics leave much to be desired, especially in modern development workflows where
speed matters.

But now there’s a new player: **[prek](https://prek.j178.dev/)**, a Rust-based reimplementation of the pre-commit
framework that promises to deliver the same functionality with dramatically better performance. But does it actually
deliver? I ran benchmarks to find out, and the results are striking enough that they might change how you think about
git hooks entirely.

### 1.1. The Problem with Pre-commit

Before diving into the comparison, let’s acknowledge what pre-commit does well. It’s mature, battle-tested, and has an
extensive ecosystem of hooks. For years, it’s been the go-to solution for enforcing code quality checks before commits
reach your repository.

However, pre-commit has a fundamental performance bottleneck: it’s written in Python and relies on creating isolated
virtual environments for each hook. This architecture, while robust, introduces significant overhead, especially during
the initial setup phase.

In modern development, where CI/CD pipelines run frequently and developer productivity depends on fast feedback loops,
this overhead adds up. Every second spent waiting for hooks to install or run is a second taken away from actual
development work.

### 1.2. Enter Prek: The Rust Alternative

Prek reimagines the pre-commit workflow with performance as a first-class concern. Built in Rust, it leverages the
language’s speed and efficient concurrency model to deliver dramatic improvements in both installation and execution
time.

The key insight behind prek is that you shouldn’t have to compromise between comprehensive code quality checks and
developer velocity. By rewriting the core framework in Rust and optimizing the environment management strategy, prek
aims to be a drop-in replacement that simply works faster.

### 1.3. The Benchmark: Real Numbers

I ran a controlled benchmark comparing both tools on a personal repository with 6 hooks in the YAML configuration.
Here’s the testing methodology:

- Multiple runs for each tool to account for variance
- Measured both installation time (cold start with no cache) and execution time (warm steady state)
- Same hardware, same repository, same hooks
- Used hyperfine for precise benchmarking

To make the results reproducible, here’s the exact script I used:

```bash
#!/usr/bin/env bash
set -euo pipefail

INSTALL_RUNS=10 # more runs for install
RUNTIME_RUNS=5  # fewer runs for runtime

echo "Starting benchmarks..."
echo
echo "Tool versions:"
prek --version || true
pre-commit --version || true
echo

# -------------------------------
# INSTALL BENCHMARK (COLD)
# -------------------------------
# Measures how long it takes to install hooks when no cache is present.
# --prepare: clears prek, pre-commit, and uv caches before each run
# --cleanup: clears caches after all runs for each command
# --runs:    repeat exactly $INSTALL_RUNS times for each tool
# Export: results go to install_benchmark.md in Markdown table format.

echo "=== Install benchmark (cold) ==="
hyperfine \
  --runs $INSTALL_RUNS \
  --prepare 'prek clean && pre-commit clean && uv cache clean' \
  --cleanup 'prek clean && pre-commit clean && uv cache clean' \
  'pre-commit install --install-hooks' \
  'prek install --install-hooks' \
  --export-markdown install_benchmark.md

# -------------------------------
# RUNTIME BENCHMARK (WARM STEADY STATE)
# -------------------------------
# Measures steady-state runtime performance.
# --warmup 3: discard the first 3 runs to fill caches
# --runs:     measure $RUNTIME_RUNS actual runs
# --cleanup:  clean caches at the end
# Export: results go to runtime_warm_benchmark.md

echo
echo "=== Runtime benchmark (warm, steady state) ==="
hyperfine \
  --warmup 3 \
  --runs $RUNTIME_RUNS \
  --cleanup 'prek clean && pre-commit clean && uv cache clean' \
  'pre-commit run --all-files' \
  'prek run --all-files' \
  --export-markdown runtime_warm_benchmark.md

echo
echo "Benchmarks completed."
echo "Results saved to:"
echo "  install_benchmark.md"
echo "  runtime_warm_benchmark.md"
```

## 2. Benchmark Results

**Install benchmark (cold)**

```text
    === Install benchmark (cold) ===
    Benchmark 1: pre-commit install --install-hooks
      Time (mean ± σ):     40.141 s ±  2.420 s    [User: 37.105 s, System: 8.164 s]
      Range (min … max):   38.442 s … 46.782 s    10 runs

    Benchmark 2: prek install --install-hooks
      Time (mean ± σ):     22.790 s ±  0.225 s    [User: 9.053 s, System: 5.426 s]
      Range (min … max):   22.496 s … 23.220 s    10 runs

    Summary
      ‘prek install --install-hooks’ ran
        1.76 ± 0.11 times faster than ‘pre-commit install --install-hooks’

**Runtime benchmark (warm, steady state)**

    === Runtime benchmark (warm, steady state) ===
    Benchmark 1: pre-commit run --all-files
      Time (mean ± σ):     176.7 ms ±   9.3 ms    [User: 112.6 ms, System: 40.1 ms]
      Range (min … max):   168.6 ms … 191.6 ms    5 runs

    Benchmark 2: prek run --all-files
      Time (mean ± σ):      26.3 ms ±   1.7 ms    [User: 33.7 ms, System: 22.8 ms]
      Range (min … max):    24.4 ms …  28.2 ms    5 runs

    Summary
      ‘prek run --all-files’ ran
        6.72 ± 0.56 times faster than ‘pre-commit run --all-files’
```

The results speak for themselves: prek consistently outperforms pre-commit across both installation and execution
phases.

**Pre-commit Performance:**

- Average Install Time: 40.1 seconds
- Average Run Time: 176.7 milliseconds

**Prek Performance:**

- Average Install Time: 22.8 seconds
- Average Run Time: 26.3 milliseconds

Let’s break down what these numbers mean in practice.

### 2.1. Installation Time

The installation phase, where hooks are set up and dependencies are installed, shows significant improvement. Prek
completes installation in 22.8 seconds compared to pre-commit’s 40.1 seconds—that’s **1.76 times faster**, saving over
17 seconds per installation.

This improvement comes from prek’s more efficient environment management and parallel processing capabilities. Where
pre-commit sets up each hook’s environment sequentially, prek parallelizes much of the work, fully leveraging modern
multi-core CPUs.

These savings hit you every time you clone a fresh repository, onboard a new teammate, rebuild your development
environment, or spin up a clean CI/CD job. In practice, these are some of the most time-sensitive moments in
development: the first impression when a new contributor joins, or the critical “green build” loop in CI.

### 2.2. Execution Time

The run-time comparison is even more striking. Prek executes all hooks in 26.3 milliseconds versus pre-commit’s 176.7
milliseconds—**nearly 7 times faster**.

For something that happens on every commit, this difference transforms the development experience. With pre-commit, you
notice the delay. With prek, the hooks feel nearly instantaneous.

This performance gap exists because of lower startup overhead (Rust binaries start faster than Python processes),
efficient process spawning (prek minimizes the cost of launching hook processes), and optimized parallelization with
better concurrent execution of independent hooks.

### 2.3. When Speed Actually Matters

You might be thinking: _“Does shaving off seconds really matter?”_ The answer becomes clear when you scale up the
impact.

For small and medium repositories like mine, prek already makes a meaningful difference: installs are about **2×
faster**, and hook execution is nearly **7× faster**. That means less waiting when you first set up, and almost instant
feedback every time you commit.

But the benefits become even more dramatic in larger projects. In the Apache Airflow
[benchmarks](https://prek.j178.dev/benchmark/) published by the prek authors, installation time dropped from **187
seconds with pre-commit to just 18 seconds with prek**—a full order of magnitude faster. For projects with dozens of
hooks and contributors, that kind of improvement changes the entire onboarding and CI experience.

Even beyond raw install times, the biggest impact is on **everyday commits**. Developers interact with pre-commit
constantly, and even sub-second delays add friction. Prek crosses an important psychological threshold: hooks feel
instantaneous, which means you stop noticing them. That reduces context switching, helps maintain flow, and removes the
temptation to skip checks because they feel “too slow.”

In open source projects, where contributors might clone fresh repositories often and CI jobs rebuild environments from
scratch, these savings add up across the community. For teams running frequent pipelines, the shorter runtimes directly
reduce compute costs and feedback latency.

Put simply: whether you’re working on a small repo or a massive open source project, prek makes pre-commit checks feel
like they should have all along—fast, seamless, and invisible.

### 2.4. What This Means for Your Workflow

These performance improvements have cascading effects throughout the development lifecycle:

- **For Individual Developers**: Commits feel responsive rather than sluggish, with less context switching while waiting
  for hooks.
- **For Teams**: Faster CI/CD pipelines, reduced compute costs from shorter-running jobs, and better developer
  satisfaction overall.
- **For Large Repositories**: More hooks can be added without degrading the user experience, and onboarding new
  contributors becomes significantly faster.

### 2.5. Compatibility: Drop-in Replacement

One of prek’s strongest features is its compatibility with the existing pre-commit ecosystem. Your
`.pre-commit-config.yaml` file works as-is. The hooks you’ve already configured continue to function identically.

This means adoption is trivial:

```bash
# Install prek
pip install prek

# Use it exactly like pre-commit
prek install --install-hooks
prek run --all-files
```

No configuration changes. No hook migrations. No breaking your team’s workflow. You get the performance benefits
immediately without any of the typical migration pain.

### 2.6. The Trade-offs

In the interest of balanced assessment, it’s worth noting that prek is newer and less battle-tested than pre-commit. The
ecosystem maturity difference means:

- Pre-commit has more extensive documentation and community resources.
- Edge cases and obscure configurations may be better handled by pre-commit.
- Some organizations may prefer the stability of the more established tool.

However, for the vast majority of use cases, standard Python projects with common hooks like Black, Ruff, MyPy, and
isort, prek works flawlessly while being dramatically faster.

### 2.7. The Bigger Picture: Rust in Python Tooling

Prek is part of a larger trend of performance-critical Python tooling being rewritten in Rust. We’ve seen this with:

- **Ruff**: The lightning-fast Python linter and formatter
- **Polars**: The high-performance DataFrame library
- **Pydantic V2**: Rewritten core with a Rust foundation
- **uv**: An extremely fast Python package installer

The pattern is clear: when performance is crucial and Python’s overhead becomes a bottleneck, Rust offers a compelling
path forward while maintaining Python ecosystem compatibility.

## 3. Conclusion

After running these benchmarks, the case for prek is compelling. With faster installation and run times—all while
maintaining full compatibility with existing pre-commit configurations—prek represents a significant improvement in the
git hooks workflow.

The numbers tell a clear story: prek doesn’t just incrementally improve on pre-commit, it fundamentally transforms the
experience. Installation goes from noticeable to negligible, and execution crosses the threshold from “slight delay” to
“essentially instant.” For teams that value developer velocity and responsive tooling, these improvements compound over
time into meaningful productivity gains.

The migration path is trivial, the benefits are immediate, and the performance gains speak for themselves. Whether
you’re a solo developer tired of waiting for hooks or leading a team where those seconds multiply into hours of lost
productivity, prek delivers exactly what modern development workflows demand: speed without compromise.

The age of waiting for git hooks is over. Give prek a try—your future self (and your teammates) will thank you.
