using Turing
using LinearAlgebra

@model function radon_partially_pooled_centered(N, J, county_idx, log_radon)
    sigma_y ~ Truncated(Normal(0, 1), 0, Inf)
    sigma_alpha ~ Truncated(Normal(0, 1), 0, Inf)
    mu_alpha ~ Normal(0, 10)

    alpha ~ Normal(mu_alpha, sigma_alpha)

    log_radon ~ MvNormal(alpha[county_idx], sigma_y^2 .* I)
end