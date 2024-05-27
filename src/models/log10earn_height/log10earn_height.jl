using Turing

@model function log10earn_height(N, earn, height)
    log10_earn = log10.(earn)
    beta ~ filldist(Turing.Flat(), 2)
    sigma ~ Turing.FlatPos(0)

    log10_earn ~ Normal(beta[1] + beta[2] * height, sigma)
end