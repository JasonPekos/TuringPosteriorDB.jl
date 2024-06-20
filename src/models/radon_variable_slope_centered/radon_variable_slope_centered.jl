using Turing
using LinearAlgebra

@model function radon_variable_slope_centered(J, N, county_idx, floor_measure, log_radon)
    alpha ~ Normal(0, 10)
    sigma_y ~ Truncated(Normal(0, 1), 0, Inf)
    sigma_beta ~ Truncated(Normal(0, 1), 0, Inf)
    mu_beta ~ Normal(0, 10)

    beta ~ Normal(fill(mu_beta, J), sigma_beta ^2 .* I)

    log_radon ~ MvNormal(alpha .+ floor_measure .* beta[county_idx], sigma_y^2 .* I)
end