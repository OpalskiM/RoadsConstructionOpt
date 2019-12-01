module RoadsConstructionOpt

using OpenStreetMapX
import OpenStreetMapXDES 
using LightGraphs
using SparseArrays
using DataStructures
using Distributions
using Statistics
using Test
using Random
using Base.Iterators

include("simulator.jl")
include("evolutionary_algorithm.jl")
include("evolutionary_algorithm2.jl")
include("evolutionary_functions.jl")

export optimize!
export run_sim!
export get_solution

end # module
