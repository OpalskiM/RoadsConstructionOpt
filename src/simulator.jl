using OpenStreetMapX
using OpenStreetMapXDES
using LightGraphs
using SparseArrays

#Functions to remove edges and rerouting
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

#Sim main functions

function run_once!(sim_data::OpenStreetMapXDES.SimData, 
                    g::Union{LightGraphs.SimpleDiGraph{Int}, Nothing},
                    λ_ind::Float64)
    #initialize sim:
    sim_flow = OpenStreetMapXDES.ControlFlow(sim_data)
    stats = OpenStreetMapXDES.Stats(size(sim_data.map_data.w)[1], size(sim_data.map_data.w)[2])
    start_times = deepcopy(sim_flow.sim_clock)
    time_in_system = zeros(length(sim_data.population))
    current_time = -Inf
    #start main loop:
    while !isempty(sim_flow.sim_clock)
        id, time = DataStructures.peek(sim_flow.sim_clock)
        #if no one can move unclog model:
        if time == Inf 
            OpenStreetMapXDES.unclog!(sim_data, sim_flow, stats, current_time, λ_ind)
            continue
        end
        current_time = time
        agent = sim_data.population[id]
        #if agent finish his route, remove him from model:
        if agent.current_edge > length(agent.route)
            agent.current_edge != 1 && OpenStreetMapXDES.update_previous_edge!(sim_data, sim_flow, 
                                                            agent.route[agent.current_edge - 1],
                                                            stats, current_time, λ_ind)
            push!(stats.delays, current_time)
            DataStructures.dequeue!(sim_flow.sim_clock)
            time_in_system[id] = current_time - start_times[id]
            agent.current_edge = 1
        else
            #otherwise, update his stats and move him forward:
            OpenStreetMapXDES.update_route!(sim_data, sim_flow, agent.route[agent.current_edge], id, current_time) || continue
            OpenStreetMapXDES.update_control_flow!(sim_data, sim_flow, agent.route[agent.current_edge],
                                stats, id, λ_ind, current_time)   
            agent.current_edge > 2 && OpenStreetMapXDES.update_previous_edge!(sim_data,sim_flow, 
                                                            agent.route[agent.current_edge - 2],
                                                            stats, current_time, λ_ind)
        end
    end
    for agent in sim_data.population
        agent.route = new_graph_routing(sim_data.map_data, g,
                                        sim_data.driving_times + agent.expected_driving_times,
                                        agent.start_node, agent.fin_node)
    end
    time_in_system
end

function run_sim!(sim_data::OpenStreetMapXDES.SimData, λ_ind::Float64, iter::Int,
                g::Union{LightGraphs.SimpleDiGraph{Int}, Nothing} = nothing)
    res = zeros(length(sim_data.population))
    for i = 1:iter
        res .+= run_once!(sim_data, g, λ_ind)
    end
    res ./ iter
end
