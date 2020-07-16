using Random
using StatsBase

"""
opt(f::Function, T::Int, z::Int, maxiter::Int, p::Float64, roads, sim, reference_time)

Return the optimal assignment of road segments to periods.
Note that the problem in our current statement has multiple optima
as any permutation of periods has exactly the same evaluation.

# Agruments
* `f`: function taking a vector of assignments of road segments to periods
  and number of periods and calculating fitness of such a solution.
* `T`: number of periods
* `z`: number of roads
* `maxiter`: maximum number of allowed iterations
* `p`: probability of accepting decrease in the solution feasibility
* `roads`: vector of roads to renovate
* `sim`: sim data
* `reference_time`: reference time (without roadworks)
"""

function opt(f::Function, T::Int, z::Int, maxiter::Int, p::Float64, presolve::Bool, roads =roads, sim = sim, reference_time = reference_time)
    @assert T > 0
    @assert z > 0
    @assert 0 <= p <= 1
    sol = rand(1:T, z)
    chunks,total = f(sol,roads,sim,reference_time)
    best_sol = sol 
    best_eval = total 
    i = 0
    while i < maxiter
        i += 1
        w = tiedrank(chunks) 
        maximum(w) == minimum(w) && break
        src = sample(1:z, Weights(exp.(w[sol]))) 
        dst = sample(1:T, Weights(exp.(-w))) 
        new_sol = copy(sol)
        new_sol[src] = dst
        new_chunks, new_total = f(new_sol, roads,sim,reference_time)
        if new_total <= total || rand() < p
            sol = new_sol
            total = new_total
            chunks = new_chunks
            if total < best_eval
                best_sol = sol
                best_eval = total
            end
        end
    end
    return best_sol, best_eval, i
end


#auxiliary function f
#finding maximum roadworks time for given permutation "sol"

function f(sol,roads,sim,reference_time)
    chunks=Float64[]
    for i in unique(sol)
    spl=findall(x->x==i, sol)
    s=deepcopy(sim)
    push!(chunks,get_solution(s,roads[spl],reference_time,1))
end
return chunks,maximum(chunks)
end

