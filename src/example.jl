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
include("parameters.jl")

const p = ModelSettings(10000,5.0)
#N = 10000, l = 5.0

pth = joinpath(dirname(pathof(OpenStreetMapX)),"..","test","data")###exemplary map
name = "reno_east3.osm"

map_data =  OpenStreetMapX.get_map_data(pth,name,use_cache = false);
sim_data = get_sim_data(map_data,N,l)

include("simulator.jl")
run_simulation!(sim_data)
