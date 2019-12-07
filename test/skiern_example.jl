#Example 
no_solutions = 10    #Number of solutions in evolutionary algorithm
roadwork_time = 10  # approximate length of roadwork of single segment  
no_of_partitions = 5   #number of steps in roadwork process
crossover_rate = 0.8
mutation_rate = 0.2
elitism = 0.1

#Example

res = NamedTuple[]
for mymethod in [optimize!, optimize2!]
    sim_data_copy = deepcopy(sim_data)
    Random.seed!(0);
    push!(res, mymethod(
        sim_data_copy,
        λ_ind,
        routes,
        no_solutions,
        roadwork_time,
        no_of_partitions,
        crossover_rate,
        mutation_rate,
        elitism;
        maxiter = 30
    ))
end