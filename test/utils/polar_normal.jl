lwr, upr = 0, 2
pN = polar(Normal(), lower=lwr, upper=upr)

@testset "Construct polar distributions" begin
    @test pN isa Polar{Normal{Float64}}
end

@testset "Draw random samples" begin
    @test rand(pN) isa Float64
    @test rand(pN, 3) isa Vector{Float64}
    @test rand(MersenneTwister(42), pN, 3) isa Vector{Float64}
end

@testset "All values inside range" begin
    # Samples from pN might lay outside the polar range by several "limit spans"
    @test all(x -> Base.isbetween(lwr, x, upr), rand(pN, 100))
end
