###Functions needed to perform evolutionary algorithm

    const Individual = Union{Vector, Matrix, Function, Nothing}
# Selection
    function pselection(prob::Vector{Float64}, N::Int)
        cp = cumsum(prob)
        selected = Array{Int}(undef, N)
        for i in 1:N
            j = 1
            r = rand()
            while cp[j] < r
                j += 1
            end
            selected[i] = j
        end
        return selected
    end

    #selection - roulette
    function roulette(fitness::Vector{Float64}, N::Int)
        prob = fitness./sum(fitness)
        return pselection(prob, N)
    end

    function vswap!(v1::T, v2::T, idx::Int) where {T <: Vector}
        val = v1[idx]
        v1[idx] = v2[idx]
        v2[idx] = val
    end

    #Crossover - singlepoint
    function singlepoint(v1::T, v2::T) where {T <: Vector}
        l = length(v1)
        c1 = copy(v1)
        c2 = copy(v2)
        pos = rand(1:l)
        for i in pos:l
            vswap!(c1, c2, i)
        end
        return c1, c2
    end

    # Obtain individual
        function getIndividual(init::Individual, N::Int)
            if isa(init, Vector)
                @assert length(init) == N "Dimensionality of initial population must be $(N)"
                individual = init
            elseif isa(init, Matrix)
                @assert size(init, 1) == N "Dimensionality of initial population must be $(N)"
                populationSize = size(init, 2)
                individual = init[:, 1]
            elseif isa(init, Function) # Creation function
                individual = init(N)
            else
                individual = ones(N)
            end
            return  individual
        end

    #function keep
    function keep(interim, v, vv, col)
        if interim
            if !haskey(col, v)
                col[v] = typeof(vv)[]
            end
            push!(col[v], vv)
        end
    end

    #mutation - insertion
    #Randomly replaced road to make sure all set of possibilites is considered
    function insertion(recombinant::T) where {T <: Vector}
        l = length(recombinant)
        from, to = rand(1:l, 2)
        val = (rand(m.n)[1],rand(m.n)[1])
        deleteat!(recombinant, from)
        return insert!(recombinant, to, val)
    end

    function swap!(v::T, from::Int, to::Int) where {T <: Vector}
    val = v[from]
    v[from] = v[to]
    v[to] = val
    end

    #Deepcopy of initial sim_data
    sim_data1 = deepcopy(sim_data)
    
    #Getting new sim_data (for new graph and map(MapData))
    #Taking the same set of agents (to compare results)
function get_sim_data2(m::MapData,
    l::Float64,sim_data::SimData,
    speeds = OpenStreetMapX.SPEED_ROADS_URBAN)::SimData
driving_times = driving_times = OpenStreetMapX.create_weights_matrix(m, OpenStreetMapX.network_travel_times(m, speeds))
velocities = OpenStreetMapX.get_velocities(m, speeds)
max_densities = get_max_densities(m, l)
agents = sim_data1.population
for agent in agents
    agent.route = get_route(m,m.w,agent.start_node,agent.fin_node)
end
return SimData(m, driving_times, velocities, max_densities, agents)
end

const SPEED_ROADS_URBAN = Dict{Int,Float64}(
1 => 100,    # Motorway
2 => 90,    # Trunk
3 => 90,    # Primary
4 => 70,    # Secondary
5 => 50,    # Tertiary
6 => 40,    # Residential/Unclassified
7 => 20,     # Service
8 => 10)     # Living street

#Value of time
#Considering 22$ for hour (== 22/1440 per second)
VoT =22/1440

#time - total output of initial road network
time_in=run_simulation!(sim_data,0.0,0.0,iter,perturbed=false)

###Function evaluating improvement of new network
#At the moment only assessing imrprovement in terms of time (ToDo: Add some costs)
function fitFunc(i)
    (time_in -  times[i]) * VoT
    end
    