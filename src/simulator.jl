function run_simulation!(sim_data::SimData,speeds = OpenStreetMapX.SPEED_ROADS_URBAN)
    m, n = size(sim_data.map_data.w)
    stats = Stats(m, n)
    traffic_densities = SparseArrays.spzeros(m, n)
    stats.actual_driving_times = OpenStreetMapX.create_weights_matrix(sim_data.map_data, OpenStreetMapX.network_travel_times(sim_data.map_data, speeds))
    simulation_total_time = Float64(0.0) #summing total travel time of all agents in the simulation
	for agent in sim_data.population
	agent.route = get_route(sim_data.map_data, stats.actual_driving_times, agent.start_node,agent.fin_node)
	for i in 1:length(agent.route)
            driving_time = calculate_driving_time(traffic_densities[agent.route[i][1], agent.route[i][2]],
                                                sim_data.max_densities[agent.route[i][1], agent.route[i][2]],
                                                sim_data.map_data.w[agent.route[i][1], agent.route[i][2]],
                                                sim_data.velocities[agent.route[i][1], agent.route[i][2]])
            update_stats!(stats, agent.route[i][1], agent.route[i][2], driving_time)
            traffic_densities[agent.route[i][1], agent.route[i][2]] += 1.0
	    simulation_total_time += driving_time
	end
        end
	return stats, simulation_total_time
end
