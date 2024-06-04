using Turing
using LinearAlgebra
using FillArrays

@model function seeds_centered_model(I, n, N, x1, x2; x1x2 = x1 .* x2)
    alpha0 ~ Normal(0, 1)
    alpha1 ~ Normal(0, 1)
    alpha2 ~ Normal(0, 1)
    alpha12 ~ Normal(0, 1)
    sigma ~ Truncated(Cauchy(0, 1), 0, Inf)

    c ~ MvNormal(fill(0, I), UniformScaling(sigma^2))
    b := c .- mean(c)

    n .~ Turing.BinomialLogit.(N, alpha0 .+
                                alpha1 .* x1 .+
                                alpha2 .* x2 .+
                                alpha12 .* x1x2 .+
                                b)
end