function GetLLOfPoint2(map::OpenStreetMapX.OSMData, mData::MapData,n::Int64)
    latitude = map.nodes[n].lat
    longitude = map.nodes[n].lon
    mypoint = (latitude,longitude)
end

function plot_edge_load(map::OpenStreetMapX.OSMData, mData::MapData, cars_per_edge)
    flm = pyimport("folium")
    matplotlib_cm = pyimport("matplotlib.cm")
    matplotlib_colors = pyimport("matplotlib.colors")
    cmap = matplotlib_cm.get_cmap("prism")
    m = flm.Map(tiles="Stamen Toner")
    for e in mData.e
        colix = cars_per_edge[map_data.v[e[1]],map_data.v[e[2]]]
        if !haskey(map.nodes, e[1]) || !haskey(map.nodes, e[2])
            continue
        end
        p1 = GetLLOfPoint2(mapa,mData,e[1])
        p2 = GetLLOfPoint2(mapa,mData,e[2])
        info =  "From: Node $(e[1])\n<br>" *
                "To: Node $(e[2])\n<br>" *
                "Load: $(colix)"
                if colix >0
        flm.PolyLine([p1,p2], popup=info,tooltip=info, weight=round(Int,log(21*colix))+1, opacity=1).add_to(m)
    #color="#$(hex(cols[colix]))"
end
    end
    MAP_BOUNDS = [(mData.bounds.min_y,mData.bounds.min_x),(mData.bounds.max_y,mData.bounds.max_x)]
    flm.Rectangle(MAP_BOUNDS, color="black",weight=6).add_to(m)
    m.fit_bounds(MAP_BOUNDS)
    m.save("EdgeLoads.html")
    m
end
