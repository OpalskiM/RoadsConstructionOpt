"""
calculate_driving_time(n_e::Float64,N_e::Float64,d::Float64,V_max::Float64, V_min::Float64 = 1.0)

**Arguments**
* `n_e`        		    : number of agents at edge e
* `N_e`  	            : capacity of edge e
* `d`             	    : length of edge e
* `V_max`               : maximum commuter's velocity at en edge e
* `v_min`               : minimum commuter's velocity at en edge e
"""

function calculate_driving_time(n_e::Float64,
                                N_e::Float64,
                                d::Float64,
                                V_max::Float64,
                                V_min::Float64 = 1.0)
    v = (V_max - V_min)* max((1 - n_e/N_e),0.0) + V_min
    return d/v
end

function update_stats!(stats::Stats, edge0::Int, edge1::Int, driving_time::Float64)
    stats.cars_count[edge0, edge1] += 1.0
    stats.avg_driving_times[edge0, edge1] += (driving_time - stats.avg_driving_times[edge0, edge1])/stats.cars_count[edge0, edge1]
end

function update_beliefs!(agent::OpenStreetMapXDES.Agent, edge0::Int, edge1::Int,
                        driving_time::Float64)
    agent.expected_driving_times[edge0, edge1] += (driving_time - agent.expected_driving_times[edge0, edge1])
end

function ControlFlow(sim_data::OpenStreetMapXDES.SimData)
    edges = Dict{Tuple{Int,Int},EdgeTraffic}()
    queue = DataStructures.PriorityQueue{Int,Float64}()
    for (i, agent) in enumerate(sim_data.population)
        queue[i] = departure_time(sim_data.driving_times + agent.expected_driving_times, agent.route)
    end
    for (node0,node1) in sim_data.map_data.e
         edges[(sim_data.map_data.v[node0], sim_data.map_data.v[node1])] = EdgeTraffic()
    end
    ControlFlow(edges,queue)
end

function departure_time(w::AbstractMatrix{Float64}, route::Array{Tuple{Int64,Int64},1})
    isempty(route) ? (driving_time = 0) : (driving_time = sum(w[edge[1],edge[2]] for edge in route))
    return -driving_time
end

function update_control_flow!(sim_data::OpenStreetMapXDES.SimData, sim_flow::ControlFlow, edge::Tuple{Int,Int},
                            stats::Stats, id::Int, current_time::Float64,
                            waiting_time::Float64 = 0.0)
    agent = sim_data.population[id]
    driving_time = calculate_driving_time(sim_flow.edges[edge].cars_count,
                                        sim_data.max_densities[edge],
                                        sim_data.map_data.w[edge],
                                        sim_data.velocities[edge])
    update_beliefs!(agent,edge[1], edge[2], driving_time + waiting_time)
    update_stats!(stats, edge[1], edge[2], driving_time + waiting_time)
    sim_flow.edges[edge].cars_count += 1.0
    agent.current_edge += 1
    sim_flow.sim_clock[id] = current_time + driving_time
end

function new_route!(sim_data::OpenStreetMapXDES.SimData, agent::OpenStreetMapXDES.Agent, edge::Tuple{Int,Int})
    if agent.current_edge != 1
        route = [agent.route[agent.current_edge - 1], (edge[1], edge[2]),]
        agent.current_edge = 2
    else
        route = [(edge[1], edge[2]),]
    end
    #select new route:
    agent.route = vcat(route, get_route(sim_data.map_data,
                        sim_data.driving_times + agent.expected_driving_times,
                        edge[2], agent.fin_node))
end

function update_route!(sim_data::OpenStreetMapXDES.SimData, sim_flow::ControlFlow,
                        edge::Tuple{Int,Int}, id::Int, time::Float64)
    agent = sim_data.population[id]
    #if he is capable of moving forward, then do nothing:
    sim_flow.edges[edge].cars_count + 1.0 > max(sim_data.max_densities[edge],1.0) || return true
    #otherwise create a list of feasible roads and select one of them randomly:
    select_route = [edge,]
    for node in sim_data.map_data.g.fadjlist[edge[1]]
        clogged = sim_flow.edges[edge[1],node].cars_count + 1.0 > max(sim_data.max_densities[edge[1],node],1.0)
        clogged || push!(select_route, (edge[1],node))
    end
    new_edge = rand(select_route)
    #if he has decided to stay on the same route, put him on queue:
    if new_edge == edge
        push!(sim_flow.edges[edge].waiting_queue,(id, time))
        sim_flow.sim_clock[id] = Inf
        return false
    #otherwise find new route:
    else
        new_route!(sim_data, agent, new_edge)
        return true
    end
end

function update_queue!(sim_data::OpenStreetMapXDES.SimData, sim_flow::ControlFlow, edge::Tuple{Int,Int},
                        stats::Stats, current_time::Float64)
    #select first agent waiting in queue:
    id, previous_clock = popfirst!(sim_flow.edges[edge].waiting_queue)
    agent = sim_data.population[id]
    #find if he is capable of moving forward:
    update_route!(sim_data, sim_flow, edge, id, previous_clock) || return false
    #calculate how long he has been waiting:
    waiting_time = current_time - previous_clock
    #if he finish his route, remove him from model:
    #otherwise, update his stats:
    update_control_flow!(sim_data, sim_flow, agent.route[agent.current_edge],
                                stats, id, current_time, waiting_time)
    #update agent(s) in his previous edge:
    agent.current_edge > 2 && update_previous_edge!(sim_data, sim_flow, agent.route[agent.current_edge - 2], stats, current_time)
    return true
end


function update_previous_edge!(sim_data::OpenStreetMapXDES.SimData, sim_flow::ControlFlow, edge::Tuple{Int,Int},
                            stats::Stats, current_time::Float64)
    #remove agent from previous edge:
    sim_flow.edges[edge[1],edge[2]].cars_count -= 1.0
    #check if some agents are waiting to enter this edge and can move to edge:
    while !isempty(sim_flow.edges[edge].waiting_queue)
        !update_queue!(sim_data, sim_flow, edge, stats, current_time) && break
    end
end


function unclog!(sim_data::OpenStreetMapXDES.SimData, sim_flow::ControlFlow,
                stats::Stats, current_time::Float64)
    for (edge, edge_traffic) in sim_flow.edges
        while !isempty(edge_traffic.waiting_queue)
            id, previous_clock = popfirst!(sim_flow.edges[edge].waiting_queue)
            agent = sim_data.population[id]
            waiting_time = current_time - previous_clock
            update_control_flow!(sim_data, sim_flow, edge, stats,
                                id, current_time, waiting_time)
            agent.current_edge > 2 && update_previous_edge!(sim_data, sim_flow, agent.route[agent.current_edge - 2],
                                                            stats, current_time)
        end
    end
end
