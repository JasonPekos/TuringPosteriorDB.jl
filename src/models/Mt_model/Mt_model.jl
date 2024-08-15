using Turing
using LogExpFunctions
using FillArrays
using LinearAlgebra

@model function Mt_model(M, T, y;
    s = [sum(y[i, :]) for i in 1:M],
    C = count(x -> x > 0, s))

    omega ~ Uniform(0, 1)
    p ~ filldist(Uniform(0, 1), T)

    for i in 1:M
        if s[i] > 0
            Turing.@addlogprob! logpdf(Bernoulli(omega), 1)
            Turing.@addlogprob! sum(logpdf.(Bernoulli.(p), y[i, :]))
        else
            Turing.@addlogprob! logsumexp([
                logpdf(Bernoulli(omega), 1) + sum(logpdf.(Bernoulli.(p), y[i, :])),
                logpdf(Bernoulli(omega), 0)
            ])
        end
    end

    # Generated Quantities – missing z[i] due to rand call + autodiff
end