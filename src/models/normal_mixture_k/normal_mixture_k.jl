using Turing
using LinearAlgebra
using FillArrays

@model function normal_mixture_k(K, N, y)
    theta ~ Dirichlet(K, 1.0)
    mu ~ MvNormal(Fill(0, K), 100 .* I)
    sigma ~ filldist(Turing.FlatPos(0), K)

    y ~ MixtureModel([Normal(mu[i], sigma[i]) for i in 1:K],
                      theta)
end