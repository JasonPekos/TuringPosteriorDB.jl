using LinearAlgebra
using Turing
using FillArrays
using Distributions

@model function logistic_regression_rhs(n, d, y, x, scale_icept, scale_global, nu_global, nu_local, slab_scale, slab_df)
    z ~ MvNormal(Fill(0, d), I)
    lambda ~ filldist(Truncated(TDist(nu_local), 0, Inf), d)
    tau ~ Truncated(scale_global*2*TDist(nu_global), 0, Inf)
    caux ~ filldist(InverseGamma(0.5 * slab_df, 0.5 * slab_df), d)
    beta0 ~ Normal(0, scale_icept)

    # Transformed Parameters
    c := slab_scale .* sqrt.(caux)
    lambda_tilde := sqrt.(c.^2 .* lambda.^2 ./ (c.^2 .+ tau.^2 .* lambda.^2))
    beta := z .* lambda_tilde .* tau

    # Likelihood
    y .~ BernoulliLogit.(beta0 .+ x * beta)

    # Generated Quantities
    f := beta0 .+ x * beta
    log_lik := pdf.(BernoulliLogit.(beta0 .+ x * beta), y)
end