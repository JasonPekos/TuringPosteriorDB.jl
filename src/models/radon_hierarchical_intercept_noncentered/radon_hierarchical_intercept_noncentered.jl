using Turing
using LinearAlgebra


@model function radon_hierarchical_intercept_noncentered(J, N, county_idx, log_uppm, floor_measure, log_radon)
    sigma_alpha ~ Truncated(Normal(0, 1), 0, Inf)
    sigma_y ~ Truncated(Normal(0, 1), 0, Inf)
    mu_alpha ~ Normal(0, 10)
    beta ~ MvNormal([0, 0], 100*I)
    alpha_raw ~ MvNormal(fill(0, J), 100*I)

    alpha := mu_alpha .+ sigma_alpha .* alpha_raw

    log_radon ~ MvNormal((alpha[county_idx] .+ log_uppm .* beta[1]) .+ floor_measure .* beta[2], sigma_y^2 .* I)
end