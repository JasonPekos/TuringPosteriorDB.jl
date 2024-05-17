using Turing

@model function Rate_1_model(n, k)
    theta ~ Beta(1, 1)
    k ~ Binomial(n, theta)
end

# can you see me git?