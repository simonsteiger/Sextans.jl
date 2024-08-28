SigDist = Sigmoid(1.0, 1.0 - eps(), -10.0, sqrt(2))

function alt_adjust_VM(d, r)
    rs = [r, r + 360, r - 360]
    return maximum(pdf.(d, rs))
end

# start to finish (total journey km T)
# replace inv(i) with
# ccdf(Exponential(T/2), d_to_f)
# mutliply with default precision as is

"""
	probabilities(current, env, erange, dir)

Returns the probability vector for transitioning from the `current` position to the targets stored in `env`. This depends on the effective range `erange` and the direction `dir` of the migration.
"""
function probabilities(current, env, erange, dir, σ, xx) # effective range used
    μ_rad = deg2rad(dir) # .+ angles(env)[current, :] # currently not wind adjusted
    κ = 1 / (deg2rad(xx * σ)^2) # change with NS
    # TODO flip indexing to instead grab an entire column, not a row
    Δ = @view distances(env)[:, current]
    α = @view angles(env)[:, current]
    p_Δ = evaluate(SigDist, Δ, erange)
    VM = VonMises.(μ_rad, κ)
    p_α = alt_adjust_VM.(VM, α) ./ pdf.(VM, mean.(VM))
    p = p_α .* p_Δ
    stayed = rand(Bernoulli(prod(1 .- p)))
    if stayed
        p = zero(p)
        p[current] = 1
        return p
    end
    return normalize(p, 1) # normalize vector so it sums to 1
end
