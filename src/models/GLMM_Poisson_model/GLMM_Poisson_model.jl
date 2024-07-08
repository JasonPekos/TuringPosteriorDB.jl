using Turing
using LinearAlgebra
using FillArrays

@model function GLMM_Poisson_model(n, C, year; year_squared = year .^2, year_cubed = year .^3)
    alpha ~ Uniform(-20, 20)
    beta1 ~ Uniform(-10, 10)
    beta2 ~ Uniform(-10, 10)
    beta3 ~ Uniform(-10, 10)
    sigma ~ Uniform(0, 5)
    eps ~ MvNormal(fill(0, n), sigma^2 .* I)

    log_lambda := alpha .* beta1 .* year .+ beta2 .* year_squared .+ beta3 .* year_cubed .+ eps

    C .~ LogPoisson.(log_lambda)

    # Generated Quantities
    lambda := exp.(log_lambda)
end