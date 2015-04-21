# Tests that take more time to run

@test ntcountprimes("10^19", "10^19+10^6") == 23069

# fixed overflow bugs
@test countprimes(convert(Int128,10)^19,convert(Int128,10)^19+10^3) == 28
@test countprimes(convert(Int128,10)^19+10^9) == convert(Int128,234057667299198865)
@test countprimes("10^19 + 10^9") == 234057667299198865
