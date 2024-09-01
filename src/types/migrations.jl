"""
	AbstractMigration

Abstract supertype of different migration types.
"""
abstract type AbstractMigration end

tiedindex(x) = [findfirst(==(v), unique(x)) for v in x]

function get_finish_group(island_group_vec, finish)
	numeric_groups = tiedindex(island_group_vec)
	all_islands = collect(eachindex(island_group_vec))
	return all_islands[numeric_groups[finish] .== numeric_groups]
end

mutable struct TargetedMigration <: AbstractMigration
	axioms::Axioms
	env::PhysicalEnvironment
	start::Int64
	finish::Int64
	finish_group::Union{Vector{Int64}, Int64}
	latlon::Vector{NTuple{2, Float64}}
	history::AbstractArray{Int64}
	travelled::Vector{Float64}
	energy::Vector{Float64}
	function TargetedMigration(df_env, start, finish, axioms)
		history = [start]
		env = PhysicalEnvironment(df_env, start)
		finish_group = get_finish_group(groups(env), finish)
		return new(axioms, env, start, finish, finish_group, latlon(env), history, [], [1.0])
	end
end

start(x::AbstractMigration) = x.start

finish(x::TargetedMigration) = x.finish

latlon(x::TargetedMigration, i) = x.latlon[i]

direction(x::TargetedMigration) = angles(x.env)[finish(x), current(x)]

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
