using Turing
using LinearAlgebra
using FillArrays

@model function wells_dist100ars_model(N, switched, dist, arsenic)
    dist100 = dist ./ 100

    x = hcat(dist100, arsenic)

    alpha ~ Turing.Flat()
    beta ~ filldist(Turing.Flat(), 2)
    
    switched .~ BernoulliLogit.(alpha .+ x * beta)
end