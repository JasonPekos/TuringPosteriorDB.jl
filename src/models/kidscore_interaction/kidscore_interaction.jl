using Turing
using LinearAlgebra

@model function kidscore_interaction(N, kid_score, mom_iq, mom_hs)
    inter = mom_hs .* mom_iq

    beta ~ filldist(Turing.Flat(), 4)
    sigma ~ Truncated(Cauchy(0, 2.5), 0, Inf)


    kid_score ~ MvNormal(beta[1] .+ 
                         beta[2] .* mom_hs .+
                         beta[3] .* mom_iq .+
                         beta[4] .* inter, sigma^2*I)
end