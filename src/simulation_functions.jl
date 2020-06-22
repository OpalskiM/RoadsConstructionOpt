function get_velocities(m::OpenStreetMapX.MapData,
            class_speeds::Dict{Int,Float64} = OpenStreetMapX.SPEED_ROADS_URBAN)
    @assert length(m.e) == length(m.w.nzval)
    indices = [(m.v[i],m.v[j]) for (i,j) in m.e]
    V = SparseArrays.spzeros(length(m.v), length(m.v))
    for (i,ind) in enumerate(indices)
        V[ind[1],ind[2]] = class_speeds[m.class[i]]/3.6
    end
    V
end

function get_max_densities(m::MapData,
                            vehicle_len::Float64)
    roadways_lanes = Dict{Int64,Int64}()
    for roadway in m.roadways
        if !OpenStreetMapX.haslanes(roadway)
            lanes = 1
        else
            lanes = OpenStreetMapX.getlanes(roadway)
        end
        roadways_lanes[roadway.id] = lanes
    end
    segments = OpenStreetMapX.find_segments(m.nodes,m.roadways,m.intersections)
    segments = Dict((m.v[segment.node0],m.v[segment.node1]) => roadways_lanes[segment.parent] for segment in segments)
    lanes_matrix = SparseArrays.sparse(
		map(x->getfield.(collect(keys(segments)), x), fieldnames(eltype(collect(keys(segments)))))...,
		collect(values(segments)),
		length(m.v),length(m.v))
    return m.w .* lanes_matrix / vehicle_len
end

function get_nodes(m::MapData)
    start_node, fin_node = 0, 0
    while start_node == fin_node
        start_node = m.v[OpenStreetMapX.point_to_nodes(OpenStreetMapX.generate_point_in_bounds(m), m)]
        fin_node = m.v[OpenStreetMapX.point_to_nodes(OpenStreetMapX.generate_point_in_bounds(m), m)]
    end
    return start_node,fin_node
end

function get_route(m::OpenStreetMapX.MapData, w::AbstractMatrix{Float64}, node0::Int64,  node1::Int64)
    f(x, B = agent.fin_node, nodes = m.nodes, vertices = m.n) = OpenStreetMapX.get_distance(x,B,nodes,vertices)/(maximum(values(OpenStreetMapX.SPEED_ROADS_URBAN))/3.6)
    route_indices, route_values = OpenStreetMapX.a_star_algorithm(m.g, node0, node1, w, f)
	[(route_indices[j - 1],route_indices[j]) for j = 2:length(route_indices)]
end

"""
calculate_driving_time(n_e::Float64,N_e::Float64,d::Float64,V_max::Float64, V_min::Float64 = 1.0)
**Arguments**
* `n_e`        		    : number of agents at edge e
* `N_e`  	            : capacity of edge e
* `d`             	    : length of edge e
* `V_max`               : maximum commuter's velocity at en edge e
* `v_min`               : minimum commuter's velocity at en edge e
"""

function calculate_driving_time(n_e::Float64,
                                N_e::Float64,
                                d::Float64,
                                V_max::Float64,
                                V_min::Float64 = 1.0)
    v = (V_max - V_min)* max((1 - n_e/N_e),0.0) + V_min
    return d/v
end

function create_agents(m::MapData,
                        w::SparseArrays.SparseMatrixCSC{Float64,Int64},
                        N::Int64)::Vector{Agent}
    buffer = Dict{Tuple{Int64,Int64}, Vector{Agent}}()
    nodes_list = Tuple{Int64,Int64}[]
    for i = 1:N
        nodes = get_nodes(m)
        if i % 2000 == 0
            @info "$i agents created"
        end
		# TODO when agents are created buffer is empty
		# TODO the buffe is not needed at all - we are using actual_driving_times instead!
		# TODO henece all this code should be reedited
        if !haskey(buffer,nodes)
            route = get_route(m, w, nodes[1], nodes[2])
            agent = Agent(nodes[1], nodes[2],
                            route,
                            1)
            buffer[nodes] = [agent]
            push!(nodes_list,nodes)
        else
            push!(buffer[nodes],deepcopy(buffer[nodes][1]))
        end
    end
    return reduce(vcat,[buffer[k] for k in nodes_list])
end

function get_sim(m::MapData, p::ModelSettings, speeds = OpenStreetMapX.SPEED_ROADS_URBAN)::SimData
	velocities = get_velocities(m, speeds)
	max_densities = get_max_densities(m, p.vehicle_len)
	a, b = size(m.w)
	driving_times=SparseArrays.spzeros(a,b)
for edge in m.e
  driving_times[m.v[edge[1]],m.v[edge[2]]] = calculate_driving_time(0, max_densities[m.v[edge[1]],m.v[edge[2]]],map_data.w[m.v[edge[1]],m.v[edge[2]]],velocities[m.v[edge[1]],m.v[edge[2]]])
   end
    agents = create_agents(m, driving_times,p.N)
    return SimData(m, driving_times, velocities, max_densities, agents)
end


function update_stats!(stats::Stats, edge0::Int, edge1::Int)
    stats.vehicle_load[edge0, edge1] += 1.0
    stats.actual_driving_times[edge0,edge1] = calculate_driving_time(stats.vehicle_load[edge0,edge1],sim.max_densities[edge0,edge1],sim.map_data.w[edge0,edge1],sim.velocities[edge0,edge1])
    stats.simulation_total_time += stats.actual_driving_times[edge0,edge1] 
end
