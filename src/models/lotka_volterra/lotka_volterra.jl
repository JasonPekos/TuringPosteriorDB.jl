using Turing
using LinearAlgebra
using DifferentialEquations

# Define Diffeq in DifferentialEquations form
function lotka_volterra!(dz, z, p, t)
    alpha, beta, gamma, delta = p
    u, v = z

    # Evaluate differential equations.
    dz[1] = (alpha - beta * v) * u # prey
    dz[2] = (- gamma + delta * u) * v # predator

    return nothing
end


# Define Turing Model
@model function lotka_volterra(N, ts, y_init, y)
    theta ~ arraydist([
        Truncated(Normal(1, 0.5), 0, Inf),
        Truncated(Normal(0.05, 0.05), 0, Inf),
        Truncated(Normal(1, 0.5), 0, Inf),
        Truncated(Normal(0.05, 0.05), 0, Inf)
    ])

    sigma ~ filldist(LogNormal(-1, 1), 2)
    z_init ~ filldist(LogNormal(log(10), 1), 2)

    prob = ODEProblem(lotka_volterra!, z_init, (0, ts[end]), theta)
    z = solve(prob, DP5(), saveat = ts)

    z1 := z[1, :]
    z2 := z[2, :]

    # If the solver failed, reject (taken roughly from DiffEqBayes.jl)
    if length(z[1,:]) < N || any(z .< 0)
        Turing.DynamicPPL.acclogp!!(__varinfo__, -Inf)
        return
    end

    for i in 1:2
        y_init[i] ~ LogNormal(log(z_init[i]), sigma[i])
        y[:, i] ~ MvLogNormal(log.(z[i, :]), sigma[i]^2 .* I)
    end

    # Generated Quantities:
    # Todo, it's a bit finicky because the rand() calls break
    # autodiff, so not yet set on how to do this inside the model.
end