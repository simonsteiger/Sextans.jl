"""
	AbstractMigration

Abstract supertype of different migration types.
"""
abstract type AbstractMigration end

tiedindex(x) = [findfirst(==(v), unique(x)) for v in x]

function get_group(island_groups, idx)
	all_islands = collect(eachindex(island_groups))
	return all_islands[island_groups[idx] .== island_groups]
end

mutable struct TargetedMigration <: AbstractMigration
	axioms::Axioms
	env_group::GroupEnvironment
	env_island::IslandEnvironment
	start_island::Int64
	finish_group::Int64
	history::AbstractArray{Int64}
	travelled::Vector{Float64}
	energy::Vector{Float64}
	function TargetedMigration(proto_group, proto_island, start_island, finish_group, axioms)
		history = [start_island]
		env_group = GroupEnvironment(proto_group)
		env_island = IslandEnvironment(proto_island)
		return new(axioms, env_group, env_island, start_island, finish_group, history, [], [1.0])
	end
end

start(x::AbstractMigration) = x.start_island

finish(x::TargetedMigration) = x.finish_group

direction(x::TargetedMigration) = angles(x.env_group)[finish(x), current(x)]

"""
	travelled(x::AbstractMigration)

Returns the current total `travelled` distance of the migration `x`.
"""
travelled(x::AbstractMigration) = x.travelled

"""
	history(x::AbstractMigration)

Returns the `history` of an AbstractMigration `x`.
"""
history(x::AbstractMigration) = x.history

"""
	current(x::AbstractMigration)

Returns the row-index of the `current` location.
"""
current(x::AbstractMigration) = history(x)[end]
