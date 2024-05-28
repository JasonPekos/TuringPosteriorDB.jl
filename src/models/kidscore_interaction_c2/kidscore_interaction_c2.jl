using Turing, LinearAlgebra

@model function kidscore_interaction_c2(N, kid_score, mom_hs, mom_iq)
    mom_hs_c = mom_hs .- 0.5
    mom_iq_c = mom_iq .- 100
    inter = mom_hs_c .* mom_iq_c

    sigma ~ Turing.FlatPos(0)
    beta ~ filldist(Turing.Flat(), 4)
    
    kid_score ~ MvNormal(beta[1] .+
                        beta[2] .* mom_hs_c .+
                        beta[3] .* mom_iq_c .+
                        beta[4] .* inter, sigma^2*I)
end