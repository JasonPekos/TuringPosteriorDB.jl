using Turing

# Prior and Posterior Prediction
@model function Rate_4_model(n, k)
    theta ~ Beta(1, 1)
    thetaprior ~ Beta(1, 1)

    k ~ Binomial(n, theta)

    postpredk := rand(Binomial(n, theta))
    priorpredk := rand(Binomial(n, thetaprior))
end

