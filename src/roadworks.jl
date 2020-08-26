#Function to split roads into batches
function split_sequence(edgs::AbstractVector{T}, k::Int) where T
    size = ceil(Int,length(edgs)/k)
    [edgs[(i*size+1):min((i+1)*size,length(edgs))] for i in 0:(k-1)]
end

#Function to remove edges from the graph
function copy_remove_edges(m::MapData,edgelist::AbstractVector{Tuple{Int,Int}})::SimpleDiGraph{Int64}
    g = deepcopy(m.g)
    for edge in edgelist
      LightGraphs.rem_edge!(g, edge[1],edge[2])
    end
    g
end





"""
    get_solution(sim::SimData, roads::Vector{Tuple{Int,Int}},reference_time::Float64,no_of_partitions::Int)

Returns relative solution to reference scenario depending on number of partitions

**Arguments**
*'sim' - Sim Data
*'roads' - Roads to renovate
*'reference_time' - benchmark time (total time of simulation without roadworks)
*'no_of_partitions' - number of roadworks batches (time of each roadwork set to 1)
*'SOLUTION_BUFFER' - dictionary to store solutions
"""
function get_solution(sim::SimData, roads::Vector{Tuple{Int,Int}},
                    reference_time::Float64,
                    no_of_partitions::Int,
                    SOLUTION_BUFFER::Dict{Vector{Tuple{Int,Int}},Float64})
    res = Float64[]
    for segments in split_sequence(roads,no_of_partitions)
        simulation_total_time = get(SOLUTION_BUFFER, segments,-1.0)
        if simulation_total_time < -0.1
            g = copy_remove_edges(sim.map_data, segments)
            stats::SimStats = run_simulation(sim, g)
            simulation_total_time = stats.simulation_total_time
            SOLUTION_BUFFER[segments] = simulation_total_time
        end
        push!(res,simulation_total_time)
    end
    #calculate maximum time spent in traffic
    maximum(res)/reference_time
end
