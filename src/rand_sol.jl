#function to generate n random permutations of feasible solutions
#n - number of randomly generated solutions
#T - number of roadworks batches
function rand_perm(n::Int64,T::Int64,sim::SimData,z::Int=length(roads),roads::Array{Tuple{Int64,Int64},1}=roads, reference_time::Float64=reference_time,SOLUTION_BUFFER::Dict{Vector{Tuple{Int,Int}},Float64} = Dict{Vector{Tuple{Int,Int}},Float64}())
res=[]
for i in 1:n
sim_copy=deepcopy(sim)
sol = rand(1:T, z)
push!(res,f(T,sol,roads,sim_copy,reference_time, SOLUTION_BUFFER))
end
return res
end

#function to measure relative performance of random solutions 
function rand_sol(n::Int64,optimal_solution::Tuple{Array{Int64,1},Float64,Int64})
ran=rand_perm(n,T,sim2)
res=[]
for i in 1:n
    push!(res, ran[i][2])
end
return res
end
