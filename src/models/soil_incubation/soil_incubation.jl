using Turing
using LinearAlgebra
using DifferentialEquations

function two_pool_feedback()

end

function evolved_CO2()

end


@model function soil_incubation(totalC_t0, t0, N_t, ts, eCO2mean)
    gamma ~ Beta(10, 1)
    k1 ~ Truncated(Normal(0, 1), 0, 1)
    k2 ~ Truncated(Normal(0, 1), 0, 1)
    alpha21 ~ Truncated(Normal(0, 1), 0, 1)
    alpha12 ~ Truncated(Normal(0, 1), 0, 1)
    sigma ~ Cauchy(0) # Check parameterization against Stan

    


end