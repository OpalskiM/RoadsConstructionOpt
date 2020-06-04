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
