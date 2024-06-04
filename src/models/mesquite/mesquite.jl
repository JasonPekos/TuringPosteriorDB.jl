using Turing
using LinearAlgebra


@model function mesquite(N, weight, diam1, diam2, canopy_height, total_height, density, group)
    beta ~ filldist(Turing.Flat(), 7)
    sigma ~ Turing.FlatPos(0)

    weight ~ MvNormal(beta[1] .+ 
                      beta[2] .* diam1 .+ 
                      beta[3] .* diam2 .+
                      beta[4] .* canopy_height .+
                      beta[5] .* total_height .+
                      beta[6] .* density .+
                      beta[7] .* group, sigma^2 .* I)
end