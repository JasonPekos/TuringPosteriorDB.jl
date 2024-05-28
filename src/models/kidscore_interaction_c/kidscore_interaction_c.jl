using Turing, LinearAlgebra

@model function kidscore_interaction_c(N, kid_score, mom_hs, mom_iq)    
    c_mom_hs = mom_hs .- mean(mom_hs) 
    c_mom_iq = mom_iq .- mean(mom_iq)
    inter = c_mom_hs .* c_mom_iq

    sigma ~ Turing.FlatPos(0)
    beta ~ filldist(Turing.Flat(), 4)

    kid_score ~ MvNormal(beta[1] .+ 
                         beta[2] .* c_mom_hs .+ 
                         beta[3] .* c_mom_iq .+ 
                         beta[4] .* inter, sigma^2*I)
end