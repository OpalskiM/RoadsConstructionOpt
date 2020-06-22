using OpenStreetMapX
using LightGraphs
using Parameters

using Pkg
pkg"activate ."

using RoadsConstructionOpt


const p = ModelSettings(N=10000)

pth = joinpath(dirname(pathof(OpenStreetMapX)),"..","test","data")###exemplary map
name = "reno_east3.osm"

map_data =  OpenStreetMapX.get_map_data(pth,name,use_cache = false);
sim = get_sim(map_data,p)

map_file_path = joinpath(dirname(pathof(OpenStreetMapX)),"..","test/data/reno_east3.osm")
mapa=OpenStreetMapX.parseOSM(map_file_path) #creating OSM file

run_simulation!(sim,mapa)
