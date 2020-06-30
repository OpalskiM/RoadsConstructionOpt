using OpenStreetMapX
using LightGraphs
using Parameters

using Pkg
pkg"activate ."

using RoadsConstructionOpt


const p = ModelSettings(N=1000)

pth = joinpath(dirname(pathof(OpenStreetMapX)),"..","test","data")###exemplary map
name = "reno_east3.osm"

map_data =  OpenStreetMapX.get_map_data(pth,name,use_cache = false);
sim = get_sim(map_data,p)

stats = run_simulation!(sim)

RoadsConstructionOpt.plot_edge_load(map_data,stats)

#1)
#Plot with removed roads
#include("Removed_edges.jl")
#RoadConstructionOpt.plot_edge_load_removed(map_data,stats,roads) #Removed roads colored green

#2)
# Optimisation Roadworks
include("Roadworks.jl")
"""
function get_solution(sim::SimData, roads::Array{Any,1},reference_time::Float64,no_of_partitions::Int)
**Arguments**
*'sim' - Sim Data
*'roads' - Roads to renovate
*'reference_time' - benchmark time (total time of simulation without roadworks)
*'no_of_partitions' - number of roadworks batches (time of each roadwork set to 1)
"""
get_solution(sim,roads,reference_time,5)
