using Sextans
using Test
using Distributions
using Random: MersenneTwister

@testset "Circular distributions" begin
    include("utils/circular.jl")
end

@testset "Sigmoid functions" begin
    include("utils/sigmoid.jl")
end
