#m=map_data
#s=sim_data

#1)Checking if the grapgh is stongly connected
spawn_points = sort(LightGraphs.strongly_connected_components(m.g),
        lt=(x,y)->length(x)<length(y), rev=true)[1]
    spawn_points_set = Set(spawn_points)
    for e in collect(LightGraphs.edges(m.g))
        if (!(e.src in spawn_points_set) || !(e.dst in spawn_points_set))
            LightGraphs.rem_edge!(m.g, e)
        end
    end
    
    #2) #Creating Function to run simulation once to measure road_visits on edges
roads_visits = SortedDict{Tuple{Int,Int},Int}() #Tuple to measure congestion on the roads
function run_once_init!(sim_data::OpenStreetMapXDES.SimData,
                    g::Union{LightGraphs.SimpleDiGraph{Int}, Nothing})
    sim_flow = ControlFlow(sim_data)
    stats = Stats(size(sim_data.map_data.w)[1], size(sim_data.map_data.w)[2])
    start_times = deepcopy(sim_flow.sim_clock)
    time_in_system = zeros(length(sim_data.population))
    current_time = -Inf
    while !isempty(sim_flow.sim_clock)
        id, time = DataStructures.peek(sim_flow.sim_clock)
        if time == Inf
            unclog!(sim_data, sim_flow, stats, current_time)
            continue
        end
        current_time = time
        agent = sim_data.population[id]
        if agent.current_edge > length(agent.route)
            agent.current_edge != 1 && update_previous_edge!(sim_data, sim_flow,
                                                            agent.route[agent.current_edge - 1],
                                                            stats, current_time)
            push!(stats.delays, current_time)
            DataStructures.dequeue!(sim_flow.sim_clock)
            time_in_system[id] = current_time - start_times[id]
            agent.current_edge = 1
        else
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
                                        #Counting roads_visits
            for n in agent.route
                   roads_visits[n]=get(roads_visits,n,0)+1
                           end
                           end
                           time_in_system
                                 end
                    
#Running once to count roads_visits
run_once_init!(s,m.g)
#3) Choosing the most congested 30 roads
roads = sort(collect(roads_visits), by = tuple -> last(tuple), rev = true)[1:30]

#4) Removing edges from the sim_data.map_data.g
for e in collect(roads)
    if((e[1][1] in spawn_points_set)) ||((e[1][2] in spawn_points_set))
        LightGraphs.rem_edge!(s.map_data.g,e[1][1],e[1][2])
println("edge removed")
    end
end
