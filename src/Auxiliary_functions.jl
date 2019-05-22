using Random

#1. Counting Visits
m=map_data
routes = Vector{Array{Tuple{Int64,Int64},1}}()
visits = Dict{Int,Int}() #TO BEZ ZMIAN
for i in 1:length(sim_data.population)
route = sim_data.population[i].route
push!(routes,route)
end

#2. Measuring traffic volume on edges
routes2=[]
for j = 1:length(routes)
for i in 1:length(routes[j])
push!(routes2,routes[j][i])
end
end
Edg = unique(routes2)
Traff=Dict([(i,count(x->x==i,routes2)) for i in Edg])

#3. Probability of the edge to be included in the solution
function roulette2(fitness::Array{Any,1}, N::Int)
prob = fitness./sum(fitness)
return pselection(prob, N)
end

Traff2 =[]
Traff2 =collect(values(Traff))
Traff3=[]
sum(values(Traff))
for i in 1:length(Traff2)
push!(Traff3,Traff2[i]/sum(values(Traff)))
end
roulette2(Traff3,1)[1]

#4. Drawing Edges
Keys =collect(keys(Traff))
Dr_Edge=Keys[roulette2(Traff3,1)[1]] #- wylosowana krawedz

#5. Randomly choosing n solutions (each consists of Z roads)
m=map_data
sol=[]
for i in 1:max(Z,n)
  push!(sol,m.e[1])
end

for i in 1:n
  sol[i]=[]
end
for i in 1:n
  for j in 1:Z
      push!(sol[i], Keys[roulette2(Traff3,1)[1]])
  end
end


function remove_edges(m::OpenStreetMapX.MapData,edgelist::Array{Tuple{Int,Int}})
g = deepcopy(m.g)
for edge in edgelist
  rem_edge!(g, map_data.v[edge[1]],map_data.v[edge[2]])
end
g
end

function remove_edges3(m::OpenStreetMapX.MapData,edgelist::Array{Any,1})
g = deepcopy(m.g)
  for edge in edgelist
      rem_edge!(g,edge[1],edge[2])
  end
  g
end

function new_graph_routing5(m::OpenStreetMapX.MapData,
                      g::LightGraphs.SimpleDiGraph{Int64},
                      w::SparseArrays.SparseMatrixCSC{Float64,Int64},
                      node0::Int, node1::Int)
heuristic(u,v) = OpenStreetMapX.get_distance(u, v, m.nodes, m.n)
route_indices, route_values = a_star_algorithm(g, map_data.v[node0], map_data.v[node1], w, heuristic)
[(route_indices[j - 1],route_indices[j]) for j = 2:length(route_indices)]
end
