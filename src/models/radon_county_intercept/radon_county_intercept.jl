using Turing
using LinearAlgebra
using FillArrays


@model function radon_county_intercept(N, J, county_idx, floor_measure, log_radon)
    sigma_y ~ Truncated(Normal(0, 1), 0, Inf)
    alpha ~ MvNormal(fill(0, J), 100I)
    beta ~ Normal(0, 10)

    log_radon ~ MvNormal(alpha[county_idx] .+ beta .* floor_measure, sigma_y^2 .* I)
end