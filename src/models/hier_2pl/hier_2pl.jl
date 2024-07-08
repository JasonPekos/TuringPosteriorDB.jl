using Turing
using LinearAlgebra
using FillArrays

# Todo: get Cholesky stuff working

# @model function hier_2pl(I, J, N, ii, jj, y)

#     # Model
#     theta ~ MvNormal(fill(0, I), I)
#     L_Omega ~ LKJCholesky(2, 4)
#     mu ~ arraydist([Normal(0, 1), Normal(0, 5)])
#     tau ~ filldist(Exponential(0.1), 2)

#     # Transformed Parameters
#     L_sigma = Diagonal(tau) .* L_Omega
#     xi = hcat(xi1, xi2)'
#     alpha = exp.(xi[1, :])
#     beta = xi[2, :]

#     # Likelihood
#     for i in 1:I
#         xi[:, i] ~ MvNormal(mu, L_Sigma)
#     end

#     y .~ BernoulliLogit.(alpha[ii] .* (theta[jj] .- beta[ii]))
# end