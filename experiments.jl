using OpenStreetMapX
using LightGraphs
using Parameters

using Pkg
pkg"activate ."

using RoadsConstructionOpt


const p = ModelSettings(N=1000)

pth = joinpath(dirname(pathof(OpenStreetMapX)),"..","test","data","reno_east3.osm")

map_data =  get_map_data(pth;use_cache = false, trim_to_connected_graph=true );
sim = get_sim(map_data,p)

stats = run_simulation!(sim)

plot_edge_load(map_data,stats)

roads = top_congested_roads(sim,stats.vehicle_load)

plot_edge_load_removed(map_data, stats, roads) #Removed roads colored green

reference_time=stats.simulation_total_time
#get_solution(sim,roads,reference_time,5)

@time opt(f, 5, 30, 50, 0.001)
