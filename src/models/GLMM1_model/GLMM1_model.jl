using LinearAlgebra
using Turing
using FillArrays

@model function GLMM1_model(nobs, nmis, nyear, nsite, obs, obsyear, obssite, misyear, missite)
    mu_alpha ~ Normal(0, 10)
    sd_alpha ~ Uniform(0, 5)
    alpha ~ MvNormal(Fill(mu_alpha, nsite), sd_alpha^2 .* I)

    log_lambda := repeat(alpha, 1, nyear)'

    for i in 1:nobs
        obs[i] ~ LogPoisson(log_lambda[obsyear[i], obssite[i]])
    end

    # Generated Quantities:
    # Turing: not implemented yet for AD reasons
end