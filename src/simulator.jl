function run_simulation!(sim::SimData, speeds = OpenStreetMapX.SPEED_ROADS_URBAN)::Stats
    m, n = size(sim.map_data.w)
    stats = Stats(m, n)
    stats.vehicle_load = SparseArrays.spzeros(m, n) #number of agents on edges
	stats.actual_driving_times=deepcopy(sim.driving_times) #driving times with 0 traffic
    stats.simulation_total_time = 0.0 #summing total time of all agents in the simulation
	for agent in sim.population
	    agent.route = get_route(sim.map_data, stats.actual_driving_times, agent.start_node,agent.fin_node) #Each agent prefers the fastest route using actual driving times
		for i in 1:length(agent.route)
		    update_stats!(stats, sim, agent.route[i][1], agent.route[i][2]) #stats.vehicle_load and stats.actual_driving_times updated with the route chosen by agent
		end
	end
    stats
end
