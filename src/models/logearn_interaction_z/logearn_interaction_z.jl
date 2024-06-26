using Turing
using StatsBase
using LinearAlgebra

@model function logearn_interaction_z(N, earn, height, male; log_earn = log.(earn))
    z_height  = zscore(height)
    inter = z_height .* male

    beta ~ filldist(Turing.Flat(), 4)
    sigma ~ Turing.FlatPos(0)

    log_earn ~ MvNormal(beta[1] .+ beta[2] .* z_height .+ beta[3] .* male .+ beta[4] .* inter, sigma^2*I)
end