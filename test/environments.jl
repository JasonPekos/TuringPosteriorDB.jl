# What it means for a model's environment to be in sync with the shared one in
# src/models. Used by runtests.jl, which checks it, and by
# scripts/sync_environments.jl, which writes the files.

using TOML

"Names of the packages a model file loads on its `using` and `import` lines, sorted."
function imports(file)
    names = String[]
    for line in eachline(file)
        m = match(r"^\s*(?:using|import)\s+([^#]*)", line)
        m === nothing && continue
        for part in split(first(split(m[1], ':')), ',')
            push!(names, first(split(strip(part), '.')))
        end
    end
    return sort!(unique!(filter!(!isempty, names)))
end

"The Project.toml of a model that loads `names`, with UUIDs from the shared project's `deps`."
project_toml(names, deps) = "[deps]\n" * join(("$n = \"$(deps[n])\"\n" for n in names))

"`names` and every package they depend on, following the shared manifest."
function closure(names, manifest)
    seen, todo = Set{String}(), collect(String, names)
    while !isempty(todo)
        name = pop!(todo)
        name in seen && continue
        push!(seen, name)
        deps = get(only(manifest["deps"][name]), "deps", String[])
        append!(todo, deps isa AbstractDict ? keys(deps) : deps)
    end
    return seen
end

pin(entry) = Tuple(get(only(entry), k, nothing) for k in ("uuid", "version", "git-tree-sha1"))

"""
Ways in which the environment in `dir` is out of sync, as sentences; empty when
it is in sync. A model's Project.toml lists exactly the packages its file
loads, and its Manifest.toml holds those packages and their dependencies at the
versions the shared manifest pins.
"""
function environment_problems(dir, shared_project, shared_manifest)
    model = basename(dir)
    names = imports(joinpath(dir, model * ".jl"))
    unknown = setdiff(names, keys(shared_project["deps"]))
    isempty(unknown) || return ["$model loads $(join(unknown, ", ")), which src/models/Project.toml lacks"]
    project, manifest = joinpath(dir, "Project.toml"), joinpath(dir, "Manifest.toml")
    isfile(project) && isfile(manifest) || return ["$model has no Project.toml or no Manifest.toml"]
    problems = String[]
    read(project, String) == project_toml(names, shared_project["deps"]) ||
        push!(problems, "$model: Project.toml does not list exactly $(join(names, ", "))")
    own = TOML.parsefile(manifest)
    get(own, "julia_version", nothing) == shared_manifest["julia_version"] ||
        push!(problems, "$model: Manifest.toml is for another Julia version")
    Set(keys(own["deps"])) == closure(names, shared_manifest) ||
        push!(problems, "$model: Manifest.toml does not hold exactly its packages' dependencies")
    stale = [n for (n, e) in own["deps"] if !haskey(shared_manifest["deps"], n) || pin(e) != pin(shared_manifest["deps"][n])]
    isempty(stale) || push!(problems, "$model: Manifest.toml pins $(join(sort(stale), ", ")) differently from src/models/Manifest.toml")
    return problems
end
