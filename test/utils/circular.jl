lwr, upr = 0, 2
cN = circular(Normal(), lower=lwr, upper=upr)

@testset "Construct circular distributions" begin
    @test cN isa Circular{Normal{Float64}}
end

@testset "Draw random samples" begin
    @test rand(cN) isa Float64
    @test rand(cN, 3) isa Vector{Float64}
    @test rand(MersenneTwister(42), cN, 3) isa Vector{Float64}
end

@testset "All values inside range" begin
    # Samples from cN might lay outside the circular range by several "limit spans"
    @test all(x -> Base.isbetween(lwr, x, upr), rand(cN, 100))
end
