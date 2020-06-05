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
using Memoize
using StatsBase

#Parameters
N = 1000; #Number of agents
iter = 10; #Number of iterations
λ_ind = 0.4; #learning rate
l = 5.0; #vehicle' length


#exemplary path, generating environment
pth = "C:/Users/opals/Documents/AKTUALNE"
name = "skierniewice.osm"
map_data =  OpenStreetMapX.get_map_data(pth,name,use_cache = false);
sim_data = get_sim_data(map_data,N,l)


 #Running once to count roads_visits
 run_once_init!(sim_data,map_data.g,λ_ind) 

#Choosing roads to remove from the graph
n=10 #Number of chosen roads
 prob = Dict{Tuple{Int,Int},Real}()
 for k=keys(roads_visits)
     prob[k]=values(roads_visits[k])/sum(values(roads_visits))
 end
 weights = collect(values(prob)) #probabilities
 roads = collect(keys(prob)) #roads in the map
 dict = Dict(roads[i]=>i for i=1:length(roads))
 value=collect(values(dict))
 samp=StatsBase.direct_sample!(value,weights)[1:n] #Example - choosing number of 10 roads
 roads[samp] #Sample roads to remove from the graph
 #Changing dictionaries
 routes=Vector{Tuple{Int,Int}}()
 for i in 1:length(samp)
 push!(routes,(map_data.n[roads[samp][i][1]],map_data.n[roads[samp][i][2]]))
 end
 routes # a list of edges to remove from the graph

#getting solution
roadwork_time = 10  # approximate length of roadwork of single segment
no_of_partitions = 5   #number of steps in roadwork process
    #get reference scenario:
    reference_times = run_sim!(deepcopy(sim_data), λ_ind, runtime)
    #generate solution:
    get_solution(deepcopy(sim_data),shuffle(routes), reference_times, λ_ind, roadwork_time, no_of_partitions)
