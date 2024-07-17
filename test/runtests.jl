using Sextans
using Test
using Distributions
using Random: MersenneTwister
using Base: -, +

@testset "Polar dists" begin
    include("utils/polar_normal.jl")
end

@testset "Sigmoid" begin
    include("utils/sigmoid.jl")
end

@testset "Angles" begin
    include("utils/angle.jl")
end
