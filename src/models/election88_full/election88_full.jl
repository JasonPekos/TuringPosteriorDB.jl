using LinearAlgebra
using Turing
using FillArrays


@model function election88_full(N, n_age, n_age_edu, n_edu, n_region_full, n_state,
    age, age_edu, black, edu, female, region_full, state, v_prev_full, y)

    sigma_a ~ Uniform(0, 100)
    sigma_b ~ Uniform(0, 100)
    sigma_c ~ Uniform(0, 100)
    sigma_d ~ Uniform(0, 100)
    sigma_e ~ Uniform(0, 100)

    a ~ MvNormal(Fill(0, n_age), sigma_a^2 .* I)
    b ~ MvNormal(Fill(0, n_edu), sigma_b^2 .* I)
    c ~ MvNormal(Fill(0, n_age_edu), sigma_c^2 .* I)
    d ~ MvNormal(Fill(0, n_state), sigma_d^2 .* I)
    e ~ MvNormal(Fill(0, n_region_full), sigma_e^2 .* I)

    beta ~ MvNormal(Fill(0, 5), 100^2 .* I)

    y_hat := beta[1] .+ beta[2] .* black .+ beta[3] .* female .+ 
             beta[5] .* female .* black .+ beta[4] .* v_prev_full .+
             a[age] .+ b[edu] .+ c[age_edu] .+ d[state] .+ e[region_full]

    y .~ BernoulliLogit.(y_hat)
end