using OpenStreetMapX
using OpenStreetMapXDES
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
include("symulacja_potrzebna.jl")
include("parameters.jl")

@unpack N,iter,l,roadwork_time,no_of_partitions,n = ModelSettings(1000,20,5.0,1,5,10)

pth = "C:/Users/opals/Documents/AKTUALNE" ###exemplary map
name = "skierniewice.osm"

map_data =  OpenStreetMapX.get_map_data(pth,name,use_cache = false);
sim_data = get_sim_data(map_data,N,l)
routes = renovated_roads(map_data,n) ##Randomly chosen n roads to renovate

#get reference scenario:
reference_times = run_sim!(deepcopy(sim_data), iter)
#generate solution - compare graph with removed edges with reference scenario
get_solution(deepcopy(sim_data),routes, reference_times, roadwork_time, no_of_partitions)

