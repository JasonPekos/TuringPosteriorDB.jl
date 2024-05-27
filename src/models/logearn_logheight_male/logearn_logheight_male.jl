using Turing 

@model function logearn_logheight_male(N, earn, height, male)
    log_earn = log.(earn)
    log_height = log.(height)

    beta ~ filldist(Turing.Flat(), 4)
    sigma ~ Turing.FlatPos(0)

    log_earn ~ Normal(beta[1] + beta[2] * log_height + beta[3] * male, sigma)
end