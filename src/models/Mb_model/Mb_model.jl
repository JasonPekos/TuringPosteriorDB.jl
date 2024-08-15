using Turing
using LogExpFunctions

@model function Mb_model(M, T, y;
    s = [sum(y[i, :]) for i in 1:M],
    C = count(x -> x > 0, s))

    omega ~ Uniform(0, 1)
    p ~ Uniform(0, 1)
    c ~ Uniform(0, 1)

    p_eff := [j == 1 ? p : (1 - y[i, j - 1]) * p + y[i, j - 1] * c for i in 1:M, j in 1:T]

    for i in 1:M
        if s[i] > 0
            Turing.@addlogprob! logpdf(Bernoulli(omega), 1)
            Turing.@addlogprob! logpdf(Binomial(T, p_eff[i]), s[i])
        else
            Turing.@addlogprob! logsumexp([
                logpdf(Bernoulli(omega), 1) + logpdf(Binomial(T, p_eff[i]), s[i]),
                logpdf(Bernoulli(omega), 0)
            ])
        end
    end

    # Generated Quantities – missing N due to rand call + autodiff
    omega_nd := (omega * (1 - p) ^ T) / (omega * (1 - p) ^ T + (1 - omega))
    trap_response := c - p
end