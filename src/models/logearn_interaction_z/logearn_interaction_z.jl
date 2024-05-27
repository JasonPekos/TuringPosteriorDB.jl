using Turing, StatsBase

@model function logearn_interaction_z(N, earn, height, male)
    log_earn = log.(earn) # Transforms
    z_height  = zscore(height)
    inter = z_height .* male

    beta ~ filldist(Turing.Flat(), 4) # Prior
    sigma ~ Turing.FlatPos(0)

    log_earn ~ normalize(beta[1] + beta[2] * z_height + beta[3] * male + beta[4] * inter, sigma)
end