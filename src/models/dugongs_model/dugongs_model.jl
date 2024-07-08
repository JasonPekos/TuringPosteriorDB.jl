using Turing
using LinearAlgebra
using LogExpFunctions

@model function dugongs_model(N, x, Y)
    alpha ~ Normal(0, 1000)
    beta ~ Normal(0, 1000)
    lambda ~ Uniform(0.5, 1.0)
    tau ~ Gamma(1.0e4, 1.0e-4)

    sigma := 1 / sqrt(tau)
    U3 := logit(lambda)

    Y ~ MvNormal(alpha .- beta .* lambda .^ x, sigma^2 .* I)
end