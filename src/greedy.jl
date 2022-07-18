#function to remove one edge from the graph
function remove_one_edge(m::MapData,edge::Tuple{Int64, Int64})::SimpleDiGraph{Int64}
      Graphs.rem_edge!(m.g, edge[1],edge[2])
    m.g
end


function greedy(sim::SimData,roads::Vector{Tuple{Int,Int}},T::Int, reference_time::Float64)
    z=length(roads)
    results=Float64[] #Vector to store results of simulations (to find a maximum delay caused by roadworks)
    order=Tuple{Int64, Int64}[] #Tuple to store the order of road closures
    sim_copy=deepcopy(sim)
    roads_copy=deepcopy(roads)
    for k in 1:T #loop for each batch of roadworks
        batch=Tuple{Int,Int}[] #includes all roads to be removed in one batch        
        sim_roadworks=deepcopy(sim) #Creating a copy of sim data to simulate roadworks for each batch
        for j in 1:min(ceil(z/T),length(roads_copy)) # loop for z/T roads to be renovated in each batch
            store=[]
                for i in 1:length(roads_copy) #loop to check which road has the smallest negative impact
                    s=deepcopy(sim_copy) #Creating a copy of sim data to check simple impacts and find a candidate for next roadwork
                    remove_one_edge(s.map_data,roads_copy[i])
                    score = run_simulation(s)
                    push!(store,(score.simulation_total_time, roads_copy[i]))
                end
            candidate=argmin(store)
            remove_one_edge(sim_roadworks.map_data,roads_copy[candidate]) #removing one road from the graph
            splice!(roads_copy,candidate) #removing one road from the set of roads to be renovated
            push!(order,store[candidate][2])
            push!(batch,store[candidate][2])
        end
                #simulation
                stats = run_simulation(sim_roadworks)
                simulation_total_time = stats.simulation_total_time
                relative_time = simulation_total_time/reference_time
                push!(results,relative_time)
            end
        maximum(results) #the maximum delay caused by roadworks compared to the reference time
end
