#Function to measure minimum distance between roads
#returns NxN matrix of distances between N roads
function distances(map_data::MapData, roads::Vector{Tuple{Int,Int}})
    vert=collect(keys(map_data.v)) #list of vertices in the graph
    nodes=collect(values(map_data.v)) #list of nodes in the graph
    for d in 1:length(roads)
    for c in 1:length(roads)
    res=Float64[]
	#measure the distance between all pairs of points and take the minimum 
    for a in 1:2
        for b in 1:2
            vert1=vert[findfirst(isequal(roads[c][a]),nodes)]
            vert2=vert[findfirst(isequal(roads[d][b]),nodes)]
            push!(res,shortest_route(map_data,vert1,vert2)[2])
    end
    end
    densities[d,c]=minimum(res)
    end
    end
    return densities 
end

#calculates the average density of roadworks (distance between renovated roads in each batch) for T number of roadworks periods 
function density_check(opt::Tuple{Vector{Int64}, Float64, Int64}, T::Int64,densities::Array{Float64,2})
avg_density=Float64[]
    for i in 1:T
        batch=findall(isequal(i),opt[1]) #identifying each batch of roadworks
        leng=Float64[]
        #checking the average distance between roads in the batch
        for j in batch, k in batch
                push!(leng,(min(densities[k,j], densities[j,k])))
            end
        #n*(n-1)/2 pairs of distances
        if length(batch)>1
        Avg_dist=sum(leng)*2/(length(batch)*(length(batch)-1))
    else
        Avg_dist=0
    end
        push!(avg_density,Avg_dist)
end
#average roadworks density in all batches
return(mean(avg_density))
end

#function created for distributed sweep - optimizes the roadworks schedule and returns the solution quality and density of roadworks 
function loops(T::Int64,density::Array{Float64,2},roads::Vector{Tuple{Int64, Int64}}, sim::SimData, reference_time::Float64)
    ooo = @time opt(f, T, 1000, 0.001,roads, sim, reference_time)
    return ooo[2], density_check(ooo,T, density)
end
