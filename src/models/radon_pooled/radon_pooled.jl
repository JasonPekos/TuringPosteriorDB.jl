using Turing
using LinearAlgebra

@model function radon_pooled(N, floor_measure, log_radon)
    sigma_y ~ Truncated(Normal(0, 1), 0, Inf)
    alpha ~ Normal(0, 10)
    beta ~ Normal(0, 10)

    log_radon ~ MvNormal(alpha .+ beta .* floor_measure, sigma_y^2 .* I)
end