using Parameters
@with_kw struct ModelSettings
    N::Int = 10000 #number of agents
    l::Float64 = 5.0 #vehicle length
end
