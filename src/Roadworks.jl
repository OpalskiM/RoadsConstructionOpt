reference_time=stats.simulation_total_time
vehicle_loads=deepcopy(stats.vehicle_load)

#1)Checking if the grapgh is stongly connected
spawn_points = sort(LightGraphs.strongly_connected_components(s.map_data.g),
        lt=(x,y)->length(x)<length(y), rev=true)[1]
    spawn_points_set = Set(spawn_points)
    for e in collect(LightGraphs.edges(s.map_data.g))
        if (!(e.src in spawn_points_set) || !(e.dst in spawn_points_set))
            LightGraphs.rem_edge!(s.map_data.g, e)
        end
    end

#2) Choosing the most congested 30 roads
dict = Dict(((s.map_data.v[e[1]],s.map_data.v[e[2]]) =>vehicle_loads[s.map_data.v[e[1]],s.map_data.v[e[2]]]) for e in s.map_data.e)
loads=sort(collect(dict), by = tuple -> last(tuple), rev = true)[1:30]
roads=[]
for i in 1:length(loads)
push!(roads,loads[i][1])
end
roads

#Auxiliary functions

#Function to split roads into batches
function split_sequence(edges::Array{Any,1}, k::Int)
    edgs = deepcopy(edges)
    seq = Array{Any,1}[]
    size = Int(round(length(edgs)/k))
    len = length(edgs)
    while len > 0
        push!(seq,splice!(edgs,1:min(size, length(edgs))))
        len -= size
    end
    seq
end

#Function to remove edges from the graph
function remove_edges(m::MapData,edgelist::Array{Any,1})
g = deepcopy(m.g)
    for edge in edgelist
        LightGraphs.rem_edge!(m.g, edge[1],edge[2])
    end
    g
end

#Function to calculate maximum time spent in traffic for each part of roadworks
function calculate_fitness(times::Array{Any,1}, reference_time::Float64) 
    avg_times = []
    for result in times
    time = result/reference_time
    push!(avg_times,time)
end
maximum(avg_times)
end #

#Function to get relative solution to reference scenario depending on number of partitions
function get_solution(sim::SimData, roads::Array{Any,1},
                    reference_time::Float64,
                    no_of_partitions::Int)
    res = []
    for segments in split_sequence(roads,no_of_partitions)
        sim_data=deepcopy(sim)
        g = remove_edges(sim_data.map_data, segments)
        time = run_simulation!(sim_data)
        push!(res,time.simulation_total_time)
    end
    calculate_fitness(res,reference_time)
end
