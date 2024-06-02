using Turing
using LinearAlgebra


@model function blr(N, D, X, y)
    beta ~ filldist(Normal(0, 10), D)
    sigma ~ Truncated(Normal(0, 10), 0, Inf)

    y ~ MvNormal(X*beta, sigma^2*I)
end