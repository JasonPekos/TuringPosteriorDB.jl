using Turing
using LinearAlgebra
using FillArrays
using LogExpFunctions

@model function surgical_model(N, r, n)
    mu ~ Normal(0, 1000)
    sigmasq ~ InverseGamma(0.001, 0.001)
    sigma := sqrt.(sigmasq)
    b ~ MvNormal(Fill(mu, N), sigma^2 .* I)
    p := logistic.(b)

    r .~ BinomialLogit.(n, b)

    # Generated Quantities.
    pop_mean := logistic.(mu)
end