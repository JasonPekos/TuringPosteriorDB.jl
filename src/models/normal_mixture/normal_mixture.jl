using Turing
using LinearAlgebra
using LogExpFunctions
using FillArrays

@model function normal_mixture(N, y)
    theta ~ Uniform(0, 1)
    mu ~ MvNormal(Fill(0, 2), 100 .* I)

    y ~ MixtureModel([Normal(mu[i], 1.0) for i in 1:2], 
                     [theta, 1-theta])
end