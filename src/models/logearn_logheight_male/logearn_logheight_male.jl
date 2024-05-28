using Turing 
using LinearAlgebra

@model function logearn_logheight_male(N, earn, height, male)
    # Breaks from Stan model: does not define new variable log_earn
    # to keep the Turing compiler happy.
    earn = log.(earn) 
    log_height = log.(height)

    beta ~ filldist(Turing.Flat(), 4)
    sigma ~ Turing.FlatPos(0)

    earn ~ MvNormal(beta[1] .+ beta[2] .* log_height .+ beta[3] .* male, sigma^2*I)
end