function run_simulation!(sim_data::SimData,speeds = OpenStreetMapX.SPEED_ROADS_URBAN)
    m, n = size(sim_data.map_data.w)
    stats = Stats(m, n)
    stats.vehicle_load = SparseArrays.spzeros(m, n) #1. SparseArray vehicle_load z obciazeniami samochodow na lukach
    actual_driving_times = OpenStreetMapX.create_weights_matrix(sim_data.map_data, OpenStreetMapX.network_travel_times(sim_data.map_data, speeds)) #2 czasy przejazdu przy zerowym obciążeniu
    stats.actual_driving_times=deepcopy(actual_driving_times) #3. creating deepcopy
    simulation_total_time = Float64(0.0) #summing total time of all agents in the simulation
	for agent in sim_data.population
	agent.route = get_route(sim_data.map_data, stats.actual_driving_times, agent.start_node,agent.fin_node)  #4 Agent jedzie najszybsza trasa korzystajac z actual_driving_times
		for i in 1:length(agent.route)
            driving_time = calculate_driving_time(stats.vehicle_load[agent.route[i][1], agent.route[i][2]],
                                                sim_data.max_densities[agent.route[i][1], agent.route[i][2]],
                                                sim_data.map_data.w[agent.route[i][1], agent.route[i][2]],
                                                sim_data.velocities[agent.route[i][1], agent.route[i][2]])
	update_stats!(stats, agent.route[1][1], agent.route[1][2], driving_time) #5 i 6 aktualizacja vehicle_load oraz stats.actual_driving_times za pomocą funkcji update_stats!
        simulation_total_time += driving_time
		end
		end #7. looping
return stats, simulation_total_time
end
