using OpenStreetMapX
using LightGraphs
using SparseArrays
using DataStructures
using Distributions
using Statistics
using Test
using Random
using Base.Iterators
using StatsBase
using Parameters

include("types.jl")
include("simulation_functions.jl")
include("simulator.jl")
include("parameters.jl")

const p = ModelSettings(10000,20,5.0)

pth = joinpath(dirname(pathof(OpenStreetMapX)),"..","test","data")###exemplary map
name = "reno_east3.osm"

map_data =  OpenStreetMapX.get_map_data(pth,name,use_cache = false);
sim_data = get_sim_data(map_data,N,l)

#get reference scenario, with no roadworks
reference_times = run_sim!(deepcopy(sim_data), iter)

m=deepcopy(map_data) #creating a copy of map_data
s=deepcopy(sim_data) #creating a copy of sim_data
include("Removing_edges.jl")

#creating solution for scenario with roadworks
@time Solution = run_sim!(s,iter)
