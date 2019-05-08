#Generating initial (random) to add to simulation processes

#At the moment random
map_data =  OpenStreetMapX.get_map_data(pth,name,road_levels=Set(1:6),use_cache = false);
    m=map_data

    n=50
    Z=20
    #Randomly choosing n solutions (each consists of Z roads)
    using Random
    M1=rand(m.n,Z,n)
    M2=rand(m.n,Z,n)
    A=collect(keys(m.n))
    #Generating initial arrays:


edge=[]
edge2=[]
edge3=[]
edge4=[]
    #edge - arrays of edges (m.n)
#    edge=[]
        for i in 1:n
            push!(edge,(M1[1,1][1],M2[1,1][1]))
        end
        for j in 1:n
        edge[j]=[]
        end
        for j =1:n
        for i in 1:Z
            push!(edge[j],(M1[i,j][1],M2[i,j][1]))
        end
        end
        Edges = edge[1:n]
        #Arrays of edges2 (m.v)
    #    edge2=[]
        for i in 1:n
            push!(edge2,(M1[1,1][2],M2[1,1][2]))
        end
        for j in 1:n
            edge2[j]=[]
        end
        for j =1:n
        for i in 1:Z
            push!(edge2[j],(M1[i,j][2],M2[i,j][2]))
        end
        end
    Edge2=edge2[1:n]
        #Edge3 - reversed Edge2 (to make sure road is two - way)
    #edge3=[]
    for i in 1:n
    push!(edge3,(M1[1,1][2],M2[1,1][2]))
    end
    for j in 1:n
    edge3[j]=[]
    end
    for j =1:n
    for i in 1:Z
    push!(edge3[j],reverse(Edge2[j][i]))
    end
    end
    # edge4 - reversed edge
    Edges=edge[1:n] #K=population
#    edge4=[]
    for i in 1:n
    push!(edge4,(M1[1,1][2],M2[1,1][2]))
    end
    for j in 1:n
        edge4[j]=[]
    end
    for j =1:n
    for i in 1:Z
    push!(edge4[j],reverse(Edges[j][i]))
    end
    end
    Edge4=edge4[1:n]
    #C - array of new roads classess (at the moment fixed = 4 class)
    c=zeros(Int64,Z,1)
    for i in 1:Z
        c[i]=4
    end
    #Initial population of edges and distances
        Edges=edge[1:n]
        Edge2=edge2[1:n]
        Edge3=edge3[1:n]
        Edge4=edge4[1:n]
