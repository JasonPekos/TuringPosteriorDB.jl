using Turing
using LinearAlgebra
using FillArrays


@model function radon_hierarchical_intercept_centered(J, N, county_idx, log_uppm, floor_measure, log_radon)
    mu_alpha ~  Normal(0, 10)
    sigma_alpha ~ Truncated(Normal(0, 1), 0, Inf)
    beta ~ MvNormal(fill(0, 2), 100)
    sigma_y ~ Truncated(Normal(0, 1), 0, Inf)

    alpha ~ MvNormal(fill(mu_alpha, J), sigma_alpha^2 .* I)

    log_radon ~ MvNormal((alpha[county_idx] .+ log_uppm .* beta[1]) .+ floor_measure .* beta[2] , sigma_y .* I)
end