#Parameters
N = 1000;
iter = 10;
λ_ind = 0.4;
l = 5.0;

#function to run once simulation to find most congested segments
map_data = OpenStreetMapX.get_map_data(pth, name)
sim_data = get_sim_data(map_data,N,l)

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


#Running once to count roads_visits
run_once_init!(sim_data,map_data.g,λ_ind)

n=10 #Number of chosen roads
prob = Dict{Tuple{Int,Int},Real}() 
for k=keys(roads_visits)
    prob[k]=values(roads_visits[k])/sum(values(roads_visits))
end
weights = collect(values(prob)) #probabilities
roads = collect(keys(prob)) #roads in the map
dict = Dict(roads[i]=>i for i=1:length(roads))
value=collect(values(dict))
samp=StatsBase.direct_sample!(value,weights)[1:n] #Example - choosing number of 10 roads
roads[samp] #Sample roads to remove from the graph

#Changing dictionaries
routes=Vector{Tuple{Int,Int}}()
for i in 1:length(samp)
push!(routes,(map_data.n[roads[samp][i][1]],map_data.n[roads[samp][i][2]]))
end

routes # a list of edges to remove from the graph
