# TuringPosteriorDB

[![Build Status](https://github.com/JasonPekos/TuringPosteriorDB.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JasonPekos/TuringPosteriorDB.jl/actions/workflows/CI.yml?query=branch%3Amain)

# Ok, here's the current rundown:

## Models

Models are in `src/models`. Each model has it's own `manifest.toml` and `project.toml`, but is not currently wrapped in
any sort of struct to handle conditioning. I don't think I fully understand the benefit of that yet.

## Benchmarking

I wrote a quick wrapper function in `src/helper-functions/benchmarking-functions.jl` that feels way too hacky to keep. But it seems to work right now. 
This function takes a posterior identifier, e.g. `Rate_1_data-Rate_1_model`, and then runs the `TuringBenchmarking.jl` suite for the corresponding Turing model. 

Also:

```
get_turing_samples("PDB_Unique_Identifier")
```

 now works, e.g.:

 ```
get_turing_samples("Rate_1_data-Rate_1_model")
 ```

will find the Turing model, find the data, fit the model with `NUTS()` (need to add some options here), 
and then return the samples.


## Testing

Nothing yet
