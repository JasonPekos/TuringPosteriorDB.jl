using Turing
using LinearAlgebra


@model function kidscore_momhsiq(N, kid_score, mom_iq, mom_hs)
    sigma ~ Truncated(Cauchy(0, 2.5), 0, Inf)
    beta ~ filldist(Turing.Flat(), 3)

    kid_score ~ MvNormal(beta[1] .+ beta[2] .* mom_hs + beta[3] .* mom_iq , sigma^2 .* I)
end