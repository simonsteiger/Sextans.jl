using Sextans
using Test
using Distributions
using Random: MersenneTwister
using Base: -, +

function create_distmat(dims)
	D = rand(Uniform(10, 2000), dims, dims)
	D[D .== diag(D)] .= 0
	return Symmetric(D)
end

function create_anglemat(dims)
	A = rand(Uniform(0, 360), dims, dims)
	A[A .== diag(A)] .= 180 # This has to be the mode of the distribution
	return Symmetric(A)
end

function create_windmat(dims)
	M = rand(Gamma(3, 15), dims, dims)
	M[M .== diag(M)] .= 0
	return Symmetric(M)
end

@testset "Polar dists" begin
    include("utils/polar_normal.jl")
end

@testset "Sigmoid" begin
    include("utils/sigmoid.jl")
end

@testset "Angles" begin
    include("utils/angle.jl")
end
