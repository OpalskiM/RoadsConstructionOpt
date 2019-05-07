###Changing data (adding data to map and graph) and traffic simulation for new data

###
#Creating environment for new data(new roads)

#Creating n copies of initial data to modify it
#1) Inicjalizacja
m=map_data
sim_data=sim_data
m2=[]
sim_data2=[]
function Initialization(m::MapData,sim_data::SimData)
for i in 1:n
push!(m2,deepcopy(m))
push!(sim_data2,deepcopy(sim_data))
end
for j in 1:n
m2[j]=deepcopy(m)
sim_data2[j]=deepcopy(m)
end
for i in 1:n
    m2[i]=deepcopy(m)
    sim_data2[i]=deepcopy(m)
end
for i in 1:n
    m2[i]=deepcopy(m)
    sim_data2[i] = deepcopy(sim_data)
end
end

#2) Powrot do stanu wyjsciowego
function Come_back(m::MapData,sim_data::SimData)
    for i in 1:n
        m2[i]=deepcopy(m)
        sim_data2[i] = deepcopy(sim_data)
    end
    end
#Creating new arrays of edges for each solution n
k8=[]
k9=[]
Edge=population
k7=[]

for i in 1:Z
push!(k7,(M1[i,1][2],M2[i,1][2]))
end
for j in 1:n
k7[j]=[]
end
for j =1:n
for i in 1:Z
push!(k7[j],reverse(Edge[j][i]))
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
for i in 1:length(Edge[j])
push!(k8[j],(m.n[Edge[j][i][1]],m.n[Edge[j][i][2]]))
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

Edge=population
#Replacing old edges with new ones for each solution n
for i in 1:n
splice!(Edge2[i],1:length(Edge2[i]), K8[i])
splice!(Edge3[i],1:length(Edge3[i]), K9[i])
splice!(Edge4[i],1:length(Edge4[i]), K7[i])
end

###Changing data, graph:
#Adding edges to map_data and graph
#Adding distances to distace_matrix
#Adding classes for each road
for j=1:n
for i in 1:length(Edge[j])
    if !(Edge[j][i][1] == Edge[j][i][2]) ##Checking if new edge consists of 2 different nodes
        if  !issubset([Edge2[j][i]],m.e) ##Checking if new edge does not exist yet
push!(m2[j].e,Edge2[j][i]) #Adding edges to set of edges in MapData
push!(m2[j].e,Edge3[j][i])
add_edge!(m2[j].g,Edge[j][i])#Adding edges to graph m.g
add_edge!(m2[j].g,Edge4[j][i])
m2[j].w[Edge[j][i][1],Edge[j][i][2]]=get_distance(Edge[j][i][1],Edge[j][i][2],m.nodes,m.n) #Adding distances to distace matrix m.w
m2[j].w[Edge[j][i][2],Edge[j][i][1]]=get_distance(Edge[j][i][1],Edge[j][i][2],m.nodes,m.n)
push!(m2[j].class,c[i]) #Adding class for each road
push!(m2[j].class,c[i])
    end
    end
    end
end


###Changing sim_data for every solution
for j=1:n
for i=1:length(Edge[j])
sim_data2[j].velocities[Edge[j][i][1],Edge[j][i][2]] = 500 #ToDo:VariableVelocity (At the moment fixed = 500)
sim_data2[j].velocities[Edge[j][i][2],Edge[j][i][1]] = 500
sim_data2[j].max_densities[Edge[j][i][1],Edge[j][i][2]] = m2[j].w[Edge[j][i][1],Edge[j][i][2]]/l #ToDo:VariableVelocity (Dependent of the velocity)
sim_data2[j].max_densities[Edge[j][i][2],Edge[j][i][1]] = m2[j].w[Edge[j][i][2],Edge[j][i][1]]/l
end
end
times = [] #Empty vector for results of simulation

#Simulating traffic for new data
for j in 1:n
push!(times, run_simulation!(sim_data2[j],0.0,0.0,2,perturbed = false))
end
