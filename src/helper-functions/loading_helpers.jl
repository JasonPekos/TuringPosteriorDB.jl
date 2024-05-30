using PosteriorDB
using Pkg
using OrderedCollections


#=
Workflow:


Initialize in base environment (PDB.jl)
   -> swap to specific environment
   -> instantiate environment
   -> include files
   -> run computations (sample)
   <- swap back to base environment

Getting Arg Names:
    -> swap to environment 
    -> include files
    -> parse methods for args
    <- swap back
    <- create data dict

=#


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

function load_env!(model_name::AbstractString)
    model_path = joinpath(get_db_dir(), model_name)
    push!(Base.LOAD_PATH, model_path)
    Pkg.instantiate()
    @info "Environment stack updated to: " Base.LOAD_PATH
end

function unload_env!()
    pop!(Base.LOAD_PATH)
    Pkg.instantiate()
    @info "Environment stack updated to: " Base.LOAD_PATH
end

function load_turing_callable(model_name::AbstractString)
    model_path = joinpath(get_db_dir(), model_name)
    include(joinpath(model_path, model_name * ".jl"))
end

"""
    get_data_args(str)

Returns a vector of symbols corresponding to the arguments to a 
Turing model. 
"""
function get_data_args(pdb_posterior_name::AbstractString)
    _, model_name = split(pdb_posterior_name, "-", limit = 2)

    load_env!(model_name)

    load_turing_callable(model_name)
    model_funs = getfield(Main.TuringPosteriorDB, Symbol(model_name))
    method_lst = collect(methods(model_funs))
    filtered_methods = filter(m -> !(:__model__ in method_argnames(m)), method_lst)

    out = method_argnames(filtered_methods[1])[2:end]

    unload_env!()

    return out
end

"""
    get_data(str)

Given a complete PosteriorDB reference string, 
return the data used to fit the model.
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
