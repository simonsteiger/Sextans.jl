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
    function ProtoEnvironment(latlon, invalid_target, group) # TODO seems overly complicated to use envrow and pass 1:length(x), improve?
        itr = eachindex(latlon)
        distances = map(i -> _envrow(haversine, i, latlon) ./ 1000, itr) |> _unnest
        angles = map(i -> _envrow(polarangle, i, latlon), itr) |> _unnest .|> deg2rad
        groups = tiedindex(group)
        return new(distances, angles, groups, invalid_target)
    end
end

"""
	Environment

Store data about the physical environment.
"""
struct Environment <: AbstractEnvironment
    distances::Matrix{Float64}
    angles::Matrix{Float64}
    function Environment(proto::ProtoEnvironment, start::Int64)
        invalid_bv = copy(proto.invalid_target)
        invalid_bv[start] = true
        proto.distances[invalid_bv, :] .= Inf
        return new(proto.distances, proto.angles)
    end
end

# Group-level "invalid_target" are only start locations
struct GroupEnvironment <: AbstractEnvironment
    distances::Matrix{Float64}
    angles::Matrix{Float64}
    function GroupEnvironment(env::ProtoEnvironment)
        # Can add invalidate step here
        # xx = copy(env.invalid_target)
        # xx[start] = true
        return new(copy(env.distances), copy(env.angles))
    end
end

# Try no invalid targets on Island level
struct IslandEnvironment <: AbstractEnvironment
    distances::Matrix{Float64}
    angles::Matrix{Float64}
    groups::Vector{Int64}
    function IslandEnvironment(env::ProtoEnvironment)
        # Can add invalidate step here
        # xx = copy(env.invalid_target)
        # xx[start] = true
        return new(copy(env.distances), copy(env.angles), copy(env.groups))
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
