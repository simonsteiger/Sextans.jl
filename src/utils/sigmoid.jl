"""
	Sigmoid(ymax, yrange, slope, xoffset)

Store parameters of a sigmoid function:

- `ymax` sets the highest possible value of the function
- `yrange` defines the lowest possible value as `ymax - yrange`
- `slope` defines how steeply the function declines (the larger, the steeper)
- `xoffset` sets a multiplier for the x value corresponding to the inflection point. If set to 1, the `scale` parameter in the `evaluate()` function is the x value at the inflection point of the function.

```julia-repl
julia> Sigmoid(1, 1, -10, sqrt(2))
```
"""
struct Sigmoid
    ymax::Float64
    yrange::Float64
    slope::Float64
    xoffset::Float64
    function Sigmoid(ymax, yrange, slope, xoffset)
        yrange > zero(yrange) || throw(DomainError("`yrange` must be positive"))
        xoffset > zero(xoffset) || throw(DomainError("`xoffset` must be positive"))
        return new(ymax, yrange, slope, xoffset)
    end
end

"""
	evaluate(σ::Sigmoid, x, scale)

Evaluate the sigmoid function at the value `x` with the parameters stored in  `σ` as:

``
\\sigma(x) = \\text{ymax} + \\frac{-\\text{yrange}}{1 + e^\\left(\\frac{\\text{slope}}{\\text{inflection} \\times \\text{scale}}\\right)}
``

	evaluate(σ::Sigmoid, x::AbstractArray, scale)

Evaluate the sigmoid function for an array of values `x` with the parameters stored in `σ`.

# Examples

```julia-repl
julia> σ = Sigmoid(1, 1, -10, sqrt(2));

julia> evaluate(σ, 5.0, 4.2)
0.8294963674627596

julia> evaluate(σ, 5.0, [2.1, 4.2, 6.0])
Vector{Float64}:
0.998445
0.829496
0.47464
```
"""
function evaluate(σ::Sigmoid, x, scale)
    x < zero(x) && throw(DomainError("`σ` undefined for `x` < 0."))
    scale < zero(scale) && throw(DomainError("`σ` undefined for `scale` < 0."))
    scaled_offset = σ.xoffset * scale
    out = @. σ.ymax + (-σ.yrange / (1 + exp(σ.slope / scaled_offset * (x - scaled_offset))))
    return out
end
