using OpenStreetMapXDES

function split_sequence(edges::Vector{Tuple{Int,Int}}, k::Int)
    edgs = deepcopy(edges)
    seq = Vector{Tuple{Int,Int}}[]
    size = Int(round(length(edgs)/k))
    len = length(edgs)
    while len > 0
        push!(seq,splice!(edgs,1:min(size, length(edgs))))
        len -= size
    end 
    seq
end

function calculate_fitness(times, reference) 
    times = filter!(x -> !isnan(x), times ./reference)
    sum(times)/length(times)
end

function get_solution(sim_data::OpenStreetMapXDES.SimData,routes::Vector{Tuple{Int,Int}},
                    reference_times::Vector{Float64},
                    λ::Float64, roadwork_time::Int, no_of_partitions::Int)
    res = zeros(length(sim_data.population))
    for segments in split_sequence(routes,no_of_partitions)
        g = remove_edges(sim_data.map_data, segments)
        res += run_sim!(sim_data, λ, roadwork_time, g)
    end
    res /= no_of_partitions
    (calculate_fitness(res,reference_times),routes)
end

#Function to run simulation once to count cars on roads to select the roads to renovate in direct proportion with road traffic
    roads_visits = Dict{Tuple{Int,Int},Int}() #Tuple to measure congestion on the roads
 function run_once_init!(sim_data::OpenStreetMapXDES.SimData,
     g::Union{LightGraphs.SimpleDiGraph{Int}, Nothing},
     λ_ind::Float64)
 sim_flow = OpenStreetMapXDES.ControlFlow(sim_data)
 stats = OpenStreetMapXDES.Stats(size(sim_data.map_data.w)[1], size(sim_data.map_data.w)[2])
 start_times = deepcopy(sim_flow.sim_clock)
 time_in_system = zeros(length(sim_data.population))
 current_time = -Inf
 while !isempty(sim_flow.sim_clock)
 id, time = DataStructures.peek(sim_flow.sim_clock)
 if time == Inf
 OpenStreetMapXDES.unclog!(sim_data, sim_flow, stats, current_time, λ_ind)
 continue
 end
 current_time = time
 agent = sim_data.population[id]
 if agent.current_edge > length(agent.route)
 agent.current_edge != 1 && OpenStreetMapXDES.update_previous_edge!(sim_data, sim_flow,
                                             agent.route[agent.current_edge - 1],
                                             stats, current_time, λ_ind)
 push!(stats.delays, current_time)
 DataStructures.dequeue!(sim_flow.sim_clock)
 time_in_system[id] = current_time - start_times[id]
 agent.current_edge = 1
 else
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
 #Counting roads_visits
                         for n in agent.route
                                roads_visits[n]=get(roads_visits,n,0)+1
                             end
                         end
 time_in_system
 end

