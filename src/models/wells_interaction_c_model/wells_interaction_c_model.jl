using Turing
using LinearAlgebra
using FillArrays

@model function wells_interaction_c_model(N, switched, dist, arsenic)
    c_dist100 = (dist .- mean(dist)) ./ 100
    c_arsenic = arsenic .- mean(arsenic)

    inter = c_dist100 .* c_arsenic

    x = hcat(c_dist100, c_arsenic, inter)

    alpha ~ Turing.Flat()
    beta ~ filldist(Turing.Flat(), 3)
    
    switched .~ BernoulliLogit.(alpha .+ x * beta)
end