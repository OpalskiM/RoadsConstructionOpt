#Algorithm of adding a set of new roads
#inspired by evolutionary.jl and modified

using OpenStreetMapX
pth = "C:/RoadsConstructionOpt/Roboczy/"
name = "mapatest2.osm"
map_data =  OpenStreetMapX.get_map_data(pth,name,use_cache = false);
#Generating example data
#Considering 5 solutions, each of 10 roads.
#Gain of adding each new road = 2000
#Cost of adding each new road = distance between nodes 
m=map_data
   m1=rand(m.n,10,N)
   m2=rand(m.n,10,N)
   A=collect(keys(m.n))
    N=5
       k=[]
       for i in 1:10
          push!(k,(m1[i,1][1],m2[i,1][1]))
       end

       for j in 1:N
       k[j]=[]
       end

       for j =1:N
       for i in 1:10
          push!(k[j],(m1[i,j][1],m2[i,j][1]))
       end
    end

      d=[]
      for i in 1:10
         push!(d,get_distance(k[1][i][1],k[1][i][2], m.nodes,m.n))
      end


      for j=1:N
      d[j]=[]
      end

      for j =1:N
      for i in 1:10
         push!(d[j],get_distance(k[j][i][1],k[j][i][2], m.nodes,m.n))
      end
      end

      g=[]
      for i in 1:10
         push!(g,2000)
      end

      for j=1:N
      g[j]=[]
      end

      for j =1:N
      for i in 1:10
         push!(g[j],2000)
      end
      end
      #initial population
      K=k[1:N]
      D=d[1:N]
      G=g[1:N]

     #Example fitness Function
     #At the moment - fixed gain(for each road set Gain=2000) and costs (=distance between nodes)
     #ToDo: Incorporate OSM features
function fitFunc(population,i)
   gain * length(population[i])-sum(get_distance(population[i][j][1],population[i][j][2],m.nodes,m.n) for j=1:10)
end

Auxilliary:
const Individual = Union{Vector, Matrix, Function, Nothing}
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

#selection roulette (example)
#ToDo:Change mechanism of selection
function roulette(fitness::Vector{Float64}, N::Int)
    prob = fitness./sum(fitness)
    return pselection(prob, N)
end

function vswap!(v1::T, v2::T, idx::Int) where {T <: Vector}
    val = v1[idx]
    v1[idx] = v2[idx]
    v2[idx] = val
end

#crossover mechanism (example)
#ToDo: Change mechanism of crossover
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

function keep(interim, v, vv, col)
       if interim
           if !haskey(col, v)
               col[v] = typeof(vv)[]
           end
           push!(col[v], vv)
       end
   end

   function swap!(v::T, from::Int, to::Int) where {T <: Vector}
   val = v[from]
   v[from] = v[to]
   v[to] = val
   end

   function inversion(recombinant::T) where {T <: Vector}
       l = length(recombinant)
       from, to = rand(1:l, 2)
       from, to = from > to ? (to, from)  : (from, to)
       l = round(Int,(to - from)/2)
       for i in 0:(l-1)
           swap!(recombinant, from+i, to-i)
       end
       return recombinant
   end


   function ga(objfun::Function=fitFunc, N::Int=5;
               initPopulation::Individual=K,
               lowerBounds::Union{Nothing, Vector} = nothing,
               upperBounds::Union{Nothing, Vector} = nothing,
               populationSize::Int = 5,
               crossoverRate::Float64 = 0.6,
               mutationRate::Float64 = 0.2,
               ɛ::Real = 1,
               selection::Function = roulette,
               crossover::Function = singlepoint,
               mutation::Function = inversion,
               iterations::Integer = N,
               tol::Float64 = 0.0 ,
               tolIter::Float64 = 10.0,
               verbose = true,
               debug = true,
               interim = true)
       store = Dict{Symbol,Any}()
       # Setup parameters
       elite = isa(ɛ, Int) ? ɛ : round(Int, ɛ * populationSize)
       # Initialize population
       individual = getIndividual(initPopulation, N)
       fitness = zeros(populationSize)
       population = Array{typeof(individual)}(undef, populationSize)
       offspring = similar(population)
   #population
       for i in 1:populationSize
           if isa(initPopulation, Array)
               population[i] = initPopulation[i]
           else
               error("Cannot generate population")
          end
           fitness[i] = fitFunc(population,i)
       end
       fitidx = sortperm(fitness, rev = true)
       println(fitidx)
       keep(interim, :fitness, copy(fitness), store)
       # Generate and evaluate offspring
       itr = 1
       bestFitness = 0.0
       bestIndividual = 0
       fittol = 0.0
       fittolitr = 1
       while true
           debug && println("BEST: $(fitidx)")
           #choosing selection
           selected = selection(fitness, populationSize)
           # Perform mating
           #crossover=singlepoint
           offidx = randperm(populationSize)
           for i in 1:2:populationSize
               j = (i == populationSize) ? i-1 : i+1
               if rand() < crossoverRate
                   debug && println("MATE $(offidx[i])+$(offidx[j])>: $(population[selected[offidx[i]]]) : $(population[selected[offidx[j]]])")
                   offspring[i], offspring[j] = crossover(population[selected[offidx[i]]], population[selected[offidx[j]]])
                   debug && println("MATE >$(offidx[i])+$(offidx[j]): $(offspring[i]) : $(offspring[j])")
               else
                   offspring[i], offspring[j] = population[selected[i]], population[selected[j]]
               end
           end
           # Perform mutation
           for i in 1:populationSize
               if rand() < mutationRate
                   debug && println("MUTATED $(i)>: $(offspring[i])")
                   mutation(offspring[i])
                   debug && println("MUTATED >$(i): $(offspring[i])")
               end
           end
           # Elitism
           if elite > 0
               for i in 1:elite
                   subs = rand(1:populationSize)
                   debug && println("ELITE $(fitidx[i])=>$(subs): $(population[fitidx[i]]) => $(offspring[subs])")
                   offspring[subs] = population[fitidx[i]]
               end
           end
           # New generation
           for i in 1:populationSize
               population[i] = offspring[i]
               fitness[i] = fitFunc(population,i)
               debug && println("FIT $(i): $(fitness[i])")
           end
           fitidx = sortperm(fitness, rev = true)
           bestIndividual = fitidx[1]
           curGenFitness = objfun(bestIndividual)
           fittol = abs(bestFitness - curGenFitness)
           bestFitness = curGenFitness
           keep(interim, :fitness, copy(fitness), store)
           keep(interim, :bestFitness, bestFitness, store)
           # Verbose step
           verbose &&  println("BEST: $(bestFitness): $(population[bestIndividual]), G: $(itr)")
           # Terminate:
           #  if fitness tolerance is met for specified number of steps
           if fittol < tol
               if fittolitr > tolIter
                   break
               else
                   fittolitr += 1
               end
           else
               fittolitr = 1
           end
           # if number of iterations more then specified
           if itr >= iterations
               break
           end
           itr += 1
       end
       return population[bestIndividual], bestFitness, itr, fittol, store
   end
