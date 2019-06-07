module RoadsConstructionOpt

using OpenStreetMapX, OpenStreetMapXDES
using LightGraphs
using Plots
using SparseArrays
using DataStructures
using Distributions
using Statistics
using Test
using Random
using Base.Iterators

include("simulator.jl")
include("evolutionary_algorithm.jl")
include("evolutionary_functions.jl")

export optimize!

end # module
