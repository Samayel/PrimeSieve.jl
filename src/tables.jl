import Base: getindex, length, eltype
export primetables, primelookup, primetableinfo, primetablefilename
export primetabletype, primesievetype

# A single table of π(x) with constant increment between values of x
immutable PrimeTable
    data::Array{Int128,1}  # values of π(x)
    incr::Int128           # increment to x for successive elements
    maxn::Int128           # largest value in data. (The last element)
    expn::Int              # log10(incr), an integer
end

length(t::PrimeTable) = length(t.data)
getindex(t::PrimeTable,i) = (t.data)[i]
eltype(t::PrimeTable) = eltype(t.data)
getindex(t::Array{PrimeTable}, i::Int,j::Int) = t[i][j]
primetabletype() = eltype(primetables[1])
primesievetype() = UInt64

#  Return a list (pi-tab, min, rem), where `pi-tab' is
#  the value of prime pi function at argument `min',
#  and `rem'= `x'-`min'"
function piandrem{T}(t::PrimeTable, x::T)
    q, rem = divrem(x, t.incr)
    convert(T, (t.data)[q]), convert(T, t.incr * q), convert(T, rem)
end

# Find the table with finest increments such that
# x falls on or between incrments and look up value for x
function piandrem(x)
    j = 0
    @inbounds for i in 1:length(primetables) x <= primetables[i].maxn && (j = i; break) end
    j == 0 && error("x is too large!")
    piandrem(primetables[j], x)
end

function primelookup(x)
    j = 0
    @inbounds for i in 1:length(primetables) x <= primetables[i].maxn && (j = i ; break) end
    j == 0 && error("x is too large!")
    j, piandrem(primetables[j], x)
end

# Look up prime pi in table, compute remaining primes
function _countprimes(stop)
    stop < 10 && return ntcountprimes(stop)

    count, i, rem = piandrem(stop)
    rem == 0 ? count : count + ntcountprimes(i, i + rem)
end

function _countprimes{T}(start::T, stop::T)
    local n1, n2, count1, count2, d1
    if start < 10
        n1 = ntcountprimes(start)
        count1 = zero(T)
    else
        count1, i1, rem1 = piandrem(start)
        n1 = rem1 == 0 ? zero(T) : ntcountprimes(i1, i1 + rem1)
    end
    d1 = isprime(start) ? one(T) : zero(T)
    if stop < 10
        n2 = ntcountprimes(stop)
        count2 = zero(T)
    else
        count2, i2, rem2 = piandrem(stop)
        n2 = rem2 == 0 ? zero(T) : ntcountprimes(i2, i2 + rem2)
    end
    count2 - count1 + n2 - n1 + d1
end

const _primetablefilename = Pkg.dir("PrimeSieve") * "/data/primetables128bin.dat"
primetablefilename() = _primetablefilename

# Read the tables from a binary data file.  First Int is number of
# tables.  Second Int is number of elements in first table.  Next come
# all the elements in the table, then the number of elements for the
# next table, etc.
function _readbintables()
    fn = primetablefilename()
    if stat(fn).inode == 0
        error("Can't find file containing prime tables, $fn\n"
              * "Maybe your package installation is corrupt.")
    end
    mystream = open(fn)
    buf = zeros(Int64,1)
    read!(mystream,buf)
    numtables = buf[1]
    bintables = Array{Array{Int128,1}}(0)
    for itab in 1:numtables
        read!(mystream,buf)
        numprimes = buf[1]
        a = Array{Int128}(numprimes)
        read!(mystream,a)
        push!(bintables,a)
    end
    close(mystream)
    return bintables
end

# Read binary tables and make table data structures.
function loadprimetables()
    bintables = _readbintables()
    tables = Array{PrimeTable}(length(bintables))
    base = Int128(10)
    for i in 1:length(bintables)
        data = bintables[i]
        expn = i
        incr = base^expn
        maxn = incr * length(data)
        pt = PrimeTable(data,incr,maxn,expn)
        tables[i] = pt
    end
    tables
end

function primetableinfo()
    dtype = eltype(primetables[1])
    println("Tables of π(x). element type: $dtype. Listed are: table number, increment in x (and first value of x),")
    println("number of entries in the table, largest x in table.\n")
    println("table  incr    tab len  max x")
    for i in 1:length(primetables)
        t = primetables[i]
        l = length(t)
        ip = rpad("$i",6)
        incr = rpad("10^$i",7)
        ll = round(Int, log10(l))
        len = rpad("10^$ll",8)
        maxn = "10^$(ll+i)"
        println("$ip $incr $len $maxn")    
    end
end

# Read the tables now.
const primetables = loadprimetables();
