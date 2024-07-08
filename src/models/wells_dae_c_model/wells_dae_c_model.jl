using Turing
using LinearAlgebra
using FillArrays

@model function wells_dae_c_model(N, switched, dist, arsenic, educ)
    c_dist100 = (dist .- mean(dist)) ./ 100
    c_arsenic = arsenic .- mean(arsenic)
    da_inter = c_dist100 .* c_arsenic
    educ4 = educ ./ 4.0

    x = hcat(c_dist100, c_arsenic, da_inter, educ4)

    alpha ~ Turing.Flat()
    beta ~ filldist(Turing.Flat(), 4)
    
    switched .~ BernoulliLogit.(alpha .+ x * beta)
end