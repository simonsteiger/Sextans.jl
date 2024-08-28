"""
	AbstractMigration

Abstract supertype of different migration types.
"""
abstract type AbstractMigration end

mutable struct TargetedMigration <: AbstractMigration
	axioms::Axioms
	start::Int64
	finish::Int64
	finish_group::Union{Vector{Int64}, Int64}
	latlon::Vector{NTuple{2, Float64}}
	history::AbstractArray{Int64}
	travelled::Vector{Float64}
	function TargetedMigration(start, finish, finish_group, physenv, axioms)
		history = [start]
		return new(axioms, start, finish, finish_group, latlon(physenv), history, [])
		# FIXME instead of initializing at 0.0 travelled, we should start with an empty vector
	end
end

start(x::AbstractMigration) = x.start

finish(x::TargetedMigration) = x.finish

latlon(x::TargetedMigration, i) = x.latlon[i]

function direction(x::TargetedMigration)
    cur_latlon = latlon(x, current(x))
    fin_latlon = latlon(x, finish(x))
    return polarangle(cur_latlon, fin_latlon)
end

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
