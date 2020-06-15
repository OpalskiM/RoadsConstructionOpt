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

#=
#Sim main functions
function run_once!(sim_data::SimData,
                    g::Union{LightGraphs.SimpleDiGraph{Int}, Nothing})
    #initialize sim:
    sim_flow = ControlFlow(sim_data)
    stats = Stats(size(sim_data.map_data.w)[1], size(sim_data.map_data.w)[2])
    start_times = deepcopy(sim_flow.sim_clock)
    time_in_system = zeros(length(sim_data.population))
    current_time = -Inf
    #start main loop:
    while !isempty(sim_flow.sim_clock)
        id, time = DataStructures.peek(sim_flow.sim_clock)
        #if no one can move unclog model:
        if time == Inf
            unclog!(sim_data, sim_flow, stats, current_time)
            continue
        end
        current_time = time
        agent = sim_data.population[id]
        #if agent finish his route, remove him from model:
        if agent.current_edge > length(agent.route)
            agent.current_edge != 1 && update_previous_edge!(sim_data, sim_flow,
                                                            agent.route[agent.current_edge - 1],
                                                            stats, current_time)
            push!(stats.delays, current_time)
            DataStructures.dequeue!(sim_flow.sim_clock)
            time_in_system[id] = current_time - start_times[id]
            agent.current_edge = 1
        else
            #otherwise, update his stats and move him forward:
update_route!(sim_data, sim_flow, agent.route[agent.current_edge], id, current_time) || continue
        update_control_flow!(sim_data, sim_flow, agent.route[agent.current_edge],
                                stats, id, current_time)
            agent.current_edge > 2 && update_previous_edge!(sim_data,sim_flow,
                                                            agent.route[agent.current_edge - 2],
                                                            stats, current_time)
        end
    end
    for agent in sim_data.population
        agent.route = new_graph_routing(sim_data.map_data, g,
                                        sim_data.driving_times + agent.expected_driving_times,
                                        agent.start_node, agent.fin_node)
    end
    time_in_system
end


function run_sim!(sim_data::OpenStreetMapXDES.SimData, iter::Int,
                g::Union{LightGraphs.SimpleDiGraph{Int}, Nothing} = nothing)
    res = zeros(length(sim_data.population))
    for i = 1:iter
        res .+= run_once!(sim_data, g)
    end
    res ./ iter
end
=#
