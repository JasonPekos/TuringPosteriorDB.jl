using Turing
using LinearAlgebra


@model function kidscore_momiq(N, kid_score, mom_iq)
    sigma ~ Truncated(Cauchy(0, 2.5), 0, Inf)
    beta ~ filldist(Turing.Flat(), 2)

    kid_score ~ MvNormal(beta[1] .+ beta[2] .* mom_iq, sigma^2*I)
end