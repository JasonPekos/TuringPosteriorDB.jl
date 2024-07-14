using Turing
using LinearAlgebra
using DifferentialEquations

# Define Diffeq in DifferentialEquations form
function lotka_volterra!(dz, z, p, t)
    dz[1] = (p[1] - p[2] * z[2]) * z[1] # prey
    dz[2] = (-p[3] + p[4] * z[1]) * z[2] # predator
    return nothing
end


# Placeholder ODE
prob = ODEProblem(lotka_volterra!, [35.0, 5.0], (0.0, 20.0), [1.0, 0.05, 1.0, 0.05])
solve(prob)

@model function lotka_volterra(N, ts, y_init, y)
    theta ~ arraydist([
        truncated(Normal(1, 0.5), lower = 0),
        truncated(Normal(0.05, 0.05), lower = 0),
        truncated(Normal(1, 0.5), lower = 0),
        truncated(Normal(0.05, 0.05), lower = 0)
    ])

    sigma ~ filldist(LogNormal(-1, 1), 2)
    z_init ~ filldist(LogNormal(log(10), 1), 2)

    # Create trajectory for this parameter set
    
    z = solve(prob, DP5(); p = theta, tspan = (0, ts[end]), u0 = z_init, saveat = ts)
    # Include trajectories in chain to match Stan
    z1 := z[1, :]
    z2 := z[2, :]

    # If the solver failed, reject (taken roughly from DiffEqBayes.jl)
    if z.retcode != :Success || any(z .< 0)
        Turing.DynamicPPL.acclogp!!(__varinfo__, -Inf)
        return
    end

    # Initial Condition Likelihood (y_init is observed)
    for i in 1:2
        y_init[i] ~ LogNormal(log(z_init[i]), sigma[i])
        y[:, i] ~ MvLogNormal(log.(z[i, :]), sigma[i]^2 .* I)
    end

    # Missing: Generated Quantities
end
