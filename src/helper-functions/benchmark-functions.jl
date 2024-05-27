using TuringBenchmarking
using PosteriorDB
using Pkg


function get_data(pdb_model_name::String)
    # Gets the dataset that the model is fit on
    pdb = PosteriorDB.database()
    dataset_name, model_name = split(pdb_model_name, "-")
    PosteriorDB.load(PosteriorDB.dataset(pdb, String(dataset_name)))
end



function benchmark_turing(pdb_model_str)
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

    # In practice I need to select the columns here for many models. But need to update PDB first ...
    conditioned_model = getfield(Main, Symbol(model_name))(data.vals...) 
    
    # Run Turing benchmarking suite
    run(make_turing_suite(conditioned_model))
end


"""Same as above, but only benchmark the Stan model"""
function benchmark_stan(pdb_model_str)

end