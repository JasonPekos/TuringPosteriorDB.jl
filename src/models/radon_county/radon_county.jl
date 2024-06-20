using Turing
using LinearAlgebra
using FillArrays


@model function radon_county(N, J, county, y)
    mu_a ~ Normal(0, 1)
    sigma_a ~ Uniform(0, 100)
    sigma_y ~ Uniform(0, 100)
    
    a ~ MvNormal(fill(mu_a, J), sigma_a^2 .* I)
    y ~ MvNormal(a[county], sigma_y^2 .* I)
end