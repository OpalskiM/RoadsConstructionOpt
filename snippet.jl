using Random,OpenStreetMapX,OpenStreetMapXDES

mapfile = "reno_east3.osm";  # This file can be found in test/data folder
datapath = raw"C:\Users\p\Desktop\OpenStreetMapXDES\test\data";
path = raw"C:\Users\p\Desktop\CAD\RoadsConstructionOpt\src";
include(joinpath(path,"RoadsConstructionOpt.jl"))

Random.seed!(234);

#Sim Params:
l=5.0 # vehicle length
N=1000 #Number of agents
λ = 0.4 #learning rate

#Optimization Params:
Z=50 #Number of roads in one solution (Evolutionary algorithm)
n = 50 #Number of solutions (Evolutionary algorithm)
roadwork_time = 5 #approximate length of roadwork of single segment  
partitions = 4 #number of steps in roadwork process
crossover_rate=0.7 #Crossover Rate (Evolutionary algorithm)
mutation_rate=0.05 #Mutation Rate (Evolutionary algorithm)
elitism_rate = 0.2 #elitism Rate (Evolutionary algorithm)

map_data =OpenStreetMapX.get_map_data(datapath, mapfile,use_cache=false, road_levels = Set(1:4));
sim_data = OpenStreetMapXDES.get_sim_data(map_data,N,l);

segments =  shuffle(map_data.e)[1:Z] #randomly selected roads

best_scenario, worst_scenario = RoadsConstructionOpt.optimize!(sim_data, λ, segments, n,
                                                            roadwork_time, partitions, 
                                                            crossover_rate, mutation_rate, elitism_rate);
  
 