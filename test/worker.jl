# Turing side of the log-density check, started by runtests.jl:
#
#   julia --project=<environment> worker.jl jobs.jls results.jls
#
# It runs inside the models' environment, so it may load that environment's
# packages and the standard library and nothing else. Each job is one
# posterior: the model's file, the data, Stan's reference points and Stan's log
# density at them. Each result is one row of the table runtests.jl prints.

using Pkg
Pkg.instantiate()
using Turing, LinearAlgebra, Printf, Serialization, Statistics
const DynamicPPL = Turing.DynamicPPL

# The difference from Stan counts as constant when, at every point, it is
# within RTOL times the size of that point's log density of the median difference.
const RTOL = 1e-9

"A failure at a named stage, so the table says where each model stopped."
struct Stage <: Exception
    stage::String
    msg::String
end

"Run `f`, turning any error it throws into a failure at stage `name`."
stage(f, name) =
    try
        f()
    catch e
        e isa Stage && rethrow()
        throw(Stage(name, first(split(sprint(showerror, e), '\n'))))
    end

"Call the model function `f` on the entries of `data` that its arguments are named after."
function build(f, data)
    # @model defines a second method with a `__model__` argument; skip it.
    meth = first(m for m in methods(f) if :__model__ ∉ Base.method_argnames(m))
    args = Base.method_argnames(meth)[2:end]
    absent = [a for a in args if !haskey(data, string(a))]
    isempty(absent) || throw(Stage("data", "model takes $(join(absent, ", ")), not in the Stan data"))
    return f((data[string(a)] for a in args)...)
end

"""
Shape Stan's value `v` like `t`, a prior draw of the same variable from the
Turing model. Stan reports a Cholesky factor as its lower-triangular matrix.
"""
conform(v, t) = throw(Stage("shape", "Stan has $(summary(v)), Turing has $(summary(t))"))
conform(v::Real, t::AbstractFloat) = v
conform(v::AbstractMatrix, t::Cholesky) = Cholesky(LowerTriangular(v))
conform(v::AbstractArray, t::AbstractArray{<:AbstractFloat}) =
    size(v) == size(t) ? v :
    throw(Stage("shape", "Stan has size $(size(v)), Turing has size $(size(t))"))

"Turing's log joint at one constrained point, given as a Dict of Stan's values."
function turing_lp(model, values::Dict{Symbol,Any})
    draw = rand(model)
    # Group the draw by top-level symbol: `x[1] ~ …` in a loop shows as x[1], x[2], …
    syms = unique(DynamicPPL.getsym.(keys(draw)))
    ours, theirs = setdiff(syms, keys(values)), setdiff(keys(values), syms)
    if !isempty(ours) || !isempty(theirs)
        throw(Stage("names", "only in Turing: [$(join(ours, ", "))]; only in Stan: [$(join(theirs, ", "))]"))
    end
    point = map(syms) do s
        vn = DynamicPPL.VarName{s}()
        s => (haskey(draw, vn) ? conform(values[s], draw[vn]) : values[s])
    end
    return logjoint(model, NamedTuple(point))
end

"The table row for one posterior whose model file has been included into `mod`."
function compare(mod, job)
    model = stage(() -> build(getglobal(mod, Symbol(job.model)), job.data), "load")
    lp = stage(() -> [turing_lp(model, point) for point in job.points], "eval")
    diff = lp .- job.lp
    all(isfinite, diff) || throw(Stage("eval", "Turing log joint not finite where Stan's is"))
    offset = median(diff)
    # Worst deviation from the constant, relative to the size of the log density there.
    spread = maximum(abs.(diff .- offset) ./ max.(1, abs.(job.lp)))
    return (; job.name, status = spread <= RTOL ? "pass" : "differ", offset, spread, note = "")
end

function check(job)
    mod = Module(Symbol(:Model_, job.model))
    stage(() -> Base.include(mod, job.file), "load")
    # The file's definitions are newer than the code that is running, so they
    # are only visible through invokelatest.
    return Base.invokelatest(compare, mod, job)
end

function main(input, output)
    rows = map(deserialize(input)) do job
        row = try
            check(job)
        catch e
            e isa Stage || rethrow()
            (; job.name, status = e.stage, offset = NaN, spread = NaN, note = e.msg)
        end
        @printf("%-6s %-52s %12s %10s  %s\n", row.status, row.name,
                isnan(row.offset) ? "" : @sprintf("%.6g", row.offset),
                isnan(row.spread) ? "" : @sprintf("%.2g", row.spread), first(row.note, 110))
        row
    end
    serialize(output, rows)
end

main(ARGS...)
