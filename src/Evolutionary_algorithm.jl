
#time_in - simulation time for existing network (benchmark)
time_in=run_simulation!(sim_data,1.0,1.0,iter,perturbed=false)
#      time_in=run_simulation!(sim_data,1.0,1.0,iter,perturbed=true)

      Sol = sol[1:n]
      times = []
      function Evolutionary_algorithm(objfun::Function,iterations::Integer,
          crossoverRate::Float64,
          mutationRate::Float64,
          n::Int=n,
          initPopulation::Individual=Sol,
          populationSize::Int = n,
          e::Real = 0.2,
          selection::Function = roulette,
          crossover::Function = twopoint,
          mutation::Function = insertion,
          tol::Float64 = 0.0 ,
          tolIter::Float64 = 10.0,
          map_data::MapData=map_data,
          m::MapData = map_data,
          sim_data::SimData=sim_data,
          verbose = true,
          debug = true,
          interim = true)
      store = Dict{Symbol,Any}()
      # Setup parameters
      elite = isa(e, Int) ? e : round(Int, e    * populationSize)
      objfun=fitFunc
      time_in=run_simulation!(sim_data,1.0,1.0,iter,perturbed = false)
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
      else
          error("Cannot generate population")
      end
      end
      #Changing_data
      m1 = deepcopy(m)
          for i in 1:n
          m1 = deepcopy(map_data)
          g = remove_edges(m1, sol[i])
          for agent in sim_data.population
              agent.route = new_graph_routing(map_data,g,map_data.w,m.n[agent.start_node],m.n[agent.fin_node])
          end
              simulation_time = run_simulation!(sim_data,1.0,1.0,iter,perturbed = false)
              push!(times,simulation_time)
          end
          #Simulating traffic for new data
      for i in 1:populationSize
      fitness[i] = objfun(time_in,i)
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
      m1 = deepcopy(map_data)
      times=[]
      for i in 1:n
          m1 = deepcopy(map_data)
          g = remove_edges(m1, population[i])
          for agent in sim_data.population
              agent.route = new_graph_routing(map_data,g,map_data.w,m.n[agent.start_node],m.n[agent.fin_node])
          end
              simulation_time = run_simulation!(sim_data,1.0,1.0,iter,perturbed = false)
              push!(times,simulation_time)
          end
              #####
          for i in 1:populationSize
              fitness[i] = objfun(time_in,i)
              debug && println("FIT $(i): $(fitness[i])")
          end
      fitidx = sortperm(fitness, rev = true)
      bestIndividual = fitidx[1]
      curGenFitness = objfun(time_in,fitidx[1])
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
