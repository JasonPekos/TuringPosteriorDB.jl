using Turing
using LinearAlgebra


@model function logmesquite_logvas(N, weight, diam1, diam2, canopy_height, total_height, density, group; log_weight = log.(weight))
    log_canopy_volume = log.(diam1 .* diam2 .* canopy_height)
    log_canopy_area = log.(diam1 .* diam2)
    log_canopy_shape = log.(diam1 ./ diam2)
    log_total_height = log.(total_height)
    log_density = log.(density)

    beta ~ filldist(Turing.Flat(), 7)
    sigma ~ Turing.FlatPos(0)

    log_weight ~ MvNormal(beta[1] .+ 
                          beta[2] .* log_canopy_volume .+ 
                          beta[3] .* log_canopy_area .+
                          beta[4] .* log_canopy_shape .+
                          beta[5] .* log_total_height .+
                          beta[6] .* log_density .+ 
                          beta[7] .* group,
                          sigma^2 .* I)
end