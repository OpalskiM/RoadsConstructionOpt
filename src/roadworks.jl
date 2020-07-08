#Function to split roads into batches
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

#Function to remove edges from the graph
function remove_edges(m::MapData,edgelist::Vector{Tuple{Int,Int}})
    g = deepcopy(m.g)
    for edge in edgelist
        LightGraphs.rem_edge!(m.g, edge[1],edge[2])
    end
    g
end

#Function to calculate maximum time spent in traffic for each part of roadworks
function calculate_fitness(times::Vector{Float64}, reference_time::Float64)
    avg_times = Float64[]
    for result in times
        time = result/reference_time
        push!(avg_times,time)
    end
    maximum(avg_times)
end

"""
    get_solution(sim::SimData, roads::Vector{Tuple{Int,Int}},reference_time::Float64,no_of_partitions::Int)

Returns relative solution to reference scenario depending on number of partitions

**Arguments**
*'sim' - Sim Data
*'roads' - Roads to renovate
*'reference_time' - benchmark time (total time of simulation without roadworks)
*'no_of_partitions' - number of roadworks batches (time of each roadwork set to 1)
"""
function get_solution(sim::SimData, roads::Vector{Tuple{Int,Int}},
                    reference_time::Float64,
                    no_of_partitions::Int)
    res = Float64[]
    for segments in split_sequence(roads,no_of_partitions)
        sim_data=deepcopy(sim)
        g = remove_edges(sim_data.map_data, segments)
        time = run_simulation!(sim_data)
        push!(res,time.simulation_total_time)
    end
    calculate_fitness(res,reference_time)
end
