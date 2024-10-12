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
	function ProtoEnvironment(df_rows, df_cols; groupcol=:bin_id)
		distances = map(df_rows.latlon) do group
            haversine.(df_cols.latlon, Ref(group),) ./ 1000
        end |> x -> transpose(reduce(hcat, x))
        angles = map(df_rows.latlon) do group
            deg2rad.(polarangle.(df_cols.latlon, Ref(group),))
        end |> x -> transpose(reduce(hcat, x))
		# Use cols because that's always islands
		groups = tiedindex(df_cols[:, groupcol])
		return new(distances, angles, groups)
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
