####Evolutionary algorithm to assess efect of new roads


#Steps:
#1. Simulation traffic for the existing network
#2. Adding randomly new roads and assessing traffic on improved road network
#3. Evolutionary changing the set of added road
#4. Goal: To minimize time spent in traffic for certain set of agents.

function EA2(objfun::Function=fitFunc, n::Int=n;
    initPopulation::Individual=Edges,
    lowerBounds::Union{Nothing, Vector} = nothing,
    upperBounds::Union{Nothing, Vector} = nothing,
    populationSize::Int = n,
    crossoverRate::Float64 = 0.6, #Example
    mutationRate::Float64 = 0.8, #Example
    e::Real = 1,
    selection::Function = roulette,
    crossover::Function = singlepoint,
    mutation::Function = insertion,
    iterations::Integer = n,
    tol::Float64 = 0.0 ,
    tolIter::Float64 = 10.0,
    map_data::MapData=map_data,
    sim_data::SimData=sim_data,
    verbose = true,
    debug = true,
    interim = true)
store = Dict{Symbol,Any}()
# Setup parameters
elite = isa(e, Int) ? e : round(Int, e    * populationSize)
objfun=fitFunc
# Initialize population
individual = getIndividual(initPopulation, n)
fitness = zeros(populationSize)
population = Array{typeof(individual)}(undef, populationSize)
offspring = similar(population)
#population
for i in 1:populationSize
if isa(initPopulation, Array)
    population[i] = initPopulation[i]
elseif isa(initPopulation, Matrix)
    population[i] = initPopulation[:, i]
elseif isa(initPopulation, Function)
    population[i] = initPopulation(n) # Creation function
else
    error("Cannot generate population")
end
end
#Changing_data (see: Changing_data.jl)
Initialization(m,sim_data)
  #
k8=[]
k9=[]
Edges=population
k7=[]
for i in 1:n
push!(k7,(M1[1,1][2],M2[1,1][2]))
end
for j in 1:max(n,Z)
k7[j]=[]
end
for j =1:n
for i in 1:Z
push!(k7[j],reverse(Edges[j][i]))
end
end
K7=k7[1:n]
#
for i in 1:n
push!(k8,(M1[1,1][2],M2[1,1][2]))
end
for j in 1:max(n,Z)
k8[j]=[]
end
for j =1:n
for i in 1:length(Edges[j])
push!(k8[j],(m.n[Edges[j][i][1]],m.n[Edges[j][i][2]]))
end
end
K8=k8[1:n]
#
for i in 1:n
push!(k9,(M1[1,1][2],M2[1,1][2]))
end
for j in 1:max(n,Z)
k9[j]=[]
end
for j =1:n
for i in 1:length(K8[j])
push!(k9[j],reverse(K8[j][i]))
end
end
K9=k9[1:n]
Edges=population
#
for i in 1:n
splice!(Edge2[i],1:length(Edge2[i]), K8[i])
splice!(Edge3[i],1:length(Edge3[i]), K9[i])
splice!(Edge4[i],1:length(Edge4[i]), K7[i])
end
#
for j=1:n
for i in 1:length(Edges[j])
    if !(Edges[j][i][1] == Edges[j][i][2])
        if  !issubset([Edge2[j][i]],m.e)
            push!(m2[j].e,Edge2[j][i])
push!(m2[j].e,Edge3[j][i])
add_edge!(m2[j].g,Edges[j][i])
add_edge!(m2[j].g,Edge4[j][i])
m2[j].w[Edges[j][i][1],Edges[j][i][2]]=get_distance(Edges[j][i][1],Edges[j][i][2],m.nodes,m.n)
m2[j].w[Edges[j][i][2],Edges[j][i][1]]=get_distance(Edges[j][i][1],Edges[j][i][2],m.nodes,m.n)
push!(m2[j].class,c[i])
push!(m2[j].class,c[i])
    end
    end
    end
end
#jah2(m2,l,sim_data1,sim_data2)

#function jah2(m2::Array{Any,1},l::Float64,sim_data1::SimData,sim_data2::Array{Any,1})
#    for  in 1:50
#    sim_data2[i]=get_sim_data2(m2[i],l,sim_data1)
#end
#end
###Changing sim_data for every solution
#Adding velocities and max_densities to sim_data

#sim_data2[1]=deepcopy(sim_data1)
#m2[1]=deepcopy(m1)

#sim_data2[1]=get_sim_data2(m2[1],l,sim_data1)

for j=1:n
for i=1:length(Edges[j])
sim_data2[j].velocities[Edges[j][i][1],Edges[j][i][2]] = 500 #ToDo:VariableVelocity
sim_data2[j].velocities[Edges[j][i][2],Edges[j][i][1]] = 500
sim_data2[j].max_densities[Edges[j][i][1],Edges[j][i][2]] = m2[j].w[Edges[j][i][1],Edges[j][i][2]]/l #ToDo:VariableVelocity
sim_data2[j].max_densities[Edges[j][i][2],Edges[j][i][1]] = m2[j].w[Edges[j][i][2],Edges[j][i][1]]/l
end
end

#run_simulation!(sim_data2[1],0.0,0.0,2,perturbed = false)

times = [] #Empty vector for results of simulation
#Simulating traffic for new data
for j in 1:n
push!(times, run_simulation!(sim_data2[j],0.0,0.0,2,perturbed = false)) #zmien iter
end
################
for i in 1:populationSize
fitness[i] = objfun(i)
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
    selected = selection(fitness, populationSize)
    # Perform mating
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
    end
        ####Changing_data
        m1=deepcopy(map_data)
        sim_data1=deepcopy(sim_data)
        m2=[deepcopy(m1),deepcopy(m1),deepcopy(m1),deepcopy(m1),deepcopy(m1)]
        sim_data2=[deepcopy(sim_data1),deepcopy(sim_data1),deepcopy(sim_data1),deepcopy(sim_data1),deepcopy(sim_data1)]
        k8=[]
        k9=[]
        Edges=population
        k7=[]
        for i in 1:Z
        push!(k7,(M1[i,1][2],M2[i,1][2]))
        end
        for j in 1:n
        k7[j]=[]
        end
        for j =1:n
        for i in 1:Z
        push!(k7[j],reverse(Edges[j][i]))
        end
        end
        K7=k7[1:n]
    for i in 1:Z
        push!(k8,(M1[i,1][2],M2[i,1][2]))
        end
        for j in 1:n
        k8[j]=[]
        end
        for j =1:n
        for i in 1:length(Edges[j])
        push!(k8[j],(m.n[Edges[j][i][1]],m.n[Edges[j][i][2]]))
        end
        end
        K8=k8[1:n]
        for i in 1:Z
        push!(k9,(M1[i,1][2],M2[i,1][2]))
        end
        for j in 1:n
        k9[j]=[]
        end
        for j =1:n
        for i in 1:length(K8[j])
        push!(k9[j],reverse(K8[j][i]))
        end
        end
        K9=k9[1:n]
        Edges=population
        #Replacing old edges with new ones for each solution n
        for i in 1:n
        splice!(Edge2[i],1:length(Edge2[i]), K8[i])
        splice!(Edge3[i],1:length(Edge3[i]), K9[i])
        splice!(Edge4[i],1:length(Edge4[i]), K7[i])
        end
        ###Changing data:
         for j=1:n
        for i in 1:length(Edges[j])
            if !(Edges[j][i][1] == Edges[j][i][2]) ##Checking if new edge consists of 2 different nodes
                if  !issubset([Edge2[j][i]],m.e) ##Checking if new edge does not exist yet
        push!(m2[j].e,Edge2[j][i]) #Adding edges to set of edges in MapData
        push!(m2[j].e,Edge3[j][i])
        add_edge!(m2[j].g,Edges[j][i])#Adding edges to graph m.g
        add_edge!(m2[j].g,Edge4[j][i])
        m2[j].w[Edges[j][i][1],Edges[j][i][2]]=get_distance(Edges[j][i][1],Edges[j][i][2],m.nodes,m.n) #Adding distances to distace matrix m.w
        m2[j].w[Edges[j][i][2],Edges[j][i][1]]=get_distance(Edges[j][i][1],Edges[j][i][2],m.nodes,m.n)
        push!(m2[j].class,c[i]) #Adding class for each road
        push!(m2[j].class,c[i])
            end
            end
            end
        end
        ###Changing sim_data for every solution
        for j=1:n
        for i=1:length(Edges[j])
        sim_data2[j].velocities[Edges[j][i][1],Edges[j][i][2]] = 500 #ToDo:VariableVelocity (At the moment fixed = 500)
        sim_data2[j].velocities[Edges[j][i][2],Edges[j][i][1]] = 500
        sim_data2[j].max_densities[Edges[j][i][1],Edges[j][i][2]] = m2[j].w[Edges[j][i][1],Edges[j][i][2]]/l #ToDo:VariableVelocity (Dependent of the velocity)
        sim_data2[j].max_densities[Edges[j][i][2],Edges[j][i][1]] = m2[j].w[Edges[j][i][2],Edges[j][i][1]]/l
        end
        end
        times = [] #Empty vector for results of simulation
        #Simulating traffic for new data
        for j in 1:n
        push!(times, run_simulation!(sim_data2[j],0.0,0.0,2,perturbed = false))
        end
        #####
    for i in 1:populationSize
        fitness[i] = fitFunc(i)
        debug && println("FIT $(i): $(fitness[i])")
    end
fitidx = sortperm(fitness, rev = true)
bestIndividual = fitidx[1]
curGenFitness = fitFunc(fitidx[1])
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
