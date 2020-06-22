function run_simulation!(sim::SimData, mapa::OpenStreetMapX.OSMData,speeds = OpenStreetMapX.SPEED_ROADS_URBAN)
    m, n = size(sim.map_data.w)
    stats = Stats(m, n)
    stats.vehicle_load = SparseArrays.spzeros(m, n) #1. SparseArray vehicle_load z obciazeniami samochodow na lukach
	stats.actual_driving_times=deepcopy(sim.driving_times) #3. creating deepcopy
    stats.simulation_total_time = 0.0 #summing total time of all agents in the simulation
	for agent in sim.population
	    agent.route = get_route(sim.map_data, stats.actual_driving_times, agent.start_node,agent.fin_node)  #4 Agent jedzie najszybsza trasa korzystajac z actual_driving_times
		for i in 1:length(agent.route)
		    update_stats!(stats, agent.route[i][1], agent.route[i][2]) #5 i 6 aktualizacja vehicle_load oraz stats.actual_driving_times za pomocą funkcji update_stats!
		 end
	end #7. looping
    cars_per_edge = stats.vehicle_load
    mData = deepcopy(sim.map_data)
    plot_edge_load(mapa,mData,cars_per_edge)
end
