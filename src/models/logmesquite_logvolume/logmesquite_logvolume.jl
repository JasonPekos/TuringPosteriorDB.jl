using Turing
using LinearAlgebra


@model function logmesquite_logvolume(N, weight, diam1, diam2, canopy_height; log_weight = log.(weight))
    log_canopy_volume = log.(diam1 .* diam2 .* canopy_height)

    beta ~ filldist(Turing.Flat(), 2)
    sigma ~ Turing.FlatPos(0)

    log_weight ~ MvNormal(beta[1] .+ 
                          beta[2] .* log_canopy_volume, sigma^2 .* I)
end