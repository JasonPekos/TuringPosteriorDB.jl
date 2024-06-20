using Turing
using LinearAlgebra

@model function radon_variable_intercept_centered(J, N, county_idx, floor_measure, log_radon)
    sigma_y ~ Truncated(Normal(0, 1), 0, Inf)
    sigma_alpha ~ Truncated(Normal(0, 1), 0, Inf)
    mu_alpha ~ Normal(0, 10)
    beta ~ Normal(0, 10)
    alpha ~ MvNormal(fill(mu_alpha, J), sigma_alpha .* I)
    
    log_radon ~ MvNormal(alpha[county_idx] .+ floor_measure .* beta, sigma_y^2 .* I)
end