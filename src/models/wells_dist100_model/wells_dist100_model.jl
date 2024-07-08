using Turing
using LinearAlgebra
using FillArrays

@model function wells_dist100_model(N, switched, dist)
    c_dist100 = dist ./ 100

    alpha ~ Turing.Flat()
    beta ~ Turing.Flat()
    
    switched .~ BernoulliLogit.(alpha .+ c_dist100 .* beta)
end