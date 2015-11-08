countprimes(stop::ConvT) = countprimes(conv128(stop))
countprimes(stop::ConvT, tuplet) = countprimes(conv128(stop), tuplet)
countprimes(stop::Integer) = countprimes(stop, Val{1})
countprimes(stop::Integer, ::Type{Val{1}}) = _countprimes(stop)
countprimes(stop::Integer, ::Type{Val{2}}) = countprimes2(stop)
countprimes(stop::Integer, ::Type{Val{3}}) = countprimes3(stop)
countprimes(stop::Integer, ::Type{Val{4}}) = countprimes4(stop)
countprimes(stop::Integer, ::Type{Val{5}}) = countprimes5(stop)
countprimes(stop::Integer, ::Type{Val{6}}) = countprimes6(stop)

countprimes(start::ConvT, stop::ConvT) = countprimes(conv128(start), conv128(stop))
countprimes(start::ConvT, stop::ConvT, tuplet) = countprimes(conv128(start), conv128(stop), tuplet)
countprimes(start::Integer, stop::Integer) = countprimes(start, stop, Val{1})
countprimes(start::Integer, stop::Integer, ::Type{Val{1}}) = countprimes(start, stop, Val{1}, Val{:tabsieve})
countprimes(start::Integer, stop::Integer, ::Type{Val{1}}, ::Type{Val{:next}})     = countprimesb(start, stop)
countprimes(start::Integer, stop::Integer, ::Type{Val{1}}, ::Type{Val{:nexta}})    = stop > stoplimit ? countprimes(start, stop, Val{1}, Val{:next}) : countprimesc(start, stop)
countprimes(start::Integer, stop::Integer, ::Type{Val{1}}, ::Type{Val{:tabsieve}}) = stop > stoplimit ? countprimes(start, stop, Val{1}, Val{:next}) : _countprimes(start, stop)
countprimes(start::Integer, stop::Integer, ::Type{Val{1}}, ::Type{Val{:sieve}})    = stop > stoplimit ? countprimes(start, stop, Val{1}, Val{:next}) : ntcountprimes(start, stop)
countprimes(start::Integer, stop::Integer, ::Type{Val{2}}) = countprimes2(start, stop)
countprimes(start::Integer, stop::Integer, ::Type{Val{3}}) = countprimes3(start, stop)
countprimes(start::Integer, stop::Integer, ::Type{Val{4}}) = countprimes4(start, stop)
countprimes(start::Integer, stop::Integer, ::Type{Val{5}}) = countprimes5(start, stop)
countprimes(start::Integer, stop::Integer, ::Type{Val{6}}) = countprimes6(start, stop)

scountprimes(stop::ConvT) = scountprimes(conv128(stop))
scountprimes{T}(stop::ConvT, tuplet::Type{T}) = scountprimes(conv128(stop), tuplet)
scountprimes(stop::Integer) = scountprimes(stop, Val{1})
scountprimes(stop::Integer, ::Type{Val{1}}) = _scountprimes(stop)
scountprimes(stop::Integer, ::Type{Val{2}}) = scountprimes2(stop)
scountprimes(stop::Integer, ::Type{Val{3}}) = scountprimes3(stop)
scountprimes(stop::Integer, ::Type{Val{4}}) = scountprimes4(stop)
scountprimes(stop::Integer, ::Type{Val{5}}) = scountprimes5(stop)
scountprimes(stop::Integer, ::Type{Val{6}}) = scountprimes6(stop)

scountprimes(start::ConvT, stop::ConvT) = scountprimes(conv128(start), conv128(stop))
scountprimes{T}(start::ConvT, stop::ConvT, tuplet::Type{T}) = scountprimes(conv128(start), conv128(stop), tuplet)
scountprimes(start::Integer, stop::Integer) = scountprimes(start, stop, Val{1})
scountprimes(start::Integer, stop::Integer, ::Type{Val{1}}) = _scountprimes(start, stop)
scountprimes(start::Integer, stop::Integer, ::Type{Val{2}}) = scountprimes2(start, stop)
scountprimes(start::Integer, stop::Integer, ::Type{Val{3}}) = scountprimes3(start, stop)
scountprimes(start::Integer, stop::Integer, ::Type{Val{4}}) = scountprimes4(start, stop)
scountprimes(start::Integer, stop::Integer, ::Type{Val{5}}) = scountprimes5(start, stop)
scountprimes(start::Integer, stop::Integer, ::Type{Val{6}}) = scountprimes6(start, stop)

printprimes(stop::ConvT) = printprimes(conv128(stop))
printprimes(stop::ConvT, tuplet) = printprimes(conv128(stop), tuplet)
printprimes(stop::Integer) = printprimes(stop, Val{1})
printprimes(stop::Integer, ::Type{Val{1}}) = _printprimes(stop)
printprimes(stop::Integer, ::Type{Val{2}}) = printprimes2(stop)
printprimes(stop::Integer, ::Type{Val{3}}) = printprimes3(stop)
printprimes(stop::Integer, ::Type{Val{4}}) = printprimes4(stop)
printprimes(stop::Integer, ::Type{Val{5}}) = printprimes5(stop)
printprimes(stop::Integer, ::Type{Val{6}}) = printprimes6(stop)

printprimes(start::ConvT, stop::ConvT) = printprimes(conv128(start), conv128(stop))
printprimes(start::ConvT, stop::ConvT, tuplet) = printprimes(conv128(start), conv128(stop), tuplet)
printprimes(start::Integer, stop::Integer) = printprimes(start, stop, Val{1})
printprimes(start::Integer, stop::Integer, ::Type{Val{1}}) = _printprimes(start, stop)
printprimes(start::Integer, stop::Integer, ::Type{Val{2}}) = printprimes2(start, stop)
printprimes(start::Integer, stop::Integer, ::Type{Val{3}}) = printprimes3(start, stop)
printprimes(start::Integer, stop::Integer, ::Type{Val{4}}) = printprimes4(start, stop)
printprimes(start::Integer, stop::Integer, ::Type{Val{5}}) = printprimes5(start, stop)
printprimes(start::Integer, stop::Integer, ::Type{Val{6}}) = printprimes6(start, stop)
