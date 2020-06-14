using Parameters
@with_kw struct ModelSettings
           N::Int = 1000 #number of agents
           iter::Int = 20 #number of iterations
           l::Float64 = 5.0 #vehicle length
       ##    roadwork_time::Int = 1  # approximate length of roadwork of single segment
      ##     no_of_partitions::Int = 5 # #number of steps in roadwork process
      ##     n::Int = 10 # number of roads to be removed from the graph
       end
       ModelSettings
