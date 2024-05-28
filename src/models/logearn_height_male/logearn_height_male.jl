using Turing
using LinearAlgebra

@model function logearn_height_male(N, earn, height, male)
    # Breaks from Stan model: does not define new variable log_earn
    # to keep the Turing compiler happy.
    earn = log.(earn)
    beta ~ filldist(Turing.Flat(), 3)
    sigma ~ Turing.FlatPos(0)

    earn ~ MvNormal(beta[1] .+ beta[2] .* height .+ beta[3] .* male, sigma^2*I)
end