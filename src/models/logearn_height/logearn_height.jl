using Turing

#=
data {
  int<lower=0> N;
  vector[N] earn;
  vector[N] height;
}
transformed data {
  // log transformation
  vector[N] log_earn;
  log_earn = log(earn);
}
parameters {
  vector[2] beta;
  real<lower=0> sigma;
}
model {
  log_earn ~ normal(beta[1] + beta[2] * height, sigma);
}
=#


@model function logearn_height(N, earn, height)
    log_earn = log.(earn)

    beta ~ filldist(Turing.Flat(), 2)
    sigma = Turing.FlatPos(0)

    log_earn ~ Normal(beta[1] + beta[2] * height, sigma)
end