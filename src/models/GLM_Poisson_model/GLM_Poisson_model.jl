using Turing
using LinearAlgebra

@model function GLM_Poisson_model(n, C, year; year_squared = year.^2, year_cubed = year.^3)
    alpha ~ Uniform(-20, 20)
    beta1 ~ Uniform(-10, 10)
    beta2 ~ Uniform(-10, 10)
    beta3 ~ Uniform(-10, 10)

    # Stan does year .+ +beta2 (double plus sign) for unknown reasons
    log_lambda := alpha .+ beta1 .* year .+ beta2 .* year_squared .+ beta3 .* year_cubed

    C .~ LogPoisson.(log_lambda)

    # Generated Quantities
    lambda := exp.(log_lambda)
end