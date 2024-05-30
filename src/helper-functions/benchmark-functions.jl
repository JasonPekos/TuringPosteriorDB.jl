using TuringBenchmarking
using PosteriorDB
using StanSample
 
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
