σ = Sigmoid(1, 1, -10, sqrt(2))

@testset "Invalid Sigmoid errors" begin
    @test try Sigmoid(1, -1, -10, sqrt(2)) catch e; e isa DomainError end
    @test try Sigmoid(1, 1, -10, -sqrt(2)) catch e; e isa DomainError end
end

@testset "Invalid `evaluate` errors" begin
    @test try evaluate(σ, -4.0, 2.0) catch e; e isa DomainError end
    @test try evaluate(σ, 4.0, -2.0) catch e; e isa DomainError end
end

@testset "Valid `evaluate` returns Float" begin
    @test evaluate(σ, 4.0, 2.0) isa AbstractFloat
end
