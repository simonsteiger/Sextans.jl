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
	PhysicalEnvironment

Store data about the observed environmental conditions `distances`, `angles`, and `wind` between atolls.
"""
struct PhysicalEnvironment <: AbstractEnvironment
	distances
	angles
	winds
	latlon
	groups
	function PhysicalEnvironment(df::DataFrame)
		"latlon" in names(df) || throw("`latlon` column not found")
		"Island Group" in names(df) || throw("`Island Group` column not found")
		winds = zeros(nrow(df), nrow(df))
		latlon = df.latlon
		groups = df[:, "Island Group"]
		starts = findall(x -> occursin("START", x), groups)
		distances = map(1:nrow(df)) do i
			out = _envrow(haversine, i, latlon) ./ 1000
			out[starts] .= Inf
			return out
		end |> _unnest
		angles = map(i -> _envrow(polarangle, i, latlon), 1:nrow(df)) |> _unnest
		return new(distances, angles, winds, latlon, groups)
	end
end

latlon(x::PhysicalEnvironment) = x.latlon

"""
	winds(x::PhysicalEnvironment)

Return the `winds` field of a PhysicalEnvironment `x`. 
"""
winds(x::PhysicalEnvironment) = x.winds

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

groups(x::PhysicalEnvironment) = x.groups
