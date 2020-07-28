using Random
using StatsBase


"""
    initial_plan(f::Function, T::Int, z::Int)

Return initial plan made from a random allocation of roads to groups

# Agruments
* `f`: function taking a vector of assignments of road segments to periods
  and number of periods; if it is passed 0 it means that road is assigned to no period
  and returning feasibility score for each period as a vector and total feasibility
  it is assumed that it is minimized
* `T`: number of periods
* `z`: number of roads
"""
function initial_plan(f::Function, T::Int, z::Int)
    sol = zeros(Int, z)
    for i in randperm(z)
        chunks, total = f(sol, T)
        sol[i] = rand(findall(==(minimum(chunks)), chunks))
    end
    return sol
end


"""
opt(f::Function, T::Int, z::Int, maxiter::Int, p::Float64, roads, sim, reference_time)

Return the optimal assignment of road segments to periods.
Note that the problem in our current statement has multiple optima
as any permutation of periods has exactly the same evaluation.

# Agruments
* `f`: function taking a vector of assignments of road segments to periods
  and number of periods and calculating fitness of such a solution.
* `T`: number of periods
* `maxiter`: maximum number of allowed iterations
* `p`: probability of accepting decrease in the solution feasibility
* `roads`: vector of roads to renovate
* `sim`: sim data
* `reference_time`: reference time (without roadworks)
* `SOLUTION_BUFFER`: dictionary to use precomputed solutions
"""

function opt(f::Function, T::Int, maxiter::Int, p::Float64,
        roads::Vector{Tuple{Int,Int}}, sim::SimData,
        reference_time::Float64,
        SOLUTION_BUFFER::Dict{Vector{Tuple{Int,Int}},Float64} = Dict{Vector{Tuple{Int,Int}},Float64}()
        )
    @assert T > 0
    @assert length(roads) > 0
    @assert 0 <= p <= 1

    z = length(roads)
    sol = rand(1:T, z)
    chunks,total = f(T,sol,roads,sim,reference_time, SOLUTION_BUFFER)
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
        new_chunks, new_total = f(T,new_sol, roads,sim,reference_time,SOLUTION_BUFFER)
        if new_total <= total || rand() < p
            sol = new_sol
            total = new_total
            chunks = new_chunks
            if total < best_eval
                best_sol = sol
                best_eval = total
            end
        end
        if i % 10 == 0
            print(".")
        end
    end
    println()
    return best_sol, best_eval, i
end


#auxiliary function f
#finding maximum roadworks time for given permutation "sol"

"""
function taking a vector of assignments of road segments to periods
  and number of periods; if it is passed 0 it means that road is assigned to no period
  and returning feasibility score for each period as a vector and total feasibility
  it is assumed that it is minimized
  Uses a SOLUTION_BUFFER to store solutions precomputed earlier
 """
function f(T,sol,roads,sim,reference_time, SOLUTION_BUFFER::Dict{Vector{Tuple{Int,Int}},Float64})
    chunks=Float64[]
    for i in 1:T
        spl=findall(x->x==i, sol)
        if length(spl) == 0
            push!(chunks,1)
        else
            #s=deepcopy(sim)
            push!(chunks,get_solution(sim,roads[spl],reference_time,1,SOLUTION_BUFFER))
        end
    end
    return chunks,maximum(chunks)
end
