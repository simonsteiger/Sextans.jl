"""
	erange(agent, travelled)

Returns the effective range of the `agent` given the distance it has `travelled`.
"""
function erange(agent::ActiveAgent, travelled, min_range)
	return maximum([range(agent) * min_range, range(agent) - travelled])
end

# TODO need an equivalent for passive agents
