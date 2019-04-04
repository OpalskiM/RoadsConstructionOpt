using Documenter

try
    using RoadsConstructionOpt
catch
    if !("../src/" in LOAD_PATH)
       push!(LOAD_PATH,"../src/")
       @info "Added \"../src/\"to the path: $LOAD_PATH "
       using RoadsConstructionOpt
    end
end

makedocs(
    sitename = "RoadsConstructionOpt",
    format = format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true"
    ),
    modules = [RoadsConstructionOpt],
    pages = ["index.md", "reference.md"],
    doctest = true
)



deploydocs(
    repo ="github.com/OpalskiM/RoadsConstructionOpt.jl.git",
    target="build"
)
