using Turing 
using LinearAlgebra

@model function logearn_interaction(N, earn, height, male)
    # Breaks from Stan model: does not define new variable log_earn
    # to keep the Turing compiler happy.
    earn = log.(earn)
    inter = height .* male

    beta ~ filldist(Turing.Flat(), 4)
    sigma ~ Turing.FlatPos(0)
    
    earn ~ MvNormal(beta[1] .+ beta[2] .* height .+ beta[3] .* male .+ beta[4] .* inter, sigma^2*I)
end