function plot_optimal_plan(mData::MapData, stats::SimStats, roads::Vector{Tuple{Int64,Int64}},opt_perm::Tuple{Array{Int64,1},Float64,Int64}=ooo; file_out="EdgeLoads.html")
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
        end
    end

    for i in 1:T
    spl=findall(x->x==i, opt_perm[1])
    for road in roads[spl]
        colix = stats.vehicle_load[road[1],road[2]]
        ss = [GetLLOfPoint2(mData,mData.n[road[i]]) for i in [1,2]]

        info =  "CLOSED From: Node $(road[1])\n<br>" *
                "To: Node $(road[2])\n<br>" *
                "Load: $(colix)\n<br>" *
                "Batch: $i"
        flm.PolyLine(ss, color=colors[i],popup=info,tooltip=info,
            weight=round(Int,log(21*colix))+5, opacity=1).add_to(m)
        for i in [1,2]
            info2 = "CLOSE NODE $(road[i]) <br> $info"
            flm.Circle(ss[i], color="black", radius=40,popup=info,tooltip=info).add_to(m)
        end
     end
    end

    MAP_BOUNDS = [(mData.bounds.min_y,mData.bounds.min_x),(mData.bounds.max_y,mData.bounds.max_x)]
    flm.Rectangle(MAP_BOUNDS, color="black",weight=6).add_to(m)
    m.fit_bounds(MAP_BOUNDS)
    m.save(file_out)
    m
end

function plot_random_plan(mData::MapData, stats::SimStats, roads::Vector{Tuple{Int64,Int64}}; file_out="EdgeLoads.html")
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
        end
    end

    for i in 1:T
    spl=findall(x->x==i, sol)
    for road in roads[spl]
        colix = stats.vehicle_load[road[1],road[2]]
        ss = [GetLLOfPoint2(mData,mData.n[road[i]]) for i in [1,2]]

        info =  "CLOSED From: Node $(road[1])\n<br>" *
                "To: Node $(road[2])\n<br>" *
                "Load: $(colix)\n<br>" *
                "Batch: $i"
        flm.PolyLine(ss, color=colors[i],popup=info,tooltip=info,
            weight=round(Int,log(21*colix))+5, opacity=1).add_to(m)
        for i in [1,2]
            info2 = "CLOSE NODE $(road[i]) <br> $info"
            flm.Circle(ss[i], color="black", radius=40,popup=info,tooltip=info).add_to(m)
        end
     end
    end

    MAP_BOUNDS = [(mData.bounds.min_y,mData.bounds.min_x),(mData.bounds.max_y,mData.bounds.max_x)]
    flm.Rectangle(MAP_BOUNDS, color="black",weight=6).add_to(m)
    m.fit_bounds(MAP_BOUNDS)
    m.save(file_out)
    m
end
