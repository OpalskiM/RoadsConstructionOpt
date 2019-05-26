sim_time = run_simulation!(sim_data,1.0,1.0,iter,perturbed = true)
g = remove_edges(map_data, sol[1])
          for agent in sim_data.population
              agent.route = new_graph_routing(map_data,g,map_data.w,m.n[agent.start_node],m.n[agent.fin_node])
          end
              simulation_time = run_simulation!(sim_data,1.0,1.0,iter,perturbed = true)
relative_difference = (sim_time-simulation_time)/sim_time *100
println("relative % time difference","=", relative_difference) 
