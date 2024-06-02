using Turing
using LinearAlgebra


@model function kilpisjarvi(N, x, y, xpred, pmualpha, psalpha, pmubeta, psbeta)
    alpha ~ Normal(pmualpha, psalpha)
    beta ~ Normal(pmubeta, psbeta)
    sigma ~ Turing.FlatPos(0)

    y ~ MvNormal(alpha .+ beta .* x, sigma^2 .* I)
end