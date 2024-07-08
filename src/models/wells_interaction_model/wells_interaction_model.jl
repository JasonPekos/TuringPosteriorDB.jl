using Turing
using LinearAlgebra
using FillArrays

@model function wells_interaction_model(N, switched, dist, arsenic)
    dist100 = dist ./ 100
    inter = dist100 .* arsenic

    x = hcat(dist100, arsenic, inter)

    alpha ~ Turing.Flat()
    beta ~ filldist(Turing.Flat(), 3)
    
    switched .~ BernoulliLogit.(alpha .+ x * beta)
end