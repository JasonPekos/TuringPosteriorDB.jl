using Turing

@model function earn_height(earn, height)
  beta ~ filldist(Turing.Flat(), 2)
  sigma ~ Turing.FlatPos(0)
  
  earn ~ Normal(beta[1] + beta[2] * height, sigma)
end