using Turing
using LinearAlgebra


@model function logmesquite_logva(N, weight, diam1, diam2, canopy_height, group; log_weight = log.(weight))
    log_canopy_volume = log.(diam1 .* diam2 .* canopy_height)
    log_canopy_area = log.(diam1 .* diam2)

    beta ~ filldist(Turing.Flat(), 4)
    sigma ~ Turing.FlatPos(0)

    log_weight ~ MvNormal(beta[1] .+ 
                          beta[2] .* log_canopy_volume .+ 
                          beta[3] .* log_canopy_area .+
                          beta[4] .* group,
                          sigma^2 .* I)
end