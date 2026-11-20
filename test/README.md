# The log-density check

A Turing model in this repo is taken to be correct when its log joint density
differs from the Stan model's by the same constant at every point. The tests
check that at ten points per posterior.

```
julia --project=test -e 'using Pkg; Pkg.instantiate()'     # once
julia --project=test test/runtests.jl                       # every posterior
julia --project=test test/runtests.jl eight_schools-eight_schools_centered
```

## What is compared

Take a posterior with parameters $\psi$ and data $y$, and test points
$\psi_1, \dots, \psi_{10}$. At each point the check computes

$$d_i = \log p_{\text{Turing}}(\psi_i, y) - \log p_{\text{Stan}}(\psi_i, y),$$

and the posterior passes when

$$\max_i \frac{|d_i - \operatorname{median}(d)|}{\max(1, |\log p_{\text{Stan}}(\psi_i, y)|)} \le 10^{-9}.$$

Both densities are evaluated at the constrained parameters, the values the
model block sees, with no Jacobian term. The result then does not depend on how
either library maps a constrained parameter to the real line.

The difference $d$ may be any constant because the two libraries drop different
normalising constants. For example, Turing's `truncated(Cauchy(0, 5); lower = 0)`
is normalised over the half line, and Stan's `cauchy(0, 5)` on a `<lower=0>`
parameter is not, which contributes $\log 2$ per such parameter.

## Files

| Path | What |
|---|---|
| `runtests.jl` | Reads posteriordb's data and the reference values, starts the worker, compares each status with `known_failures.toml`. |
| `worker.jl` | Runs in a model's own environment, one process per distinct environment. Includes each model file, evaluates `logjoint` at the reference points and reports a row per posterior. |
| `environments.jl` | Checks that each model's `Project.toml` and `Manifest.toml` match the shared ones in `src/models`. `scripts/sync_environments.jl` writes them. |
| `reference/<posterior>.json` | Stan's side: `names`, `points` (constrained, flattened in Stan's order) and `lp` (Stan's log density at each point, all constants kept). Five points come from a short NUTS run on Stan's density and five are draws from Stan's initial-value distribution. |
| `known_failures.toml` | The posteriors that do not pass yet, grouped by status, each with a reason. |
| `stan/` | `stan_reference.jl` writes the reference files with BridgeStan. The tests never run it. |

## Statuses

| Status | Meaning |
|---|---|
| `pass` | The difference from Stan is constant. |
| `differ` | The model evaluates, and the difference is not constant. |
| `load` | The file fails to load, or defines no model named after its folder. |
| `data` | The model takes an argument that is not in the Stan data. |
| `names` | The model's parameter names are not Stan's. |
| `shape` | A parameter has a different shape from Stan's. |
| `eval` | Evaluating the log joint throws, or gives a non-finite value where Stan's is finite. |

A posterior with no entry in `known_failures.toml` is expected to pass. The
suite fails when a status is not the expected one, in either direction, so a
fix to a model comes with the removal of its entry.

## Adding a model

1. Put the model in `src/models/<name>/<name>.jl`, as `@model function <name>(...)`.
   `<name>` is the posteriordb model name, and the positional arguments are
   named after the Stan data they take.
2. If the file loads a package that `src/models/Project.toml` lacks, add it there
   (`julia --project=src/models -e 'using Pkg; Pkg.add("Name")'`).
3. Write the model's `Project.toml` and `Manifest.toml`: `julia scripts/sync_environments.jl`.
4. Write the reference values for its posteriors:
   `julia --project=test/stan test/stan/stan_reference.jl`.
5. Run the tests.
