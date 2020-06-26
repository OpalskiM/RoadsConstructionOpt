using OpenStreetMapX
using LightGraphs
using Parameters

using Pkg
pkg"activate ."

using RoadsConstructionOpt


const p = ModelSettings(N=1000)

pth = joinpath(dirname(pathof(OpenStreetMapX)),"..","test","data")###exemplary map
name = "reno_east3.osm"

map_data =  OpenStreetMapX.get_map_data(pth,name,use_cache = false);
sim = get_sim(map_data,p)

stats = run_simulation!(sim)

RoadsConstructionOpt.plot_edge_load(map_data,stats)
