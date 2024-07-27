"""
    Angle

Store the value of an angle. The following methods are defined for this type:

- value(a::Angle) # return the value of `a` as a `Float64`
- :(-) # calculate the difference of two angles

# Examples

```julia-repl
julia> a, b = Angle(4), Angle(36);
julia> value(a)
4.0
julia> a - b
32.0
```
"""
struct Angle
    value::Float64
    function Angle(x)
        Base.isbetween(0, x, 360) || throw(DomainError(x, "angles are only defined for 0 < x < 360"))
        return new(x)
    end
end

"""
    value(a::Angle)

Return the value stored in `a` as a Float64.

```julia-repl
julia> a = Angle(4);
julia> value(a)
4.0
```
"""
value(a::Angle) = a.value

# Define regularly used radii for clarity
const HALF = 180.0
const FULL = HALF * 2

# Conversion necessary for negative results returned by `atand`
_adjust(x) = x + FULL

function Base.:(-)(x::Angle, y::Angle)
    dif = abs(value(x) - value(y))
    if dif > HALF
        return Angle(FULL - dif)
    end
    return Angle(dif)
end

# TODO improve docstring, excuse my angl'ish.
"""
    polarangle(x::T, y::T) where {T<:NTuple{2,AbstractFloat}}

Return the angle between two points on a polar coordinate system and the origin of the coordinate system.
This method expects x and y to be Tuples of coordinates.

    polarangle(east, north)

Method for directions.
"""
function polarangle(x::T, y::T) where {T<:NTuple{2,AbstractFloat}}
    lat1, lon1 = x
    lat2, lon2 = y
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    deg = atand(dlon, dlat)
    # FIXME should this return an Angle?
    return deg > zero(deg) ? deg : _adjust(deg)
end

# FIXME Need to fix method for latlon values to be able to provide this as fallback
# function polarangle(east, north)
#     deg = atand(east, north)
#     if deg > zero(deg)
#         return Angle(deg)
#     end
#     return Angle(_adjust(deg))
# end
