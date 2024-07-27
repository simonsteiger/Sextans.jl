"""
	AbstractMigration

Abstract supertype of different migration types.
"""
abstract type AbstractMigration end

mutable struct TargetedMigration <: AbstractMigration
	start::Int64
	finish::Int64
	latlon::Vector{NTuple{2, Float64}}
	history::AbstractArray{Int64}
	travelled::Float64
	function TargetedMigration(start, finish, physenv)
		history = [start]
		return new(start, finish, latlon(physenv), history, 0.0)
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
