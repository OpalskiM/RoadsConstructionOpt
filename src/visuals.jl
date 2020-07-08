function GetLLOfPoint2(mData::MapData,n::Int64)
    point = LLA(mData.nodes[n],mData.bounds)
    mypoint = (point.lat,point.lon)
end

function plot_edge_load(mData::MapData, stats::Stats; out_file="EdgeLoads.html")
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
    MAP_BOUNDS = [(mData.bounds.min_y,mData.bounds.min_x),(mData.bounds.max_y,mData.bounds.max_x)]
    flm.Rectangle(MAP_BOUNDS, color="black",weight=6).add_to(m)
    m.fit_bounds(MAP_BOUNDS)
    m.save(out_file)
    m
end
