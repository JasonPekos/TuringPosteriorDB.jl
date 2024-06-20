using Turing
using LinearAlgebra

@model function radon_variable_intercept_slope_centered(N, J, county_idx, floor_measure, log_radon)
    sigma_y ~ Truncated(Normal(0, 1), 0, Inf)
    sigma_beta ~ Truncated(Normal(0, 1), 0, Inf)
    sigma_alpha ~ Truncated(Normal(0, 1), 0, Inf)

    mu_alpha ~ Normal(0, 10)
    mu_beta ~ Normal(0, 10)

    alpha ~ MvNormal(fill(mu_alpha, J), sigma_alpha^2 .* I)
    beta ~ MvNormal(fill(mu_beta, J), sigma_beta^2 .* I)

    log_radon ~ MvNormal(alpha[county_idx] .+ floor_measure .* beta[county_idx], sigma_y^2 .* I)
end