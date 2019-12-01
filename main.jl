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
N = 100;
l = 5.0;
map_data = OpenStreetMapX.get_map_data(map_file_path);
sim_data = OpenStreetMapXDES.get_sim_data(map_data, N, l);


λ_ind = 0.4
#λ_soc = 1.0
routes = map_data.e;
no_solutions = 10
roadwork_time = 10
no_of_partitions = 5
crossover_rate = 0.8
mutation_rate = 0.2
elitism = 0.1


res = NamedTuple[]

for mymethod in [optimize!, optimize2!]
    sim_data_copy = deepcopy(sim_data)
    Random.seed!(0);
    push!(res, mymethod(
        sim_data_copy,
        λ_ind,
        routes,
        no_solutions,
        roadwork_time,
        no_of_partitions,
        crossover_rate,
        mutation_rate,
        elitism;
        maxiter = 30
    ))
end
