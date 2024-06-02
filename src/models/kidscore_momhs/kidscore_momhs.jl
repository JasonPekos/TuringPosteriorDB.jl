using Turing
using LinearAlgebra


@model function kidscore_momhs(N, kid_score, mom_hs)
    sigma ~ Truncated(Cauchy(0, 2.5), 0, Inf)
    beta ~ filldist(Turing.Flat(), 2)

    kid_score ~ MvNormal(beta[1] .+ mom_hs .* beta[2] ,sigma^2 .* I)
end

