mutable struct Agent
    start_node::Int64
    fin_node::Int64
    route::Array{Tuple{Int64,Int64},1}
    current_edge::Int64
end

mutable struct SimData
    map_data::OpenStreetMapX.MapData
	driving_times::SparseArrays.SparseMatrixCSC{Float64,Int64}
	velocities::SparseArrays.SparseMatrixCSC{Float64,Int64}
	max_densities::SparseArrays.SparseMatrixCSC{Float64,Int64}
	population::Vector{Agent}
end

mutable struct FlowData
    map_data::OpenStreetMapX.MapData
    DAs_to_intersection::Dict{Int64,Int64}
    demographic_data::Dict{Int64, Int64}
    flow_dictionary::Dict{Int64,Int64}
    flow_matrix::SparseArrays.SparseMatrixCSC{Int64,Int64}
end


mutable struct Stats
	delays::Array{Float64,1}
    cars_count::SparseArrays.SparseMatrixCSC{Float64,Int64}
    avg_driving_times::SparseArrays.SparseMatrixCSC{Float64,Int64}
end

