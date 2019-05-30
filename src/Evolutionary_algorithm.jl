function optimize!(sim_data::OpenStreetMapXDES.SimData, λ_ind::Float64, 
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
        mates = mating(population)
        offidx = randperm(no_solutions) 
        for i = 1:2:no_solutions
            j = i + 1
            if rand() < crossover_rate
                seq1,seq2 = order1_crossover(population[mates[offidx[i]]][2], population[mates[offidx[j]]][2])
                offspring[i], offspring[j] = (NaN, seq1), (NaN, seq2)
            else
                offspring[i], offspring[j] = population[mates[i]], population[mates[j]]
            end
        end
        #mutation
        for i in 1:no_solutions
            (rand() < mutation_rate) && mutate!(offspring, i)
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