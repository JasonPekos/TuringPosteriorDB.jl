using Turing
using LinearAlgebra

@model function radon_variable_intercept_slope_noncentered(N, J, county_idx, floor_measure, log_radon)
    sigma_y ~ Truncated(Normal(0, 1), 0, Inf)
    sigma_beta ~ Truncated(Normal(0, 1), 0, Inf)
    sigma_alpha ~ Truncated(Normal(0, 1), 0, Inf)

    mu_alpha ~ Normal(0, 10)
    mu_beta ~ Normal(0, 10)

    alpha_raw ~ MvNormal(fill(0, J), 1)
    beta_raw ~ MvNormal(fill(0, J), 1)

    alpha := mu_alpha .+ sigma_alpha .* alpha_raw
    beta := mu_beta .+ sigma_beta .* beta_raw

    log_radon ~ MvNormal(alpha[county_idx] .+ floor_measure .* beta[county_idx], sigma_y^2 .* I)
end