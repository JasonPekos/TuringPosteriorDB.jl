using Turing
using LinearAlgebra
using FillArrays

@model function pilots(N, n_groups, n_scenarios, group_id, scenario_id, y)
    sigma_y ~ Uniform(0, 100)

    mu_a ~ Normal(0, 1)
    sigma_a ~ Uniform(0, 100)
    a ~ MvNormal(fill(mu_a, n_groups), sigma_a^2 .* I)

    mu_b ~ Normal(0, 1)
    sigma_b ~ Uniform(0, 100)
    b ~ MvNormal(fill(10 * mu_b, n_scenarios), sigma_b^2 .* I)

    y_hat := a[group_id] .+ b[scenario_id]

    y ~ MvNormal(y_hat, sigma_y^2 .* I)
end