# Write each model's Project.toml and Manifest.toml from the shared environment
# in src/models, so that every model pins the same package versions and installs
# only the packages its own file loads.
#
#   julia scripts/sync_environments.jl
#
# Run it after changing a model's `using` lines, after adding a model, or after
# updating src/models/Manifest.toml. The tests fail when a model is out of sync.
#
# A model's Manifest.toml is the shared manifest cut down to the model's
# packages: Pkg.resolve() keeps the versions a manifest already holds and drops
# the packages the project does not need.

using Pkg
include(joinpath(dirname(@__DIR__), "test", "environments.jl"))

const MODELS = joinpath(dirname(@__DIR__), "src", "models")

function main()
    deps = TOML.parsefile(joinpath(MODELS, "Project.toml"))["deps"]
    manifest = read(joinpath(MODELS, "Manifest.toml"), String)
    models = filter(d -> isdir(joinpath(MODELS, d)), readdir(MODELS))
    loads = Dict(m => imports(joinpath(MODELS, m, m * ".jl")) for m in models)
    for m in models, name in loads[m]
        haskey(deps, name) ||
            error("$m loads $name, which src/models/Project.toml lacks. Add it to that environment first.")
    end
    # Models that load the same packages get the same two files, so resolve once per set.
    for names in sort!(unique(values(loads)))
        pruned = mktempdir() do dir
            write(joinpath(dir, "Project.toml"), project_toml(names, deps))
            write(joinpath(dir, "Manifest.toml"), manifest)
            Pkg.activate(dir; io = devnull)
            Pkg.resolve(; io = devnull)
            read(joinpath(dir, "Manifest.toml"), String)
        end
        same = [m for m in models if loads[m] == names]
        for m in same
            write(joinpath(MODELS, m, "Project.toml"), project_toml(names, deps))
            write(joinpath(MODELS, m, "Manifest.toml"), pruned)
        end
        println(lpad(length(same), 3), " models: ", join(names, ", "))
    end
end

main()
