using Turing
using StatsBase
using LinearAlgebra

@model function kidscore_interaction_z(N, kid_score, mom_hs, mom_iq)
    z_mom_hs = (mom_hs .- mean(mom_hs)) ./ (2 .* std(mom_hs))
    z_mom_iq = (mom_iq .- mean(mom_iq)) ./ (2 .* std(mom_iq))
    inter = z_mom_iq .* z_mom_hs    

    beta ~ filldist(Turing.Flat(), 4)
    sigma ~ Turing.FlatPos(0)

    kid_score ~ MvNormal(beta[1] .+
                         beta[2] .* z_mom_hs .+ 
                         beta[3] .* z_mom_iq .+ 
                         beta[4] .* inter, sigma^2*I)
end