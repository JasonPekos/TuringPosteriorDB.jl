using Turing
using LinearAlgebra

@model function wells_dist(N, switched, dist)
    beta ~ filldist(Turing.Flat(), 2)
    switched .~ BernoulliLogit.(beta[1] .+ beta[2] .* dist)
end