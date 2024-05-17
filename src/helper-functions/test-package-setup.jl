"""
Run a full `TuringBenchmarks.jl` style benchmark suite for
    1. The associated Stan model
    2. The associated Turing model

Maybe print some warnings if:
    1. There are no associated reference draws
    2. There are reference draws and the results of running either of the models 
       doesn't "match" the refence draws (have to think about what this means)

Maybe I should have functions:
    test_turing(pdb_model_str)
    test_stan(pdb_model_str)
    test(pdb_model_str)

that do correctness stuff, and leave the benchmark functions to just benchmark.
"""
function benchmark(pdb_model_str)

end


"""Same as above, but only benchmark the Turing model"""
function benchmark_turing(pdb_model_str)

end


"""Same as above, but only benchmark the Stan model"""
function benchmark_stan(pdb_model_str)

end

# see me git