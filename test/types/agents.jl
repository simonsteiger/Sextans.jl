@testset "Constructor" begin
    @test Agent isa AbstractAgent
    @test Agent isa ActiveAgent
    @test !isa(Agent, PassiveAgent)
end

@testset "Field access" begin
    @test Sextans.range(Agent) isa Real
    @test flightspeed(Agent) isa Real
    @test resistance(Agent) isa Real
end