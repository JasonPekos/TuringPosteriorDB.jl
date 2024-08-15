using Turing
using LinearAlgebra
using LogExpFunctions

@model function M0_model(M, T, y; 
    s = [sum(y[i, :]) for i in 1:M], # Transformed data
    C = count(x -> x > 0, s)) # Currently not used, and also can be put in GQ?
    
    omega ~ Uniform(0, 1)
    p ~ Uniform(0, 1)

    for i in 1:M
        if s[i] > 0
            Turing.@addlogprob! logpdf(Bernoulli(omega), 1)
            Turing.@addlogprob! logpdf(Binomial(T, p), s[i])
        else
            Turing.@addlogprob! logsumexp([
                logpdf(Bernoulli(omega), 1) + logpdf(Binomial(T, p), 0),
                logpdf(Bernoulli(omega), 0)]
            )
        end
    end

    # Generated quantities:
    omega_nd := (omega * (1 - p) ^ T) / (omega * (1 - p) ^ T + (1 - omega))
    # N = C + rand(Binomial(M - C), omega_nd)
end