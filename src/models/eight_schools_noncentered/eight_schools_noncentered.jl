using Turing
using FillArrays
using LinearAlgebra

@model function eight_schools_noncentered(J, y, sigma)
    tau ~ Truncated(Cauchy(0, 5); lower = 0)
    mu ~ Normal(0, 5)
    theta_trans ~ MvNormal(Fill(theta, J), I)

    theta := theta_trans .* tau .+ mu
    y ~ MvNormal(theta, sqrt.(sigma)*I)
end