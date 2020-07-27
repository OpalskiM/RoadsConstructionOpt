function run_simulation(sim::SimData, g=sim.map_data.g, speeds = OpenStreetMapX.SPEED_ROADS_URBAN)::SimStats
    m, n = size(sim.map_data.w)
    stats = SimStats(m, n)
	stats.actual_driving_times=deepcopy(sim.driving_times) #driving times with 0 traffic
    stats.simulation_total_time = 0.0 #summing total time of all agents in the simulation
	#code copied from OpenStreetMapX.get_route function
	f_heur(x, B = agent.fin_node, nodes = sim.map_data.nodes, vertices = sim.map_data.n) =
		OpenStreetMapX.get_distance(x,B,nodes,vertices)/(maximum(values(speeds))/3.6)
	for agent in sim.population
		#  code copied from OpenStreetMapX.get_route function
		#  to manipulate graph g and avoid clonning the entire sim.map_data
		#Each agent prefers the fastest route using actual driving times
	    route_indices, route_values = OpenStreetMapX.a_star_algorithm(g, agent.start_node,agent.fin_node, stats.actual_driving_times, f_heur)
		agent.route = [(route_indices[j - 1],route_indices[j]) for j = 2:length(route_indices)]
	    #agent.route = get_route(sim.map_data, stats.actual_driving_times, agent.start_node,agent.fin_node)
		for i in 1:length(agent.route)
		    update_stats!(stats, sim, agent.route[i][1], agent.route[i][2]) #stats.vehicle_load and stats.actual_driving_times updated with the route chosen by agent
		end
	end
    stats
end
