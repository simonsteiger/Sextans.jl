using Sextans
using Test
using Distributions
using LinearAlgebra
using Random: MersenneTwister
using Base: -, +
using CSV
using DataFrames
using Chain
using CategoricalArrays

df_islands = @chain begin
    joinpath(@__DIR__, "data", "environment.csv")
    CSV.read(_, DataFrame)
    subset(_, :Basin => ByRow(x -> occursin(r"india", lowercase(x))))
    transform(_, [:Latitude, :Longitude] => ByRow((x, y) -> (x, y)) => :latlon)
end

lat_edge = Base.range(extrema(df_islands.Latitude)...; step=1)
lon_edge = Base.range(extrema(df_islands.Longitude)...; step=1)

df_islands.bin_lat = cut(df_islands.Latitude, lat_edge; extend=true)
df_islands.bin_lon = cut(df_islands.Longitude, lon_edge; extend=true)

df_groups = @chain df_islands begin
    transform(_, :Longitude => ByRow(x -> x < 0 ? x + 360 : x) => identity)
    subset(_, :Basin => ByRow(x -> occursin(r"india", lowercase(x))))
    groupby(_, r"bin")
    transform(_, Cols(r"itude") .=> mean => identity)
    transform(_, :Longitude => ByRow(x -> x > 180 ? x - 360 : x) => identity)
    transform(_, "Island Group" => ByRow(x -> occursin(r"START", x)) => :invalid_target)
    transform(_, [:Latitude, :Longitude] => ByRow((x, y) -> (x, y)) => :latlon)
    unique(_, :latlon)
    insertcols(_, :bin_id => eachindex(_[:, "Island Group"]))
    select(_, :latlon, r"bin", :invalid_target)
end

tmp = []

for (i, row_out) in enumerate(eachrow(df_groups))
    x = row_out.bin_lat .== df_islands.bin_lat .&& row_out.bin_lon .== df_islands.bin_lon
    push!(tmp, (i, x))
end

df_islands.bin_id = fill(0, nrow(df_islands))
for (id, idx) in tmp
    df_islands.bin_id[idx] .= id
end

axm = Axioms(
    max_iter=50,
    min_iter=10,
    default_precision=120,
    max_range=5000,
    local_threshold=5
)

agent = ActiveAgent(1500, 60, 4, missing)

targets = collect(2:nrow(df_groups))

proto_group = ProtoEnvironment(df_groups, df_islands)
proto_island = ProtoEnvironment(df_islands, df_islands)

migs = [TargetedMigration(proto_group, proto_island, 1, target, axm) for target in targets]

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
