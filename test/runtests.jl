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
    subset(_, :Basin => ByRow(x -> occursin(r"india", lowercase(x))))
    transform(_, [:Latitude, :Longitude] => ByRow((x, y) -> (x, y)) => :latlon)
    transform(_, :Basin => ByRow(x -> occursin(r"START", x)) => :invalid_target)
end

axm = Axioms(
    max_iter=50,
    min_iter=10,
    default_precision=45,
    max_range=5000,
    local_threshold=5
)

agent = ActiveAgent(1500, 60, 4, missing)
targets = collect(2:nrow(df_islands))

proto = ProtoEnvironment(df_islands.latlon, df_islands.invalid_target, df_islands[:, "Island Group"])

migs = [TargetedMigration(proto, 1, target, axm) for target in targets]

africa_australia = TargetedMigration(proto, 2, 4, axm)
aaagent = ActiveAgent(3000, 60, 4, missing)
migrate!(africa_australia, aaagent)

df_islands[history(africa_australia), :]


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

@testset "Migrations" begin
    include("types/migrations.jl")
end
