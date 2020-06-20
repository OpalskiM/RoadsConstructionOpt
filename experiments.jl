using OpenStreetMapX
using LightGraphs
using Parameters

using Pkg
pkg"activate ."

# using Rivise  # TODO : you can consider using this line to automatically relaoding the module when programmin g it
using RoadsConstructionOpt


const p = ModelSettings(N=10000)


pth = joinpath(dirname(pathof(OpenStreetMapX)),"..","test","data")###exemplary map
name = "reno_east3.osm"

map_data =  OpenStreetMapX.get_map_data(pth,name,use_cache = false);
sim = get_sim(map_data,p)

run_simulation!(sim)


# TODO : edit this code here for vizualisation to properly work with simulation

cars_per_edge = stats.vehicle_load
map_file_path = joinpath(dirname(pathof(OpenStreetMapX)),"..","test/data/reno_east3.osm")
mapa=OpenStreetMapX.parseOSM(map_file_path) #creating OSM file
mData = deepcopy(map_data)

plot_edge_load(mapa,mData,cars_per_edge)
