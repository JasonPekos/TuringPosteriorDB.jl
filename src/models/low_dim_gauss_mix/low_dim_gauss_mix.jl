using Turing
using Bijectors
using LogExpFunctions
using LinearAlgebra
using FillArrays

@model function low_dim_gauss_mix(N, y)
    mu ~ Bijectors.ordered(MvNormal(Fill(0, 2), 4 .* I))
    sigma ~ arraydist([truncated(Normal(0, 2), lower = 0) for _ in 1:2])
    theta ~ Beta(5, 5)

    y ~ MixtureModel([Normal(mu[1], sigma[1]), Normal(mu[2], sigma[2])],
                     [theta, 1 - theta])
end