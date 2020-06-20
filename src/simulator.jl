function run_simulation!(sim::SimData,speeds = OpenStreetMapX.SPEED_ROADS_URBAN)
    m, n = size(sim.map_data.w)
    stats = Stats(m, n)
	# TODO : use English comments in the code
    stats.vehicle_load = SparseArrays.spzeros(m, n) #1. SparseArray vehicle_load z obciazeniami samochodow na lukach

	# TODO : it should be just a `deepcopy(driving_times)` that you are creating in the function `get_sim`
    actual_driving_times = OpenStreetMapX.create_weights_matrix(sim.map_data, OpenStreetMapX.network_travel_times(sim.map_data, speeds)) #2 czasy przejazdu przy zerowym obciążeniu
    stats.actual_driving_times=deepcopy(actual_driving_times) #3. creating deepcopy
    simulation_total_time = 0.0 #summing total time of all agents in the simulation
	for agent in sim.population
	    agent.route = get_route(sim.map_data, stats.actual_driving_times, agent.start_node,agent.fin_node)  #4 Agent jedzie najszybsza trasa korzystajac z actual_driving_times
		for i in 1:length(agent.route)
			# TODO : The driving_time should be calculated inside `update_stats!` not here

            driving_time = calculate_driving_time(stats.vehicle_load[agent.route[i][1], agent.route[i][2]],
                                                sim.max_densities[agent.route[i][1], agent.route[i][2]],
                                                sim.map_data.w[agent.route[i][1], agent.route[i][2]],
                                                sim.velocities[agent.route[i][1], agent.route[i][2]])
	        update_stats!(stats, agent.route[1][1], agent.route[1][2], driving_time) #5 i 6 aktualizacja vehicle_load oraz stats.actual_driving_times za pomocą funkcji update_stats!
            simulation_total_time += driving_time
		 end
	end #7. looping
    return stats, simulation_total_time
end
