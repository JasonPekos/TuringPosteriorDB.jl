# TuringPosteriorDB

[![Build Status](https://github.com/JasonPekos/TuringPosteriorDB.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JasonPekos/TuringPosteriorDB.jl/actions/workflows/CI.yml?query=branch%3Amain)

# Ok, here's the current rundown:

## Models

Models are in `src/models`. Each model has it's own `manifest.toml` and `project.toml`, but is not currently wrapped in
any sort of struct to handle conditioning. I don't think I fully understand the benefit of that yet.

## Using a model

Each model is a plain `@model` function whose positional arguments are named after the Stan data it takes.
`test/worker.jl` shows the whole route from a posteriordb name to a conditioned model: include the file,
read the data, call the function. The old sampling and benchmarking helpers, which switched environments
at run time, are gone.

## Testing

`test/runtests.jl` compares each model's log joint density with Stan's at ten points per posterior.
A model passes when the two differ by the same constant at every point. `test/README.md` describes the check,
and `test/known_failures.toml` lists the posteriors that don't pass yet, with the reason for each.

```
julia --project=test -e 'using Pkg; Pkg.instantiate()'
julia --project=test test/runtests.jl
```

`Pkg.test()` from the repo root runs the same suite.


## Notes on Models

| Model           | Notes           |
|-----------------|-----------------|
| Rate_5_model    | AD Broken for posterior predictive checks |
| Rate_4_model    | AD Broken for posterior predictive checks |
| Kilpisjarvi    | Check for divergences and correctness -- large variance in sample mean for both Stan and Turing |



Actually all the transformed parameter models are broken. 