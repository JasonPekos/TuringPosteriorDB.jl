using Turing
using LinearAlgebra
using LogExpFunctions

@model function GLM_Binomial_model(nyears, C, N, year; year_squared = year .* year)
    alpha ~ Normal(0, 100)
    beta1 ~ Normal(0, 100)
    beta2 ~ Normal(0, 100)

    logit_p := alpha .+ beta1 .* year .+ beta2 .* year_squared

    C .~ BinomialLogit.(N, logit_p)

    # Generated Quantities:
    p := logistic.(logit_p)
end