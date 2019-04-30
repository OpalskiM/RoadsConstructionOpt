#Updating attributes of new roads:
#Graph edges
#Distances matrix
#road class
#road max density
#road velocity

mapdata=OpenStreetMapX.parseOSM(joinpath(pth,name))
n=mapdata
map_data =  OpenStreetMapX.get_map_data(pth,name,use_cache = false);
m=map_data

const SPEEDS = Dict{Int,Float64}(
    1 => 100,    # Motorway
    2 => 90,    # Trunk
    3 => 90,    # Primary
    4 => 70,    # Secondary
    5 => 50,    # Tertiary
    6 => 40,    # Residential/Unclassified
    7 => 20,     # Service
    8 => 10)     # Living street
include("evolution_roads.jl")

    m1=[deepcopy(m),deepcopy(m),deepcopy(m),deepcopy(m),deepcopy(m)] #5 New solutions - ToDo:Change numbers of solutions
    sim_data1=[deepcopy(sim_data),deepcopy(sim_data),deepcopy(sim_data),deepcopy(sim_data),deepcopy(sim_data)] #To do - change number of solutions
    for j=1:5
       m1[j]
    sim_data1[j]
    end
    function update(a::Array{Any,1},b::Array{Any,1},c::Array{Int64,2},d::Array{Any,1},class_speeds::Dict{Int,Float64} = SPEEDS)
            for j=1:5
                for i=1:10
            push!(m1[j].e,a[j][i])
            push!(ololol[j].e,d[j][i])
            m1[j].w[b[j][i][1],b[j][i][2]]=get_distance(b[j][i][1],b[j][i][2],m.nodes,m.n)
            m1[j].w[b[j][i][2],b[j][i][1]]=get_distance(b[j][i][1],b[j][i][2],m.nodes,m.n)
            push!(m1[j].class,c[i])
            push!(m1[j].class,c[i]) #can be combined together
        sim_data1[j].velocities[b[j][i][1],b[j][i][2]] = 5 #ToDo:VariableVelocity (At the moment fixed = 5)
            sim_data1[j].velocities[b[j][i][2],b[j][i][1]] = 5
            sim_data1[j].max_densities[b[j][i][1],b[j][i][2]] = m1[j].w[b[j][i][1],b[j][i][2]]/l #ToDo:VariableVelocity (Dependent of the velocity)
            sim_data1[j].max_densities[b[j][i][2],b[j][i][1]] = m1[j].w[b[j][i][2],b[j][i][1]]/l
        end
        end
        end
    update(K2,K,c)
#K2 - vector of edges (number - OSM data)
#K - Vector of edges (numbered 1...n)
#c - Vector of road classes
