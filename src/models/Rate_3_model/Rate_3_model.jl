using Turing

@model function Rate_3_model(n1, n2, k1, k2)
    theta ~ Beta(1, 1)

    k1 ~ Binomial(n1, theta)
    k2 ~ Binomial(n2, theta)
end