using Turing

# Inferring a Common Rate, With Posterior Predictive
@model function Rate_5_model(n1, n2, k1, k2)
    theta ~ Beta(1, 1)
    k1 ~ Binomial(n1, theta)
    k2 ~ Binomial(n2, theta)

    postpredk1 := rand(Binomial(n1, theta))
    postpredk2 := rand(Binomial(n2, theta))
end