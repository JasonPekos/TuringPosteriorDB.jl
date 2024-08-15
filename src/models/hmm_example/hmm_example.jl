using Turing
using LinearAlgebra
using HiddenMarkovModels
using LogExpFunctions


@model function hmm_example(N, K, y)
    mu ~ Bijectors.ordered(MvNormal([3.0, 10.0], I))
    theta1 ~ Dirichlet(softmax(ones(K)))
    theta2 ~ Dirichlet(softmax(ones(K)))
    θ = vcat(theta1', theta2')

    hmm = HMM(softmax(ones(K)), θ, [Normal(mu[1], 1), Normal(mu[2], 1)])
    Turing.@addlogprob! logdensityof(hmm, y)

    # TODO: Generated quantities with Viterbi
end