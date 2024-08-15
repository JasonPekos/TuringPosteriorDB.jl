using Turing
using LogExpFunctions
using FillArrays
using LinearAlgebra

@model function Mth_model(M, T, y;
    s = [sum(y[i, :]) for i in 1:M],
    C = count(x -> x > 0, s))

    omega ~ Uniform(0, 1)
    mean_p ~ filldist(Uniform(0, 1), T)
    sigma ~ Uniform(0, 5)
    eps_raw ~ MvNormal(Fill(0, M), I)

    eps := sigma .* eps_raw
    mean_lp := logit.(mean_p)

    logit_p = [mean_lp[j] + eps[i] for i in 1:M, j in 1:T]    
    
    for i in 1:M
        if s[i] > 0
            Turing.@addlogprob! logpdf(Bernoulli(omega), 1)
            Turing.@addlogprob! sum(logpdf.(BernoulliLogit.(logit_p[i, :]), y[i, :]))
        else
            Turing.@addlogprob! logsumexp([
                logpdf(Bernoulli(omega), 1) + sum(logpdf.(BernoulliLogit.(logit_p[i, :]), y[i, :])),
                logpdf(Bernoulli(omega), 0)
            ])
        end
    end

    # Generated Quantities – missing z[i] due to rand call + autodiff

end