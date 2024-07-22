const default_precision = 120

"""
	ismigrating(history, i)

Returns a `Boolean` value signalling whether the migration is still ongoing at step `i`.
"""
ismigrating(history, i) = i < 10 || 5 < length(Set(Iterators.drop(history, i - 10)))

# ╔═╡ 362723f8-64b0-49ea-9bd4-20fda8286132
function notarrived(m::T) where T <: AbstractMigration
	T != TargetedMigration && return true # Untargeted never arrived
	return current(m) != finish(m)
end

add_dist!(m, pe, a, b) = m.travelled += distances(pe)[a, b]

"""
	migrate(m::T, agent, pe::AbstractEnvironment) where T <: AbstractMigration

Returns the simulated migration of type `T` of `agent` in physical environment `pe`.
"""
function migrate(m::T, agent, pe::AbstractEnvironment) where T <: AbstractMigration
	# e_env = EffectiveEnvironment(pe, agent)
	# TODO does this adjustment have to happen _INSIDE_ migrate? No, right?!
	# ATTENTION had e_env before. But e_env contains only adjustments to angles, not new angles? CAREFUL!

	# Initialise counter
	i = 1

	# σ is the adjusted precision of an agent depending on its range (larger range means higher precision)
	σ = default_precision * evaluate(SigAngl, range(agent), max_range)

	while ismigrating(history(m), i) && notarrived(m) && i < 100 
		# Get current optimal migration angle (only changes in TargetedMigration)
		dir = direction(m)
		# Get current position from migration history
		current_pos = current(m)
		# Get current effective range of agent
		eff_range = erange(agent, travelled(m))
		# Calculate probabilities of potential targets from current position
		p = probabilities(current_pos, pe, eff_range, dir, i, σ)
		# Draw the target position
		target_pos = rand(Categorical(p))
		# Add travel distance to total travelled km
		current_pos != target_pos && add_dist!(m, pe, current_pos, target_pos)
		# m.travelled += distances(pe)[current_pos, target_pos]
		# Update migration history
		push!(history(m), target_pos)
		# Increment counter
		i += 1
	end

	return m
end

function main(pe::AbstractEnvironment, a::AbstractAgent, niter)
	# Find all indices of start positions among island groups
	starts = findall(x -> occursin("START", x), unique(groups(pe)))

	# Find all unique island groups that are NOT starting positions
	ugroups = filter(x -> !occursin("START", x), unique(groups(pe)))
	targetgroups = denserank(ugroups)

	# Number of starts
	nstarts = length(starts)
	ngroups = length(unique(groups(pe))) - nstarts
	
	out = Array{AbstractMigration}(undef, (nstarts, ngroups, niter))
	
	for start in starts
		Threads.@threads for targetgroup in targetgroups
			for iter in 1:niter
				target = @chain targetgroup begin
					_ + nstarts # adjust to index in source dataframe
					gettargets(_, groups(pe)) # get all possible targets
					sample(_, 1)[1] # sample one of them and return as Int, not Vec
				end
				M = TargetedMigration(start, target, pe)
				out[start, targetgroup, iter] = migrate(M, a, pe)
			end
		end
	end
	
	return out
end