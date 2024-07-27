a, b = Angle(4), Angle(32)

@testset "Constructing Angles" begin
    @test Angle(4.0) isa Angle
    @test Angle(4) isa Angle
    @test try Angle("4") catch e; e isa MethodError end
    @test try Angle(366) catch e; e isa DomainError end
    @test try Angle(-8) catch e; e isa DomainError end
end

@testset "Accessing fields" begin
    @test value(a) isa Float64
end

@testset "Math with Angles" begin
    @test a - b isa Angle
    @test a - b == Angle(28)
end

# TODO add test for polarangle
