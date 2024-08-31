
@testset "Constructor" begin
    @test env isa AbstractEnvironment
end

@testset "Field access" begin
    @test angles(env) isa AbstractMatrix
    @test distances(env) isa AbstractMatrix
    @test winds(env) isa AbstractMatrix
    @test latlon(env) isa Vector{NTuple{2, Float64}}
    @test groups(env) isa AbstractVector
end

# TODO add tests for finish_group and tiedindex helpers
# Also, is there a need to find finish group based on a given target group (instead of target island), too?
