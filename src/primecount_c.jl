export primepi
export legendrephi
export nthprime
export primeLi
export primeLiinv
export primepi_xmax
export primepi_num_threads
export primepi_num_threads
export prime_set_print_status
#export primepi_test

const libccountname = @static is_windows() ? "libcprimecount.dll" : "libcprimecount.so"

for (f,c) in ( # (:primepi, :(:pi_int64)), use function with keyword
               (:pi_deleglise_rivat, :(:pi_deleglise_rivat)),
              (:pi_legendre, :(:pi_legendre)), (:pi_lehmer, :(:pi_lehmer)),
              (:pi_meissel, :(:pi_meissel)), (:pi_lmo, :(:pi_lmo)),
              (:piprimesieve, :(:pi_primesieve)), (:nthprimecount, :(:nth_prime)),
              (:primeLi, :(:prime_Li)), (:primeLiinv, :(:prime_Li_inverse)))
    @eval begin
        # are c++ exceptions the culprit ? Don't see it in the code
        # function ($f){T<:Real}(n::T)   # try-catch not preventing segfaults
        #     res = try
        #         ccall(($c, libccountname), Int64, (Int64,), convert(Int64,n))
        #     catch
        #         throw(InterruptException())
        #     end
        #     return convert(T,res)
        # end
        ($f){T<:Real}(n::T) = ccall(($c, libccountname), Int64, (Int64,), convert(Int64,n))
        ($f){T<:AbstractString}(n::T) = ($f)(conv128(n))
        Base.@vectorize_1arg Real $f
        Base.@vectorize_1arg AbstractString $f        
    end
end



function legendrephi(x,a)
    ccall((:prime_phi, libccountname), Int64, (Int64, Int64), convert(Int64,x), convert(Int64,a))
end
Base.@vectorize_2arg Integer legendrephi

nthprime(x) = nthprime(x, Val{:count})
nthprime(x, ::Type{Val{:count}}) = nthprimecount(x)
nthprime(x, ::Type{Val{:sieve}}) = nthprimea(x)

Base.@vectorize_1arg Integer nthprime

# libprimecount has a member function converts a string to Int128, but we probably handle more cases this way
function primepi{T<:AbstractString}(s::T)
    n1 = conv128(s)
    s1 = string(n1)
    parse(Int128, unsafe_string(ccall((:pi_string,libccountname),Ptr{UInt8},(Ptr{UInt8},),s1)))
end

Base.@vectorize_1arg AbstractString primepi

# Can't get access to Int128 routine, so we convert back and forth many times.
pi_deleglise_rivat(x::Int128) = primepi(string(x))

# :auto is not perfect, fails often
# Tables or interpolation, or a crude fit for both methods is a better way.
# The two parameters are x and rem, the distance to the previous table value.

primepi(x)                                               = primepi(x, Val{:auto})
primepi{T<:Integer}(x::T, ::Type{Val{:dr}})              = convert(T, pi_deleglise_rivat(x))
primepi{T<:Integer}(x::T, ::Type{Val{:deleglise_rivat}}) = convert(T, pi_deleglise_rivat(x))
primepi{T<:Integer}(x::T, ::Type{Val{:tabsieve}})        = convert(T, countprimes(x))
primepi{T<:Integer}(x::T, ::Type{Val{:lehmer}})          = convert(T, pi_lehmer(x))
primepi{T<:Integer}(x::T, ::Type{Val{:meissel}})         = convert(T, pi_meissel(x))
primepi{T<:Integer}(x::T, ::Type{Val{:lmo}})             = convert(T, pi_lmo(x))
primepi{T<:Integer}(x::T, ::Type{Val{:legendre}})        = convert(T, pi_legendre(x))
primepi{T<:Integer}(x::T, ::Type{Val{:sieve}})           = convert(T, piprimesieve(x))

primepi(x, ::Type{Val{:auto}}) = begin
    # This is a fairly sharp crossover here
    x < 7*10^11 && return primepi(x, Val{:tabsieve})

    rem = piandrem(x)[3]
    rem == 0 && return primepi(x, Val{:tabsieve})
    if rem <= 10^9 || x/rem >= 10^7  # this gets a lot of cases correctly.
        return primepi(x, Val{:tabsieve})
    else
        return primepi(x, Val{:deleglise_rivat})
    end
end

# using macro will work, too
#Base.@vectorize_1arg Integer primepi
function primepi(arr::AbstractArray, alg)
    arrout = similar(arr)
    for i in 1:length(arr) arrout[i] = primepi(arr[i], alg) end
    arrout
end


#register_sigint() = ccall((:cprimecount_register_sigint, libccountname), Void, ())

# Sun Apr  3 18:21:07 CEST 2016:  These two are broken. This syntax worked at one point. Julia has changed
#primepi_xmax() = parse(Int128, unsafe_string(ccall((:pi_xmax, libccountname), Ptr{UInt8}, ())))
#const PRIMEPI_XMAX = primepi_xmax()

primepi_num_threads(n) = ccall((:prime_set_num_threads,libccountname),Void,(Int,), convert(Int,n))
primepi_num_threads() = ccall((:prime_get_num_threads,libccountname),Int,())
prime_set_print_status(stat::Bool) = ccall((:prime_set_num_threads,libccountname),Void,(Int,), stat ? 1 : 0)

#primepi_test() = ccall((:prime_test,libccountname),Int,())

# libprimecount does not really set the number of threads until you ask.
# In primecount, the initial value returned by init_num_threads == num cores.
# In primesieve it was a huge integer. I am paranoid, so I check.
function init_num_threads()
    n = primepi_num_threads()
    n < 10000 && primepi_num_threads(n)
end

# Set multithreading now
init_num_threads()
