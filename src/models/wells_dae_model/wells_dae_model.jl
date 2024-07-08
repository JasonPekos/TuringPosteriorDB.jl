using Turing
using LinearAlgebra
using FillArrays

@model function wells_dae_model(N, switched, dist, arsenic, educ)
    dist100 = dist ./ 100
    educ4 = educ ./ 4.0

    x = hcat(dist100, arsenic, educ4)

    alpha ~ Turing.Flat()
    beta ~ filldist(Turing.Flat(), 3)
    
    switched .~ BernoulliLogit.(alpha .+ x * beta)
end