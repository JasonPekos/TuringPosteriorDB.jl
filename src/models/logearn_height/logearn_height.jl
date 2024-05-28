using Turing
using LinearAlgebra

@model function logearn_height(N, earn, height; log_earn = log.(earn))
    beta ~ filldist(Turing.Flat(), 2)
    sigma ~ Turing.FlatPos(0)

    log_earn ~ MvNormal(beta[1] .+ beta[2] .* height, sigma^2*I)
end