roads #Vector of roads to remove
mx=map_data

#1. Sample roads to remove from the graph.
using PyCall
flm = pyimport("folium")
matplotlib_cm = pyimport("matplotlib.cm")
matplotlib_colors = pyimport("matplotlib.colors")
cmap = matplotlib_cm.get_cmap("prism")
m = flm.Map()
for j in 1:length(routes)
    locs = [LLA(mx.nodes[routes[j][i]],mx.bounds) for i=1:2]
  flm.PolyLine(        
        [(loc.lat, loc.lon) for loc in locs ],weight=10,
        color=matplotlib_colors.to_hex(cmap(j/length(routes)))       
    ).add_to(m)
end
MAP_BOUNDS = [(mx.bounds.min_y,mx.bounds.min_x),(mx.bounds.max_y,mx.bounds.max_x)]
flm.Rectangle(MAP_BOUNDS, color="black",weight=6).add_to(m)
m.fit_bounds(MAP_BOUNDS)
m

#2. Visualizing first solution (first algorithm) 
m = flm.Map()
for j in 1:10
    locs = [LLA(mx.nodes[res[1].best_solution[j][i]],mx.bounds) for i=1:2 ]
  flm.PolyLine(        
        [(loc.lat, loc.lon) for loc in locs ],weight=10,
        color=matplotlib_colors.to_hex(cmap(j/10))       
    ).add_to(m)
end
MAP_BOUNDS = [(mx.bounds.min_y,mx.bounds.min_x),(mx.bounds.max_y,mx.bounds.max_x)]
flm.Rectangle(MAP_BOUNDS, color="black",weight=6).add_to(m)
m.fit_bounds(MAP_BOUNDS)
m

#3. Visualizing second solution (second algorithm)
m = flm.Map()
for j in 1:length(routes)
    locs = [LLA(mx.nodes[res[2].best_solution[j][i]],mx.bounds) for i=1:2 ]
  flm.PolyLine(        
        [(loc.lat, loc.lon) for loc in locs ],weight=10,
        color=matplotlib_colors.to_hex(cmap(j/length(routes)))       
    ).add_to(m)
end
MAP_BOUNDS = [(mx.bounds.min_y,mx.bounds.min_x),(mx.bounds.max_y,mx.bounds.max_x)]
flm.Rectangle(MAP_BOUNDS, color="black",weight=6).add_to(m)
m.fit_bounds(MAP_BOUNDS)
m
