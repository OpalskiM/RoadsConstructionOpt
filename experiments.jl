using OpenStreetMapX
using Graphs
using Parameters

using Pkg
pkg"activate ."

using RoadsConstructionOpt


const p = ModelSettings(N=1000)

pth = "winnipeg_downtownf.osm"
#pth = joinpath(dirname(pathof(OpenStreetMapX)),"..","test","data","reno_east3.osm")

map_data =  get_map_data(pth;use_cache = false, trim_to_connected_graph=true );
sim = get_sim(map_data, p)
sim2=deepcopy(sim) # creating a copy of sim_data for testing random solutions

@time stats = run_simulation(sim)

roads = top_congested_roads(sim,stats.vehicle_load,20)

reference_time=stats.simulation_total_time

ooo = @time opt(f, 2, 100, 0.001,roads, sim, reference_time) #Optimal solution

#Creating n random solutions and comparing relative performance with optimal solution
T=2 #number of roadworks batches
random_solutions=rand_sol(10,ooo) # Creating 10 random solutions and assesing performance. Result = Random/optimal

#Visualisation
plot_edge_load(map_data,stats)
plot_edge_load_removed(map_data, stats, roads) #Removed roads colored green

colors = ["yellow", "magenta"] #colours chosen to distinguish 1st and 2nd batch of roadworks.
plot_optimal_plan(map_data, stats, roads,ooo) #Plotting optimal plan of roadworks

sol = rand(1:T, length(roads)) #Creating a random permutation as a random feasible solution
plot_random_plan(map_data, stats, roads) #Plotting a random solution using colors as above

