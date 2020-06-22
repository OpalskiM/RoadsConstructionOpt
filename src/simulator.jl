function run_simulation!(sim::SimData, mapa::OpenStreetMapX.OSMData,speeds = OpenStreetMapX.SPEED_ROADS_URBAN) #OSM object used only for visualisation
    m, n = size(sim.map_data.w)
    stats = Stats(m, n)
    stats.vehicle_load = SparseArrays.spzeros(m, n) #number of agents on edges
	stats.actual_driving_times=deepcopy(sim.driving_times) #driving times with 0 traffic
    stats.simulation_total_time = 0.0 #summing total time of all agents in the simulation
	for agent in sim.population
	    agent.route = get_route(sim.map_data, stats.actual_driving_times, agent.start_node,agent.fin_node) #Each agent prefers the fastest route using actual driving times 
		for i in 1:length(agent.route)
		    update_stats!(stats, agent.route[i][1], agent.route[i][2]) #stats.vehicle_load and stats.actual_driving_times updated with the route chosen by agent
		end
	end 
	#Visualization
    cars_per_edge = stats.vehicle_load 
    mData = deepcopy(sim.map_data)
    plot_edge_load(mapa,mData,cars_per_edge)
end
