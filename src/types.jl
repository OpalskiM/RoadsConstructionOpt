@with_kw mutable struct Agent
    start_node::Int64
   	fin_node::Int64
    route::Array{Tuple{Int64,Int64},1}
    current_edge::Int64
end

@with_kw struct SimData
    map_data::OpenStreetMapX.MapData
	driving_times::SparseArrays.SparseMatrixCSC{Float64,Int64}
	velocities::SparseArrays.SparseMatrixCSC{Float64,Int64}
	max_densities::SparseArrays.SparseMatrixCSC{Float64,Int64}
	population::Vector{Agent} = Agent[]
end

@with_kw struct Stats
	vehicle_load::SparseArrays.SparseMatrixCSC{Float64,Int64}
	avg_driving_times::SparseArrays.SparseMatrixCSC{Float64,Int64}
	actual_driving_times::SparseArrays.SparseMatrixCSC{Float64,Int64} #latest travel time on the edge.
end

Stats(m::Int,n::Int) = Stats(SparseArrays.spzeros(m, n), SparseArrays.spzeros(m, n),SparseArrays.spzeros(m, n))
