"""
	erange(agent, travelled)

Returns the effective range of the `agent` given the distance it has `travelled`.
"""
erange(agent::ActiveAgent, travelled) = maximum([range(agent) / 3, range(agent) - travelled])

# TODO need an equivalent for passive agents
