struct Circular{T}
    d0::T
    lower
    upper
end

function circular(d0::UnivariateDistribution; lower, upper)
    return Circular(d0, lower, upper)
end

function wrap(x; lower, upper)
    if x < lower
        sub = x - lower
        res = upper + sub
        res > lower && return res
        return wrap(res; upper=upper, lower=lower)
    elseif x > upper
        sur = x - upper
        res = lower + sur
        res < upper && return res
        return wrap(res; upper=upper, lower=lower)
    end
    return x
end

cN = circular(Normal(360, 40); lower=0, upper=360);

function Random.rand(d::Circular{<:Normal{<:Real}})
    return wrap.(rand(default_rng(), d.d0); lower=d.lower, upper=d.upper)
end

function Random.rand(d::Circular{<:Normal{<:Real}}, T::Int)
    return wrap.(rand(default_rng(), d.d0, T); lower=d.lower, upper=d.upper)
end

function Random.rand(rng::AbstractRNG, d::Circular{<:Normal{<:Real}})
    return wrap(rand(rng, d.d0); lower=d.lower, upper=d.upper)
end

function Random.rand(rng::AbstractRNG, d::Circular{<:Normal{<:Real}}, T::Int)
    return wrap.(rand(rng, d.d0, T); lower=d.lower, upper=d.upper)
end
