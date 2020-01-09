using Pkg


#Pkg.add(PackageSpec(url="https://github.com/pszufe/OpenStreetMapXDES.jl", rev="master"))

import OpenStreetMapXDES
using OpenStreetMapX
using Random

Pkg.activate(".");

using RoadsConstructionOpt

#map_file_path = joinpath(dirname(pathof(OpenStreetMapX)),"..","test/data/reno_east3.osm")
#
map_file_path = joinpath(".","winnipeg_downtownf.osm")
#Example
N = 100; #Number of agents
l = 5.0; # Vehicle length
map_data = OpenStreetMapX.get_map_data(map_file_path);
sim_data = OpenStreetMapXDES.get_sim_data(map_data, N, l);


λ_ind = 0.4 #Learning rate
Random.seed!(0);
routes = shuffle(map_data.e)[1:50];    #Routes to renovate
no_solutions = 10    #Number of solutions in evolutionary algorithm
roadwork_time = 10  # approximate length of roadwork of single segment
no_of_partitions = 5   #number of steps in roadwork process
crossover_rate = 0.8
mutation_rate = 0.2
elitism = 0.1

const alg_methods = [optimize!, optimize2!]

# in order for the multithreading to work set system vatiable
#set JULIA_NUM_THREADS=2
res = Vector{NamedTuple}(undef, length(alg_methods))
Threads.@threads for m in 1:length(alg_methods)
    sim_data_copy = deepcopy(sim_data)
    Random.seed!(m);
    res[m] = alg_methods[m](
        sim_data_copy,
        λ_ind,
        routes,
        no_solutions,
        roadwork_time,
        no_of_partitions,
        crossover_rate,
        mutation_rate,
        elitism;
        maxiter = 50
    )
end
