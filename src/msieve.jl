export mfactor

const smsievelib = @windows ? "libsmsieve.dll" : "libsmsieve.so"

type Msieveopts{S}
    n::ASCIIString
    deadline::Int
    logfile::S
    ecm::Bool
    info::Bool    
end

# Send the string to msieve and return c struct msieve_obj
function runmsieve(opts::Msieveopts)
    numcores = 1

    logfile = opts.logfile
    ecm = opts.ecm ? 1 : 0
    info = opts.info ? 1 : 0

    res = try
        ccall((:factor_from_string,smsievelib), Ptr{Void}, (Ptr{UInt8},Int,Int,Ptr{UInt8},Int,Int), opts.n, numcores, opts.deadline, logfile == "" ? C_NULL : logfile, ecm, info)
    catch
        error("factor_from_string failed")
    end

    res == C_NULL && throw(InterruptException())
    res
end

# Send ptr to msieve_obj and get ptr to struct factors.
getfactors(obj) = ccall((:get_factors_from_obj,smsievelib), Ptr{Void}, (Ptr{Void},), obj)
# Sent ptr to struct factors and get number of factors.
get_num_factors(factors) = ccall((:get_num_factors,smsievelib), Int, (Ptr{Void},), factors)
msieve_free(obj) =  ccall((:msieve_obj_free_2,smsievelib), Void, (Ptr{Void},), obj)

# Send ptr to struct factor and get string rep of one factor.
# A ptr to next struct factor, correponding to next factor, is returned.
function get_one_factor_value(factor)
    a = Array(UInt8,500) # max num digits input to msieve is 300
    nextfactor = ccall((:get_one_factor_value,smsievelib), Ptr{Void}, (Ptr{Void},Ptr{UInt8},Int), factor, a, length(a))

    nextfactor, bytestring(convert(Ptr{UInt8}, pointer(a)))
end

# Send ptr to first struct factor. Return all factors as array of strings 
function get_all_factor_values(factor)
    allf = Array(AbstractString, 0)
    nfactor = factor

    for i in 1:get_num_factors(factor)
        nfactor, sfact = get_one_factor_value(nfactor)
        push!(allf, sfact)
    end

    allf
end

# Send n as string to msieve, return all factors as array of strings
function runallmsieve(opts::Msieveopts)
    obj = runmsieve(opts)
    sfactors = get_all_factor_values(getfactors(obj))
    msieve_free(obj)
    sfactors
end

# input factors as Array of strings. Output Array of Integers (Usually of type Int)
function factor_strings_to_integers{T<:Integer}(::Type{T}, sfactors::Array{AbstractString})
    arr = Array(T, length(sfactors))
    @inbounds for (i, f) in enumerate(sfactors)
        arr[i] = parse(T, f)
    end
    arr    
end

# Send string to msieve. Return factors as list of Integers.
mfactorl{T<:Integer}(::Type{T}, opts::Msieveopts) = factor_strings_to_integers(T, runallmsieve(opts))

# Send string to msieve. Return factors in Dict, like Base.factor
function mfactor{T<:Integer}(::Type{T}, opts::Msieveopts)
    arr = mfactorl(T, opts)
    d = Dict{T,Int}()
    @inbounds for i in arr
        d[i] = get(d, i, 0) + 1
    end
    d
end

function mfactor(x::AbstractString; deadline::Integer = 0, logfile::AbstractString = "", ecm::Bool = false, info::Bool = false)
    opts = Msieveopts(x, deadline, logfile, ecm, info)
    mfactor(BigInt, opts)
end

function mfactor{T<:Integer}(x::T; deadline::Integer = 0, logfile::AbstractString = "", ecm::Bool = false, info::Bool = false)
    opts = Msieveopts(string(x), deadline, logfile, ecm, info)
    mfactor(T, opts)
end

for (thetype) in ( :AbstractString, :Integer ) 
    @eval begin
        function mfactor{T<:$thetype}(a::AbstractArray{T,1}; dl::Integer = 0, logfile::AbstractString = "", ecm::Bool = false, info::Bool = false)
            outa = Array(Any, 0)
            for x in a
                res = mfactor(x; deadline=dl, logfile=logfile, ecm=ecm, info=info)
                push!(outa, res)
            end
            outa
        end
    end
end
