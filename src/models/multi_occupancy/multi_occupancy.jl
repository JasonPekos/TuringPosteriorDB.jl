using LinearAlgebra
using Turing
using LogExpFunctions
using Distributions

function cov_matrix_2d(sigma, rho)
    [sigma[1]^2 sigma[1] * sigma[2] * rho;
     sigma[1] * sigma[2] * rho  sigma[2]^2]
end

function lp_observed(X, K, logit_psi, logit_theta)
    -softplus(-logit_psi) + logpdf(BinomialLogit(K, logit_theta), X)
end

function lp_unobserved(K, logit_psi, logit_theta)
    logsumexp([lp_observed(0, K, logit_psi, logit_theta),
               -softplus(logit_psi)])
end

function lp_never_observed(J, K, logit_psi, logit_theta, Omega)
    logsumexp(
        [logpdf(Bernoulli(Omega), 0),
         logpdf(Bernoulli(Omega), 1) + J *
         lp_unobserved(K, logit_psi, logit_theta)])
end

@model function multi_occupancy(J, K, n, X, S)
    alpha ~ Cauchy(0, 2.5)
    beta ~ Cauchy(0, 2.5)
    sigma_uv ~ filldist(truncated(Cauchy(0, 2.5), lower = 0), 2)
    Omega ~ Beta(2, 2)
    
    rho_uv ~ 2*Beta(2, 2) - 1
    uv1 ~ filldist(Turing.Flat(), S)
    uv2 ~ filldist(Turing.Flat(), S)

    uv := hcat(uv1, uv2)

    logit_psi := uv[:, 1] .+ alpha
    logit_theta := uv[:, 2] .+ beta

    for i in 1:n
        Turing.@addlogprob! logpdf(Bernoulli(Omega), 1)
        for j in 1:J
            if X[i, j] > 0
                Turing.@addlogprob! lp_observed(X[i, j], K, logit_psi[i], logit_theta[i])
            else
                Turing.@addlogprob! lp_unobserved(K, logit_psi[i], logit_theta[i])
            end
        end
    end
    
    for i in (n+1):S
        Turing.@addlogprob! lp_never_observed(J, K, logit_psi[i], logit_theta[i], Omega)
    end

    # Generated quantities missing because of rng calls and autodiff
end

