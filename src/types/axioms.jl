Base.@kwdef struct Axioms
    default_precision::Float64
    max_iter::Int64
    min_iter::Int64
    max_range::Int64
    local_threshold::Int64
end

# TODO accessor for min_range
