module TuringPosteriorDB

function get_db_dir()
    return joinpath(@__DIR__,  "models")
end

include("helper-functions/loading_helpers.jl")
include("helper-functions/sampling_helpers.jl")
include("helper-functions/benchmark-functions.jl")

export get_data, get_turing_samples, get_stan_samples, get_base_dir

end
