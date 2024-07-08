using Turing
using LinearAlgebra
using FillArrays

@model function wells_daae_c_model(N, switched, dist, arsenic, assoc, educ)
    c_dist100 = (dist .- mean(dist)) ./ 100
    c_arsenic = arsenic .- mean(arsenic)
    da_inter = c_dist100 .* c_arsenic
    educ4 = educ ./ 4.0

    x = hcat(c_dist100, c_arsenic, da_inter, assoc, educ4)

    alpha ~ Turing.Flat()
    beta ~ filldist(Turing.Flat(), 5)
    
    switched .~ BernoulliLogit.(alpha .+ x * beta)
end