using LinearAlgebra
using Turing
using FillArrays

@model function irt_2pl(I, J, y)
    sigma_theta ~ Truncated(Cauchy(0, 2), 0, Inf)
    theta ~ MvNormal(fill(0, J), sigma_theta)

    sigma_a ~ Truncated(Cauchy(0, 2), 0, Inf)
    a ~ MvLogNormal(fill(0, I), sigma_a)

    mu_b ~ Normal(0, 5)
    sigma_b ~ Truncated(Cauchy(0, 2), 0, Inf)
    b ~ MvNormal(fill(mu_b, I), sigma_b)

    for i in 1:I
        y[i,:] ~ arraydist([BernoulliLogit(a[i] .* (theta[j] .- b[i])) for j in 1:J])
    end
end