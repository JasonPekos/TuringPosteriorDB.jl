using Turing
using LinearAlgebra

@model function rats_model(N, Npts, rat, x, y, xbar)
    mu_alpha ~ Normal(0, 100)
    mu_beta ~ Normal(0, 100)

    sigma_y ~ Turing.FlatPos(0)
    sigma_alpha ~ Turing.FlatPos(0)
    sigma_beta ~ Turing.FlatPos(0)

    alpha ~ filldist(Normal(mu_alpha, sigma_alpha), N)
    beta ~ filldist(Normal(mu_beta, sigma_beta), N)

    y ~ MvNormal(alpha[rat] .+ beta[rat] .* (x .- xbar), sigma_y^2 .* I)

    alpha0 := mu_alpha - xbar * mu_beta
end