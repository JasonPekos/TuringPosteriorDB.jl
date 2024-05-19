# TuringPosteriorDB

[![Build Status](https://github.com/JasonPekos/TuringPosteriorDB.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JasonPekos/TuringPosteriorDB.jl/actions/workflows/CI.yml?query=branch%3Amain)

# Ok, here's the current rundown:

## Models

Models are in `src/models`. Each model has it's own `manifest.toml` and `project.toml`, but is not currently wrapped in
any sort of struct to handle conditioning. I don't think I fully understand the benefit of that yet.

## Benchmarking

I wrote a quick wrapper function in `src/helper-functions/benchmarking-functions.jl` that feels way too hacky to keep. But it seems to work right now for some models\*. 
This function takes a posterior identifier, e.g. `Rate_1_data-Rate_1_model`, and then runs the `TuringBenchmarking.jl` suite for the corresponding Turing model. 

\* the catch here is that I want to change the original `Stan`PDB repo for this project, adding a subject to the posterior info `.json` files that tells me
what data the models actually use (some models use only part of a larger dataset, e.g. `earnings`). When I do this, I'll change `get_data` to filter the data
to only what I want, so that model fitting works for all models.
