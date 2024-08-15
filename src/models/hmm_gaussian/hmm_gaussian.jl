using Turing
using LinearAlgebra
using HiddenMarkovModels
using LogExpFunctions

@model function hmm_gaussian(T, K, y)
    pi1 ~ Dirichlet(softmax(ones(K)))
    A ~ filldist(Dirichlet(softmax(ones(K))), K)
    mu ~ Bijectors.ordered(arraydist(Normal.([10*k for k in 1:K], 1)))
    sigma ~ filldist(Turing.FlatPos(0), K)
    
    hmm = HMM(pi1, vcat(A)', [Normal(mu[i], sigma[i]) for i in 1:K])
    Turing.@addlogprob! logdensityof(hmm, y)

    seq, _ = viterbi(hmm, y)
    zstar := [mu[s] for s in seq]
end