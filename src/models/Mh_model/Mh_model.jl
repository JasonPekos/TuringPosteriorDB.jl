using Turing
using LogExpFunctions
using FillArrays
using LinearAlgebra

@model function Mh_model(M, T, y;
    s = [sum(y[i, :]) for i in 1:M],
    C = count(x -> x > 0, s))

    omega ~ Uniform(0, 1)
    mean_p ~ Uniform(0, 1)
    sigma ~ Uniform(0, 5)
    eps_raw ~ MvNormal(Fill(0, M), I)

    eps := logit(mean_p) .+ sigma .* eps_raw

    for i in 1:M
        if s[i] > 0
            Turing.@addlogprob! logpdf(Bernoulli(omega), 1)
            Turing.@addlogprob! logpdf(BinomialLogit(T, eps[i]), s[i])
        else
            Turing.@addlogprob! logsumexp([
                logpdf(Bernoulli(omega), 1) + logpdf(BinomialLogit(T, eps[i]), s[i]),
                logpdf(Bernoulli(omega), 0)
            ])
        end
    end

    # Generated Quantities – missing z[i] due to rand call + autodiff

end