using Turing, LinearAlgebra

@model function sesame_one_pred_a(N, encouraged, watched)
    beta ~ filldist(Turing.Flat(), 2)
    sigma ~ Turing.FlatPos(0)

    watched ~ MvNormal(beta[1] + beta[2]*encouraged, sigma^2*I)
end