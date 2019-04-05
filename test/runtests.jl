using Test
using OpenStreetMapX
using Random

@testset "maps" begin

using Random
Random.seed!(0);
@test rand(Int) == -4635026124992869592

end
