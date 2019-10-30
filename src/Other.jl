#1. Alternative selection
function tournament(population::Array{Tuple{Float64,Array{Tuple{Int64,Int64},1}},1})
    length(population) <= 0 && error("Population length needs to be positive")
    fit = [ind[1] for ind in population]
        cum_p = cumsum(fit ./ sum(fit))
     mates = zeros(Int,length(population))
    for i in 1:length(population)
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

#2. Alternative crossover
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

#3. Alternative mutation
function insertion!(population::Array{Tuple{Float64,Array{Tuple{Int64,Int64},1}},1}, id::Int)
    seq = population[id][2]
    swap1, swap2 = rand(1:length(seq), 2)
    val = seq[swap1]
    val2 = seq[swap2]
    deleteat!(seq,swap1)
    insert!(seq,swap2,val2)
    population[id]=(NaN, seq)
end

#4. Changing optimization function 
function optimize2!(sim_data::OpenStreetMapXDES.SimData, λ_ind::Float64, 
    routes::Array{Tuple{Int,Int},1}, no_solutions::Int,
    roadwork_time::Int, no_of_partitions::Int,
    crossover_rate::Float64, mutation_rate::Float64, 
    elitism::Float64;
    burning_time::Int = 50, runtime::Int = 20,
    ϵ = 0.0001, maxiter::Int = 500, toliter::Int = 10)
#let no_solution be even:
mod(no_solutions,2) == 1 && (no_solutions += 1)
#prepare enviroment:
run_sim!(sim_data, λ_ind, burning_time)
#get reference scenario:
reference_times = run_sim!(deepcopy(sim_data), λ_ind, runtime)
#generate first solutions:
population = Tuple{Float64, Array{Tuple{Int64,Int64},1}}[]
for i = 1:no_solutions
push!(population, get_solution(deepcopy(sim_data),shuffle(routes), reference_times, λ_ind, roadwork_time, no_of_partitions))
end
@info "First generation done!"
sort!(population)
(best_fit, best_solution), _ = findmin(population)
(worst_fit, worst_solution), _ = findmax(population)
#main loop:
iter = 1
fit_iter = 1
δ = Inf
while true
offspring = similar(population)
#mating
mates = tournament(population) ##################### 1. Change (tournament)
offidx = randperm(no_solutions) 
for i = 1:2:no_solutions
j = i + 1
if rand() < crossover_rate
seq1,seq2 = twopoint(population[mates[offidx[i]]][2], population[mates[offidx[j]]][2]) ################## 2. Change (twopoint)
offspring[i], offspring[j] = (NaN, seq1), (NaN, seq2)
else
offspring[i], offspring[j] = population[mates[i]], population[mates[j]]
end
end
#mutation
for i in 1:no_solutions
(rand() < mutation_rate) && insertion!(offspring, i) ################ 3. Change (insertion)
end
#elitism
for i in 1:Int(round(elitism*no_solutions))
idx = rand(1:no_solutions)
offspring[idx] = population[i]
end
#compute new fitnesses
for (id, individual) in enumerate(offspring)
if isnan(individual[1])
offspring[id] = get_solution(deepcopy(sim_data),individual[2], 
                            reference_times, λ_ind, 
                            roadwork_time, no_of_partitions)
end
end
#convergence
population = offspring
sort!(population)
(next_best_fit, next_best_solution), _ = findmin(population)
(next_worst_fit, next_worst_solution), _ = findmax(population)
(next_worst_fit > worst_fit) && (worst_fit = next_worst_fit; worst_solution =  next_worst_solution)
δ = abs(next_best_fit - best_fit)
best_fit, best_solution = next_best_fit, next_best_solution
if δ < ϵ  
fit_iter > toliter && break
fit_iter += 1 
else
fit_iter = 1
end
iter += 1
iter >= maxiter && break
@info "iteration $iter done"
end
(best_fit, best_solution), (worst_fit, worst_solution)
end


#Example
N = 1000; l = 5.0;
map_data = OpenStreetMapX.get_map_data(pth, name)
sim_data = get_sim_data(map_data,N,l)
λ_ind = 0.5
λ_soc = 0.4
routes = map_data.e
no_solutions = 50
roadwork_time = 10
no_of_partitions = 5
crossover_rate = 0.8
mutation_rate = 0.2
elitism = 0.1
optimize2!(sim_data,λ_ind,routes,no_solutions,roadwork_time,no_of_partitions,crossover_rate,mutation_rate,elitism)


