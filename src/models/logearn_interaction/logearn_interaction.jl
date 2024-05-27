using Turing 

@model function logearn_interaction(N, earn, height, male)
    log_earn = log.(earn)
    inter = height .* male

    beta ~ filldist(Turing.Flat(), 4)
    sigma ~ Turing.FlatPos(0)
    
    log_earn ~ MvNormal(beta[1] .+ beta[2] .* height .+ beta[3] .* male .+ beta[4] .* inter, sigma^2*I)
end