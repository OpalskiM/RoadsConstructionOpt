function split_sequence(edges::Array{Tuple{Int,Int},1}, k::Int)
    edgs = deepcopy(edges)
    seq = Array{Tuple{Int64,Int64},1}[]
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

function get_solution(sim_data::OpenStreetMapXDES.SimData,routes::Array{Tuple{Int,Int},1},
                    reference_times::Array{Float64,1},
                    λ::Float64, roadwork_time::Int, no_of_partitions::Int)
    res = zeros(length(sim_data.population))
    for segments in split_sequence(routes,no_of_partitions)
        g = remove_edges(sim_data.map_data, segments)
        res += run_sim!(sim_data, λ, roadwork_time, g)
    end
    res /= no_of_partitions
    (calculate_fitness(res,reference_times),routes)
end

function mating(population::Array{Tuple{Float64,Array{Tuple{Int64,Int64},1}},1})
    fit = [ind[1] for ind in population]
    cum_p = cumsum(fit ./ sum(fit))
    mates = zeros(Int,length(population))
    for i in 1:length(population)
        j = 1
        while cum_p[j] < rand()
            j += 1
        end
        mates[i] = j
    end
    mates
end

function order1_crossover(v1::Array{Tuple{Int64,Int64},1}, v2::Array{Tuple{Int64,Int64},1})
    l = length(v1)
    swap = rand(1:l, 2)
    alleles11, alleles21 = v1[minimum(swap) : maximum(swap)], v2[minimum(swap) : maximum(swap)]
    alleles12, alleles22 = setdiff(v2, alleles11), setdiff(v1, alleles21)
    c1 = vcat(splice!(alleles12, 1:minimum(swap) - 1), alleles11, alleles12)
    c2 = vcat(splice!(alleles22, 1:minimum(swap) - 1), alleles21, alleles22)
    c1,c2
end

function mutate!(population::Array{Tuple{Float64,Array{Tuple{Int64,Int64},1}},1}, id::Int)
    seq = population[id][2]
    swap1, swap2 = rand(1:length(seq), 2)
    val = seq[swap1]
    seq[swap1], seq[swap2] = seq[swap2], val
    population[id] = (NaN, seq)
end