using Turing
using LinearAlgebra
using FillArrays


@model function radon_variable_intercept_noncentered(J, N, county_idx, floor_measure, log_radon)
    alpha_raw ~ MvNormal(fill(0, J), I)
    beta ~ Normal(0, 10)
    mu_alpha ~ Normal(0, 10)
    sigma_alpha ~ Truncated(Normal(0, 1), 0, Inf)
    sigma_y ~ Truncated(Normal(0, 1), 0, 1)
    alpha := mu_alpha .+ sigma_alpha .* alpha_raw

    log_radon ~ MvNormal(alpha[county_idx] .+ floor_measure * beta, sigma_y^2 .* I)
end