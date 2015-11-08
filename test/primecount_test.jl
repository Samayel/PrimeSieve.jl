@test typeof(primepi("10")) == Int128

@test nextprime(0) == 2
@test nextprime(2) == 3
@test prevprime(3) == 2
@test prevprime(2) == 0
@test prevprime(0) == 0
@test nextprime(prevprime(nextprime(@bigint 10^100))) == nextprime(@bigint 10^100)
@test genprimes(10^6, Val{:sieve}) == genprimes(10^6, Val{:next})

@test nextprime(2^20) == nextprime(BigInt(2^20))
@test prevprime(2^20) == prevprime(BigInt(2^20))
