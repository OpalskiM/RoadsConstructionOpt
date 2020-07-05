vehicle_loads=deepcopy(stats.)

"""
Returns a list of `n` edges such as that the graph remains connected even after removing them
"""
function mostCongestedRoads(sim::SimData,vehicle_loads::AbstractMatrix, n::Int=30)::Vector{Tuple{Int,Int}}
    roads=Tuple{Int,Int}[]
    s=deepcopy(s)
    dict = Dict(((s.map_data.v[e[1]],s.map_data.v[e[2]]) =>vehicle_loads[s.map_data.v[e[1]],s.map_data.v[e[2]]]) for e in s.map_data.e)
    loads=sort(collect(dict), by = tuple -> last(tuple), rev = true)
    i = 1
    g = sim.g
    while i <= length(loads) && length(roads) < n
        e = loads[i][i]
        g2 = deepcopy(g)
        rem_edge!(g2,e[1],e[2])
        if is_strongly_connected(g2)
            push!(roads,e)
            g = g2
        end
        i += 1
    end
    roads
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
