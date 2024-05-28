using TuringBenchmarking
using PosteriorDB
using StanSample
using Pkg
using OrderedCollections



"""
    method_argname(m)

This is a function taken from base Julia: 
https://github.com/JuliaLang/julia/blob/master/base/methodshow.jl

which returns the symbols that comprise the arguments for some Julia method `m`.

Used as part of `get_data_args()`
"""
function method_argnames(m::Method)
    argnames = ccall(:jl_uncompress_argnames, Vector{Symbol}, (Any,), m.slot_syms)
    isempty(argnames) && return argnames
    return argnames[1:m.nargs]
end

"""includes() the Turing model.jl without activating the environment"""
function load_turing_callable_no_env!(model_name::AbstractString)
    model_path = joinpath("src/models", model_name)
    include(joinpath(model_path, model_name * ".jl"))
end

"""
    get_data_args(str)

Returns a vector of symbols corresponding to the arguments to a 
Turing model. 
"""
function get_data_args(pdb_posterior_name::AbstractString)
    _, model_name = split(pdb_posterior_name, "-", limit = 2)
    
    load_turing_callable_no_env!(model_name)

    model_fun = getfield(Main, Symbol(model_name))
    method_argnames(collect(methods(model_fun))[1])[2:end]
end

"""
    get_data(str)

Given a complete PosteriorDB reference string, 
return the data used to fit the model.

## Example

```julia-repl
julia> get_data("Rate_1_data-Rate_1_model")
2-element Vector{Int64}:
 10
  5
```
"""
function get_data(pdb_posterior_name::AbstractString)
    # Gets the dataset that the model is fit on
    pdb = PosteriorDB.database()
    dataset_name, model_name = split(pdb_posterior_name, "-")
    data_keys = get_data_args(pdb_posterior_name)
    data_dict = PosteriorDB.load(PosteriorDB.dataset(pdb, String(dataset_name)))

    return OrderedDict(string(k) => data_dict[string(k)] for k in data_keys)
end



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
    Pkg.activate(model_path)
    Pkg.instantiate()

    # Get actual model
    model_file = joinpath(model_path, model_name * ".jl")
    include(model_file)

    conditioned_model = @invokelatest getfield(Main, Symbol(model_name))(data.vals...) 
    sampler = @invokelatest NUTS()
    samples = @invokelatest sample(conditioned_model, sampler, 1000)

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
 
function benchmark_turing(pdb_model_str::AbstractString)
    # Separate the (dataset name, model name)
    _, model_name = split(pdb_model_str, "-", limit = 2)

    # Get data, get path
    data = get_data(pdb_model_str)
    model_path = joinpath("src/models", model_name)

    # Activate path of model
    Pkg.activate(model_path)
    Pkg.instantiate()

    # Get actual model
    model_file = joinpath(model_path, model_name * ".jl")
    include(model_file)

    conditioned_model = getfield(Main, Symbol(model_name))(data.vals...) 
    # Run Turing benchmarking suite
    run(make_turing_suite(conditioned_model))
end

# function check_pairs(pdb_model_name; params)

# end


# function giant_diagnostics_plot(pdb_model_name; params)
#     turing_chains = get_turing_samples(pdb_model_name)
#     stan_chains = get_stan_samples(pdb_model_name)


# end
