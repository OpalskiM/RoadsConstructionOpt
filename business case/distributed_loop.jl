using OpenStreetMapX
using Graphs
using Parameters
using Distributed
using Pkg
pkg"activate ."

using RoadsConstructionOpt

if startswith(gethostname() , "ip")
    @info "Adding 24 procs"
    #chmura
    addprocs(24)
else
    #komputer lokalny
    addprocs(6)
end

@everywhere using Random, DataFrames, StatsBase, Dates, CSV
@everywhere include("experiment.jl")
@everywhere include("loops.jl")

runtime = Dates.format(now(), "yyyymmdd_HHMMSS")
#parametr1 = liczba okresów remontów
#parametr2 = łączna liczba dróg remontowanych
datf = @distributed (append!) for (parametr1,parametr2, seed) in vec(collect(Iterators.product(1:5,30,1:30)))
roads= top_congested_roads(sim,stats.vehicle_load,parametr2)
densities=Array{Float64}(undef, length(roads),length(roads))
densities= distances(map_data,roads)
    outfile = "Prod_$(runtime)_$(parametr1)_$(parametr2)_$(seed).txt"
    loop=loops(parametr1,densities, roads, sim, reference_time)
    time = @elapsed df = DataFrame(seed=seed,Result=loop[1],Density=loop[2], no_of_roads=parametr2, no_of_batches=parametr1)
    df[:, :time] .= time # zbieramy czas obliczen
    CSV.write(outfile,df,delim="\t")
    df
end

CSV.write("MyProd_$(runtime).txt",datf,delim="\t")
