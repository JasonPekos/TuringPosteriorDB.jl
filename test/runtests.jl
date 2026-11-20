# The log-density check. A Turing model passes when its log joint differs from
# Stan's by the same constant at every reference point in test/reference/.
#
#   julia --project=test test/runtests.jl                  # every posterior
#   julia --project=test test/runtests.jl eight_schools-eight_schools_centered ...
#
# This file reads posteriordb's data and Stan's reference values, hands them to
# worker processes (worker.jl, the only code that loads Turing), and compares
# each posterior's status with what known_failures.toml expects. Each model is
# evaluated in the environment its own folder pins, one worker per distinct
# environment.

using JSON, PosteriorDB, Serialization, TOML, Test
include("environments.jl")

const MODELS = joinpath(dirname(@__DIR__), "src", "models")
const REFERENCE = joinpath(@__DIR__, "reference")

"A model's environment as text. Models whose folders hold the same two files share a worker."
fingerprint(model) = read.(joinpath.(MODELS, model, ("Project.toml", "Manifest.toml")), String)

# ── Stan's JSON → Julia values ──────────────────────────────────────────────

"posteriordb data: nested JSON lists become arrays, a list of rows a matrix."
tidy(x) = x
function tidy(x::AbstractVector)
    first(x) isa AbstractVector && return stack(tidy.(x); dims = 1)
    return all(v -> v isa Integer, x) ? Int.(x) : Float64.(x)
end

"Stan's flat names and values (\"theta.1\", \"L.2.1\") → Dict of scalars and arrays."
function unflatten(names, x)
    cells = Dict{Symbol,Vector{Pair{Vector{Int},Float64}}}()
    for (name, v) in zip(names, x)
        parts = split(name, '.')
        push!(get!(cells, Symbol(parts[1]), []), parse.(Int, parts[2:end]) => v)
    end
    return Dict{Symbol,Any}(k => unflatten(c) for (k, c) in cells)
end
function unflatten(cells::Vector{Pair{Vector{Int},Float64}})
    isempty(first(cells).first) && return first(cells).second
    dims = Tuple(maximum(c.first[j] for c in cells) for j in eachindex(first(cells).first))
    a = zeros(dims)
    for (idx, v) in cells
        a[idx...] = v
    end
    return a
end

# ── Jobs and workers ────────────────────────────────────────────────────────

"Model folders: every directory under src/models."
model_names() = filter(d -> isdir(joinpath(MODELS, d)), readdir(MODELS))

"Every posteriordb posterior whose model has a folder here, with that model's name."
function posteriors(pdb)
    have = Set(model_names())
    out = Pair{String,String}[]
    for name in PosteriorDB.posterior_names(pdb)
        model = PosteriorDB.name(PosteriorDB.model(PosteriorDB.posterior(pdb, name)))
        model in have && push!(out, name => model)
    end
    return out
end

"What the worker needs for one posterior. Plain values only: the worker has no JSON package."
function job(pdb, name, model)
    ref = JSON.parsefile(joinpath(REFERENCE, name * ".json"))
    raw = PosteriorDB.load(PosteriorDB.dataset(PosteriorDB.posterior(pdb, name)))
    return (; name, model, file = joinpath(MODELS, model, model * ".jl"),
            data = Dict{String,Any}(String(k) => tidy(v) for (k, v) in raw),
            points = [unflatten(ref["names"], Float64.(x)) for x in ref["points"]],
            lp = Float64.(ref["lp"]))
end

"""
Run `jobs` in a fresh Julia process whose project is `env`, and return its rows
by posterior name. The process sees that environment and the standard library
only, so a model cannot pick up a package from the caller's environment.
"""
function run_worker(env, jobs)
    mktempdir() do dir
        input, output = joinpath(dir, "jobs.jls"), joinpath(dir, "results.jls")
        serialize(input, jobs)
        julia = joinpath(Sys.BINDIR, Base.julia_exename())
        cmd = `$julia --startup-file=no --project=$env $(joinpath(@__DIR__, "worker.jl")) $input $output`
        run(addenv(cmd, "JULIA_LOAD_PATH" => "@" * (Sys.iswindows() ? ";" : ":") * "@stdlib"))
        return Dict(row.name => row for row in deserialize(output))
    end
end

"Expected status of each posterior that is known not to pass, from known_failures.toml."
known_failures() = Dict(name => status
                        for (status, entries) in TOML.parsefile(joinpath(@__DIR__, "known_failures.toml"))
                        for name in keys(entries))

# ── The tests ───────────────────────────────────────────────────────────────

function main(only)
    pdb = PosteriorDB.database()
    all_posteriors = posteriors(pdb)
    todo = isempty(only) ? all_posteriors : filter(p -> first(p) in only, all_posteriors)
    unknown = setdiff(only, first.(all_posteriors))
    isempty(unknown) || error("no model folder for the posteriors: ", join(unknown, ", "))
    expected = known_failures()

    @testset "TuringPosteriorDB" begin
        @testset "every model folder is a posteriordb model" begin
            @test setdiff(model_names(), last.(all_posteriors)) == String[]
        end
        @testset "known_failures.toml names posteriors that exist" begin
            @test isempty(setdiff(keys(expected), first.(all_posteriors)))
        end
        @testset "every model's environment is in sync with src/models" begin
            shared_project = TOML.parsefile(joinpath(MODELS, "Project.toml"))
            shared_manifest = TOML.parsefile(joinpath(MODELS, "Manifest.toml"))
            problems = reduce(vcat, [environment_problems(joinpath(MODELS, m), shared_project, shared_manifest)
                                     for m in model_names()]; init = String[])
            foreach(println, problems)
            isempty(problems) || println("Run `julia scripts/sync_environments.jl` to rewrite them.")
            @test problems == String[]
        end

        fp = Dict(model => fingerprint(model) for model in unique(last.(todo)))
        rows = Dict{String,Any}()
        for f in unique(fp[model] for (_, model) in todo)
            group = [(name, model) for (name, model) in todo if fp[model] == f]
            model = last(first(group))
            println("\n", length(group), " posteriors in the environment of ", model, ": ",
                    join(imports(joinpath(MODELS, model, model * ".jl")), ", "))
            merge!(rows, run_worker(joinpath(MODELS, model), [job(pdb, p...) for p in group]))
        end

        # One line per posterior whose status is not the expected one, then one test over all of them.
        unexpected = [(name, get(expected, name, "pass"), rows[name]) for (name, _) in todo
                      if rows[name].status != get(expected, name, "pass")]
        isempty(unexpected) || println("\nNot as known_failures.toml expects:")
        for (name, want, row) in unexpected
            println("  ", rpad(name, 52), " expected ", rpad(want, 6), " got ", rpad(row.status, 6), " ", row.note)
        end
        @testset "log density against Stan" begin
            @test first.(unexpected) == String[]
        end
        statuses = [row.status for row in values(rows)]
        println("\n", join(("$s: $(count(==(s), statuses))" for s in sort(unique(statuses))), ", "))
    end
end

main(ARGS)
