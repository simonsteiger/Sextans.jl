using Sextans
using Test
using Distributions
using LinearAlgebra
using Random: MersenneTwister
using Base: -, +
using CSV
using DataFrames
using Chain


df_islands = @chain begin
	joinpath(@__DIR__, "data", "environment.csv")
	CSV.read(_, DataFrame)
    subset(_, :Basin => ByRow(x -> occursin(r"pacific", lowercase(x))))
    transform(_, [:Latitude, :Longitude] => ByRow((x,y) -> (x, y)) => :latlon)
end

df_groups = @chain df_islands begin
	transform(_, :Longitude => ByRow(x -> x < 0 ? x + 360 : x) => identity)
	subset(_, :Basin => ByRow(x -> occursin(r"pacific", lowercase(x))))
	groupby(_, "Island Group")
	combine(_, Cols(r"itude") .=> mean => identity)
	transform(_, :Longitude => ByRow(x -> x > 180 ? x - 360 : x) => identity)
	transform(_, "Island Group" => ByRow(x -> occursin(r"START", x) ? true : false) => :invalid_target)
	transform(_, [:Latitude, :Longitude] => ByRow((x,y) -> (x, y)) => :latlon)
end

axm = Axioms(
	max_iter = 50,
	min_iter = 10,
	default_precision=120,
	max_range = 5000,
	local_threshold = 5
)

agent = ActiveAgent(4500, 60, 4, missing)

targets = collect(3:nrow(df_groups))

proto_group = ProtoEnvironment(df_groups, df_islands)
proto_island = ProtoEnvironment(df_islands, df_islands)

migs = [TargetedMigration(proto_group, proto_island, start, target, axm) for start in [1, 2], target in targets]

@testset "Migrations" begin
	include("types/migrations.jl")
end

#=
@testset "Sigmoid" begin
    include("utils/sigmoid.jl")
end

@testset "Angles" begin
    include("utils/angle.jl")
end

@testset "Agents" begin
	include("types/agents.jl")
end

@testset "Environments" begin
	include("types/environments.jl")
end
=#
