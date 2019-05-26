#bierzemy jakies sol
#i powtorka z evolutionary, tylko bez algo ewo.

module simulator_RemovedEdges

using OpenStreetMapX
using LightGraphs
using Plots
using SparseArrays
using DataStructures
using Distributions
using Statistics
using Test
using Random

export get_route
export get_max_densities
export get_nodes
export create_agents
export get_velocities
export get_sim_data
export update_beliefs!
export calculate_driving_time
export departure_time
export update_stats!
export update_routes!
export update_time
export run_single_iteration!
export run_simulation!
export remove_edges, new_graph_routing
export roulette

iter=5 #Number of iterations (simulator)
l=5.0 # vehicle length
N=1000 #Number of agents
Z=5 #Number of roads in one solution (Evolutionary algorithm)
n = 1 

include("simulator.jl")
include("Evolutionary_functions.jl")
include("Auxiliary_functions.jl")
include("sim_RemovingEdges.jl")