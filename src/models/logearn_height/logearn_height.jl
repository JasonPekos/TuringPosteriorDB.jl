using Turing
using LinearAlgebra

@model function logearn_height(N, earn, height)
    # Breaks from Stan model: does not define new variable log_earn
    # to keep the Turing compiler happy.
    earn = log.(earn)

    beta ~ filldist(Turing.Flat(), 2)
    sigma ~ Turing.FlatPos(0)

    earn ~ MvNormal(beta[1] .+ beta[2] .* height, sigma^2*I)
end