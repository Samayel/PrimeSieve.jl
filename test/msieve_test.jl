@test( mfactor( @bigint(2^201-1))  == Dict{BigInt,Int}(7=>1,761838257287=>1,87449423397425857942678833145441=>1,1609=>1,22111=>1,193707721=>1))

@test( mfactor( BigInt(2)^201-1)  == Dict{BigInt,Int}(7=>1,761838257287=>1,87449423397425857942678833145441=>1,1609=>1,22111=>1,193707721=>1))

#@test( mfactor( @bigint(2^201-1))  == Dict{BigInt,Int}(7=>1,761838257287=>1,87449423397425857942678833145441=>1,1609=>1,22111=>1,193707721=>1))

@test mfactor(10) == Dict( 2 => 1, 5 => 1 )

# Test that mfactor gives same result as native Julia code
let a = 2^20 -1
    @test mfactor(a) == factor(a)
end
