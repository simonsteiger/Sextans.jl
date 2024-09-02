"""
	AbstractEnvironment

Abstract supertype of `PhysicalEnvironment` and `EffectiveEnvironment`.
"""
abstract type AbstractEnvironment end

function _unnest(x)
	dims = (length(x), length(x))
	out = @chain x begin
		reduce(vcat, _)
		reshape(_, dims)
	end
	return out
end

_envrow(f, i, col) = f.(Ref(col[i]), col)

"""
	ProtoEnvironment

Preliminarily store data about the physical environment.
"""
struct ProtoEnvironment <: AbstractEnvironment
	distances::Matrix{Float64}
	angles::Matrix{Float64}
	groups::Vector{Int64}
	invalid_target::Vector{Bool}
	function ProtoEnvironment(df::DataFrame)
		"invalid_target" in names(df) || throw(error("`df` must contain column `invalid_target`"))
		"Island Group" in names(df) || throw(error("`df` must contain column `Island Group`"))
		distances = map(x -> _envrow(haversine, x, df.latlon) ./ 1000, 1:nrow(df)) |> _unnest
		angles = map(i -> _envrow(polarangle, i, df.latlon), 1:nrow(df)) |> _unnest .|> deg2rad
		groups = tiedindex(df[:, "Island Group"])
		return new(distances, angles, groups, df.invalid_target)
	end
end

struct PhysicalEnvironment <: AbstractEnvironment
	distances::Matrix{Float64}
	angles::Matrix{Float64}
	function PhysicalEnvironment(proto::AbstractEnvironment, start::Int64)
		proto.invalid_target[start] = true
		proto.distances[proto.invalid_target, :] .= Inf
		return new(proto.distances, proto.angles)
	end
end

"""
	angles(x::AbstractEnvironment)

Return the `angles` field of an AbstractEnvironment `x`. 
"""
angles(x::AbstractEnvironment) = x.angles

"""
	distances(x::AbstractEnvironment)

Return the `distances` field of an AbstractEnvironment `x`. 
"""
distances(x::AbstractEnvironment) = x.distances
