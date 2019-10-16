function vswap!(v1::T, v2::T, idx::Int) where {T <: Vector}
    val = v1[idx]
    v1[idx] = v2[idx]
    v2[idx] = val
end

function twopoint(v1::Array{Tuple{Int64,Int64},1}, v2::Array{Tuple{Int64,Int64},1})
    l = length(v1)
    c1 = copy(v1)
    c2 = copy(v2)
    from, to = rand(1:l, 2)
    from, to = from > to ? (to, from)  : (from, to)
    for i in from:to
        vswap!(c1, c2, i)
    end
    return c1, c2
end

#Mutation

function insertion!(population::Array{Tuple{Float64,Array{Tuple{Int64,Int64},1}},1}, id::Int)
    seq = population[id][2]
    swap1, swap2 = rand(1:length(seq), 2)
    val = seq[swap1]
    val2 = seq[swap2]
    deleteat!(seq,swap1)
    insert!(seq,swap2,val2)
    population[id]=(NaN, seq)
end

#selection
function tournament(population::Array{Tuple{Float64,Array{Tuple{Int64,Int64},1}},1})
    length(population) <= 0 && error("Population length needs to be positive")
    fit = [ind[1] for ind in population]
        cum_p = cumsum(fit ./ sum(fit))
    #   function tournamentN(fitness::Vector{Float64}, N::Int)
     mates = zeros(Int,length(population))
    # nFitness = length(fit)
    for i in 1:length(population)
    #j = 1
    #c = 1  
              contender = unique(rand(1:length(fit), length(population)))
                while length(contender) < length(population)
                    contender = unique(vcat(contender, rand(1:length(fit), length(population)- length(contender))))
                end
                winner = first(contender)
                winnerFitness = fit[winner]
                for idx = 2:length(population)
                    c = contender[idx]
                    if winnerFitness < fit[c]
                        winner = c
                        winnerFitness = fit[c]
                    end
                end
                mates[i] = winner
            end
            return mates
        end
