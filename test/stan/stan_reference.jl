# Stan side of the log-density check. For one posteriordb posterior, evaluate
# Stan's log density at a set of points and save them as JSON that any other
# language can read:
#
#   test/reference/<posterior>.json = {posterior, model, names, points, lp}
#
# `points` are in the constrained space (the parameters as the model block
# sees them), flattened in Stan's order with Stan's names ("theta.1", "L.2.1").
# `lp` is the full log joint at each point: every constant kept and no Jacobian
# term, so it does not depend on how either language unconstrains a parameter.
#
#   julia --project=test/stan test/stan/stan_reference.jl            # posteriors with no file yet
#   julia --project=test/stan test/stan/stan_reference.jl a-b ...    # write these again
#
# The tests read the saved files and never run this, so they need no Stan.
# BridgeStan compiles each model, which needs a C++ toolchain.

using BridgeStan, PosteriorDB, JSON, Random
using AdvancedHMC, AbstractMCMC, LogDensityProblems

const BUILD = joinpath(@__DIR__, "build")    # Stan sources and compiled models
const MODELS = joinpath(dirname(dirname(@__DIR__)), "src", "models")
reference_file(name) = joinpath(dirname(@__DIR__), "reference", name * ".json")

# Stan's unconstrained log density, as AdvancedHMC wants it. Stan throws where
# it rejects a point, and the sampler needs a density of zero there.
struct StanDensity
    sm::StanModel
end
LogDensityProblems.dimension(p::StanDensity) = Int(param_unc_num(p.sm))
LogDensityProblems.capabilities(::Type{StanDensity}) = LogDensityProblems.LogDensityOrder{1}()
LogDensityProblems.logdensity(p::StanDensity, u) = first(LogDensityProblems.logdensity_and_gradient(p, u))
LogDensityProblems.logdensity_and_gradient(p::StanDensity, u) =
    try
        log_density_gradient(p.sm, u)
    catch
        (-Inf, zero(u))
    end

"""
    posterior_points(sm, rng, start, n)

`n` unconstrained points from a short NUTS run on Stan's density. The run only
has to reach the region where the posterior has
its mass. At a random initial value a large unscaled dataset gives a log
density near 1e11, and at that size rounding hides an error of order 1 in a
prior.
"""
function posterior_points(sm, rng, start, n; warmup = 300, thin = 20)
    draws = AbstractMCMC.sample(rng, AbstractMCMC.LogDensityModel(StanDensity(sm)),
                                AdvancedHMC.NUTS(0.8), warmup + n * thin;
                                n_adapts = warmup, initial_params = start,
                                progress = false, verbose = false)
    return [draws[warmup + i * thin].z.θ for i in 1:n]
end

"""
    stan_reference(name; n = 10, seed = 1)

Compute and save the reference evaluations for posterior `name`. Half the
points come from `posterior_points`; the rest are Stan's own initial values
(uniform on (-2, 2) in the unconstrained space), far from the posterior. All
are saved in the constrained space, and an initial value that Stan rejects is
drawn again.
"""
function stan_reference(name; n = 10, seed = 1)
    pdb = PosteriorDB.database()
    post = PosteriorDB.posterior(pdb, name)
    model = PosteriorDB.model(post)
    code = PosteriorDB.load(PosteriorDB.implementation(model, "stan"))
    data = PosteriorDB.load(PosteriorDB.dataset(post), String)

    # One Stan file per model, so posteriors that share a model compile once.
    # It is left alone when it is already right, since BridgeStan recompiles a newer file.
    mkpath(BUILD)
    stanfile = joinpath(BUILD, "m_" * PosteriorDB.name(model) * ".stan")
    (isfile(stanfile) && read(stanfile, String) == code) || write(stanfile, code)
    sm = StanModel(stanfile, data; warn = false)

    rng = Xoshiro(seed)
    init() = 4 .* rand(rng, Int(param_unc_num(sm))) .- 2
    candidates = posterior_points(sm, rng, init(), n ÷ 2)
    points, lp = Vector{Float64}[], Float64[]
    while length(lp) < n
        u = isempty(candidates) ? init() : popfirst!(candidates)
        l = try
            log_density(sm, u; propto = false, jacobian = false)
        catch      # Stan rejects the point
            continue
        end
        push!(points, param_constrain(sm, u))
        push!(lp, l)
    end

    ref = Dict("posterior" => name, "model" => PosteriorDB.name(model),
               "names" => param_names(sm), "points" => points, "lp" => lp)
    write(reference_file(name), JSON.json(ref))
end

"Every posteriordb posterior whose model has a folder in src/models."
function model_posteriors()
    pdb = PosteriorDB.database()
    return [n for n in PosteriorDB.posterior_names(pdb)
            if isdir(joinpath(MODELS, PosteriorDB.name(PosteriorDB.model(PosteriorDB.posterior(pdb, n)))))]
end

for name in (isempty(ARGS) ? filter(!isfile ∘ reference_file, model_posteriors()) : ARGS)
    stan_reference(name)
    println("wrote ", name)
end
