using Sextans
using Test
using Distributions
using LinearAlgebra
using Random: MersenneTwister
using Base: -, +
using CSV
using DataFrames
using Chain

df = @chain begin
	joinpath(@__DIR__, "data", "environment.csv")
	CSV.read(_, DataFrame)
	transform(_, [:Latitude, :Longitude] => ByRow((x,y) -> (x, y)) => :latlon)
	dropmissing(_)
end

axm = Axioms(
	max_iter = 30,
	min_range = 1//3,
	default_precision=80,
	max_range = 5000,
)

env = PhysicalEnvironment(df)

agent = ActiveAgent(5000, 60, 4, missing)

mig = TargetedMigration(1, 345, env, axm)

@testset "Polar N" begin
    include("utils/polar_normal.jl")
end

@testset "Sigmoid" begin
    include("utils/sigmoid.jl")
end

@testset "Angles" begin
    include("utils/angle.jl")
end

@testset "Environments" begin
	include("types/environments.jl")
end

@testset "Agents" begin
	include("types/agents.jl")
end

@testset "Migrations" begin
	include("types/migrations.jl")
end
