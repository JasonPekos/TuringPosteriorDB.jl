using Turing
using FillArrays

@model function seeds_model(I, n, N, x1, x2; x1x2 = x1 .* x2)
    alpha0 ~ Normal(0.0, 1.0e3)
    alpha1 ~ Normal(0.0, 1.0e3)
    alpha2 ~ Normal(0.0, 1.0e3)
    alpha12 ~ Normal(0.0, 1.0e3)
    tau ~ Gamma(1.0e-3, 1.0e-3)
    sigma := 1.0 / sqrt(tau)

    # Use UniformScaling because data already contains `I`
    b ~ MvNormal(fill(0.0, I), UniformScaling(sigma^2))
    n .~ Turing.BinomialLogit.(N, alpha0 .+ alpha1 .* x1 .+ alpha2 .* x2 .+ alpha12 .* x1x2 .+ b)
end