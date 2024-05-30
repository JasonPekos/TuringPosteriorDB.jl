using StanSample

"""
    get_data(str)

Given a complete PosteriorDB reference string, 
compute and return Turing draws for that model.

Each model has it's own enviroment, which this function activates.

## Example

```julia-repl
julia> get_turing_samples("Rate_1_data-Rate_1_model")
Chains MCMC chain (1000×13×1 Array{Float64, 3}): ...
```
"""
function get_turing_samples(pdb_posterior_name::AbstractString)
    # Separate the (dataset name, model name)
    _, model_name = split(pdb_posterior_name, "-", limit = 2)

    # Get data, get path
    data = get_data(pdb_posterior_name)
    model_path = joinpath("src/models", model_name)

    # Activate path of model
    load_env!(model_name)

    # Get actual model
    model_file = joinpath(model_path, model_name * ".jl")
    include(model_file)

    conditioned_model = @invokelatest getfield(Main.TuringPosteriorDB, Symbol(model_name))(data.vals...) 
    sampler = @invokelatest NUTS()
    samples = @invokelatest sample(conditioned_model, sampler, 1000)

    # Go back to original env
    unload_env!()

    return samples
end

function get_stan_samples(pdb_posterior_name::AbstractString)
    pdb = PosteriorDB.database()
    _, model_name = split(pdb_posterior_name, "-")
    model_imp = PosteriorDB.implementation(PosteriorDB.model(pdb, String(model_name)), "stan")

    stan_string = PosteriorDB.load(model_imp)

    sm = SampleModel(model_name, stan_string)
    data_dict = Dict(get_data(pdb_posterior_name))
    stan_sample(sm; data = data_dict)

    return read_samples(sm, :mcmcchains)
end