s=deepcopy(sim)
vehicle_loads=deepcopy(stats.vehicle_load)

#1. Checking if the graph is stricly connected
spawn_points = sort(LightGraphs.strongly_connected_components(s.map_data.g),
        lt=(x,y)->length(x)<length(y), rev=true)[1]
    spawn_points_set = Set(spawn_points)
    for e in collect(LightGraphs.edges(s.map_data.g))
        if (!(e.src in spawn_points_set) || !(e.dst in spawn_points_set))
            LightGraphs.rem_edge!(s.map_data.g, e)
        end
    end

#2. Choosing the indices of 30 most congested roads (Creating a dictionary from the sparse array and sorting)
dict = Dict(((s.map_data.v[e[1]],s.map_data.v[e[2]]) =>vehicle_loads[s.map_data.v[e[1]],s.map_data.v[e[2]]]) for e in s.map_data.e)
loads=sort(collect(dict), by = tuple -> last(tuple), rev = true)[1:30]
roads=[]
for i in 1:length(loads)
push!(roads,loads[i][1])
end
roads

#3.Removing roads from the graph.
s.map_data.g
for e in collect(roads)
   if((e[1][1] in spawn_points_set)) ||((e[1][2] in spawn_points_set))
        LightGraphs.rem_edge!(s.map_data.g,e[1],e[2])
println("edge removed")
else
   println("not")
    end
end

#4. Altered function to plot roads (removed edges colored green)
function plot_edge_load_removed(mData::MapData, stats::Stats, roads::Array{Any,1})
    flm = pyimport("folium")
    matplotlib_cm = pyimport("matplotlib.cm")
    matplotlib_colors = pyimport("matplotlib.colors")
    cmap = matplotlib_cm.get_cmap("prism")
    m = flm.Map(tiles="Stamen Toner")

    max_count = maximum(stats.vehicle_load)
    min_count = max(1,minimum(stats.vehicle_load))
    cc = max_count - min_count + 1
    cols = reshape( range(colorant"blue", stop=colorant"red",length=cc), 1, cc);

    for e in mData.e
        if !haskey(mData.nodes, e[1]) || !haskey(mData.nodes, e[2])
            continue
        end
        colix = stats.vehicle_load[mData.v[e[1]],mData.v[e[2]]]
        p1 = GetLLOfPoint2(mData,e[1])
        p2 = GetLLOfPoint2(mData,e[2])
        info =  "From: Node $(e[1])\n<br>" *
                "To: Node $(e[2])\n<br>" *
                "Load: $(colix)"
        if colix >0
            flm.PolyLine([p1,p2], popup=info,tooltip=info, color="#$(hex(cols[colix]))",
               weight=round(Int,log(21*colix))+1, opacity=1).add_to(m)
       ###Adding green roads from the set of removed edges
       for road in roads
        s1 = GetLLOfPoint2(mData,mData.n[road[1]])
        s2 = GetLLOfPoint2(mData,mData.n[road[2]])
         flm.PolyLine([s1,s2], color="green",
               weight=round(Int,log(21*colix))+3, opacity=1).add_to(m)
        end
        end
    end
    MAP_BOUNDS = [(mData.bounds.min_y,mData.bounds.min_x),(mData.bounds.max_y,mData.bounds.max_x)]
    flm.Rectangle(MAP_BOUNDS, color="black",weight=6).add_to(m)
    m.fit_bounds(MAP_BOUNDS)
    m.save("EdgeLoads.html")
    m
end

