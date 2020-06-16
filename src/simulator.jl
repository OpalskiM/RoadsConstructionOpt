function remove_edges(m::OpenStreetMapX.MapData,edgelist::Array{Tuple{Int,Int},1})
    g = deepcopy(m.g)
    for edge in edgelist
        LightGraphs.rem_edge!(g, m.v[edge[1]],m.v[edge[2]])
    end
    g
end

function new_graph_routing(m::OpenStreetMapX.MapData,
                            g::Union{LightGraphs.SimpleDiGraph{Int}, Nothing},
                            w::SparseArrays.SparseMatrixCSC{Float64,Int},
                            v0::Int, v1::Int)
    heuristic(u,v) = OpenStreetMapX.get_distance(u, v, m.nodes, m.n)
    isa(g, Nothing) && (g = m.g)
    route_indices, route_values = a_star_algorithm(g, v0, v1, w, heuristic)
    [(route_indices[j - 1],route_indices[j]) for j = 2:length(route_indices)]
end

function run_single_iteration!(sim_data::SimData)
    sim_clock = DataStructures.PriorityQueue{Int, Float64}()
    for i = 1:length(sim_data.population)
        sim_clock[i] = departure_time(sim_data.driving_times, sim_data.population[i].route)
    end
    m, n = size(sim_data.map_data.w)
    stats = Stats(m, n)
    traffic_densities = SparseArrays.spzeros(m, n)
    while !isempty(sim_clock)
        id, current_time = DataStructures.peek(sim_clock)
        agent = sim_data.population[id]
        (agent.current_edge != 1) && (traffic_densities[agent.route[agent.current_edge - 1][1], agent.route[agent.current_edge - 1][2]] -= 1.0)
        if agent.current_edge > length(agent.route)
			push!(stats.delays, current_time)
            DataStructures.dequeue!(sim_clock)
            agent.current_edge = 1
        else
            edge0, edge1 = agent.route[agent.current_edge]
            driving_time = calculate_driving_time(traffic_densities[edge0, edge1],
                                                sim_data.max_densities[edge0, edge1],
                                                sim_data.map_data.w[edge0, edge1],
                                                sim_data.velocities[edge0, edge1])
            update_stats!(stats, edge0, edge1, driving_time)
            traffic_densities[edge0, edge1] += 1.0
            agent.current_edge += 1
            sim_clock[id] += driving_time
        end
    end
	return stats
end
