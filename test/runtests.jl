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
	max_iter = 50,
	min_range = 1/3,
	min_iter = 10,
	default_precision=80,
	max_range = 5000,
	local_threshold = 5
)

env = PhysicalEnvironment(df)

agent = ActiveAgent(2500, 60, 4, missing)

target = 1400

df.numidx = eachindex(df.region)

finish_group = @chain df begin
	subset(_, "Island Group" => ByRow(x -> x == _[target, "Island Group"]))
	getproperty(_, :numidx)
end

mig = TargetedMigration(1, target, finish_group, env, axm)

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

using BenchmarkTools

@benchmark migrate!($mig, $agent, $env)
