using Turing
using LinearAlgebra


@model function logmesquite(N, weight, diam1, diam2, canopy_height, total_height, density, group; log_weight = log.(weight))
    beta ~ filldist(Turing.Flat(), 7)
    sigma ~ Turing.FlatPos(0)

    log_weight ~ MvNormal(beta[1] .+ 
                          beta[2] .* log.(diam1) .+ 
                          beta[3] .* log.(diam2) .+
                          beta[4] .* log.(canopy_height) .+
                          beta[5] .* log.(total_height) .+
                          beta[6] .* log.(density) .+
                          beta[7] .* group, sigma^2 .* I)
end