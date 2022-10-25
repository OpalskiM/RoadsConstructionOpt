const p1 = ModelSettings(N=500)

pth = joinpath(dirname(pathof(OpenStreetMapX)),"newyork.osm")
map_data =  get_map_data(pth;use_cache = false, trim_to_connected_graph=true );
sim = get_sim(map_data, p1)

@time stats = run_simulation(sim)

roads = top_congested_roads(sim,stats.vehicle_load,20)

reference_time=stats.simulation_total_time

roads = top_congested_roads(sim,stats.vehicle_load,30)
densities=Array{Float64}(undef, length(roads),length(roads))
distances(map_data,roads)
