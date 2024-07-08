using Turing
using LinearAlgebra
using FillArrays

@model function wells_dae_inter_model(N, switched, dist, arsenic, educ)
    c_dist100 = (dist .- mean(dist)) ./ 100
    c_arsenic = arsenic .- mean(arsenic)
    c_educ4 = (educ .- mean(educ)) ./ 4.0

    da_inter = c_dist100 .* c_arsenic
    de_inter = c_dist100 .* c_educ4
    ae_inter = c_arsenic .* c_educ4

    x = hcat(c_dist100, c_arsenic, da_inter, c_educ4, de_inter, ae_inter)

    alpha ~ Turing.Flat()
    beta ~ filldist(Turing.Flat(), 6)
    
    switched .~ BernoulliLogit.(alpha .+ x * beta)
end