using BinDeps

try
    eval(Expr(:import,:DeepConvert))
catch err
    Pkg.clone("https://github.com/Samayel/DeepConvert.jl")
    Pkg.build("DeepConvert")
end

const pkgdir = Pkg.dir("PrimeSieve")

# Find the directory with installed Julia libraries
julialibpath = dirname(Libdl.dlpath(Libdl.dlopen("libgmp")))

# Set link flags for Autotools external packages
# This is only needed for the ecm package
ENV["LDFLAGS"] = "-L$julialibpath"
# config.log shows that BinDeps also set the following as well.
# We have copied gmp.h from Julia source tree to this location.
# Maybe Julia should also copy it to the installation tree.
# ENV["CPPFLAGS"] = "-I../../usr/include"

# -Wl... makes the libecm search for libgmp in the Julia installation rather than the system.
# (The  -lgmp should not be neccessary, but it is.
# The Makefile writes -lgmp multiple times in link commands. -lm occurs five times per link command.)
ENV["LIBS"] = "-lgmp -Wl,-rpath -Wl,$julialibpath"

@BinDeps.setup

deps = [
    gmpecm = library_dependency("gmpecm", aliases = ["libecm"], os = :Unix)
    primesieve = library_dependency("primesieve", aliases = ["libprimesieve.so.7", "libprimesieve-7"])
    primecount = library_dependency("primecount", aliases = ["libprimecount.so.4", "libprimecount-4"], depends = [primesieve])
    cprimecount = library_dependency("cprimecount", aliases = ["libcprimecount"], depends = [primecount])
    smsieve = library_dependency("smsieve", aliases = ["libsmsieve"], depends = [gmpecm])
]

provides(Sources, URI("http://dl.bintray.com/kimwalisch/primesieve/primesieve-5.7.3.tar.gz"), primesieve, os = :Unix)
provides(Sources, URI("http://dl.bintray.com/kimwalisch/primecount/primecount-2.6.tar.gz"), primecount, os = :Unix)
provides(Sources, URI("https://gforge.inria.fr/frs/download.php/file/36224/ecm-7.0.4.tar.gz"), gmpecm, os = :Unix)
# Getting zip- or tarball from github with a predictable name is mysterious to me.
# But, pushing tags allows downloading this way...
provides(Sources, URI("https://github.com/jlapeyre/msieve-shared/archive/v0.0.3.tar.gz"), smsieve,unpacked_dir="msieve-shared-0.0.3", os = :Unix)

# The Autotools BuildProcess will try to download the source using the data above.
# It would not be hard to modify BinDeps to allow skipping the download.
provides(BuildProcess, Autotools(libtarget = ".libs/libecm."*BinDeps.shlib_ext, configure_options = [
    "--enable-shared",
    "--enable-openmp",
    "--with-gmp-lib=$julialibpath",
    "--with-gmp-include=$(joinpath(pkgdir, "deps", "src", "gmp"))"]), gmpecm, os = :Unix)
provides(BuildProcess, Autotools(libtarget = ".libs/libprimesieve."*BinDeps.shlib_ext), primesieve, os = :Unix)
provides(BuildProcess, Autotools(libtarget = ".libs/libprimecount."*BinDeps.shlib_ext), primecount, os = :Unix)

# BinDeps.depsdir(cprimecount) is /pathto/PackageName/deps
const cpcsrcdir = joinpath(BinDeps.depsdir(cprimecount),"src","cprimecount")
# This source for this library will not be downloaded; it is in this repo.
# BuildProcess and SimpleBuild may use the information in provides(Sources...
# Here, we need no such information, and so omit GetSources.
provides(SimpleBuild,
    (@build_steps begin
        ChangeDirectory(cpcsrcdir)
        `make`
        `make install`            
    end),cprimecount, os = :Unix)


# libsmsieve.so needs to know the location of libecm.so . Both are in deps/usr/lib .
# Since this is our own library, the hardcoded rpath is specified in the Makefile rather than
# passed via ENV as above.
smsrcdir = joinpath(BinDeps.depsdir(cprimecount),"src","msieve-shared-0.0.3")
provides(SimpleBuild,
         (@build_steps begin
             GetSources(smsieve)
             @build_steps begin
                 ChangeDirectory(smsrcdir)
                 `cp ../localmsieve/Makefile ../localmsieve/msieveshared.c .`
                 `make ECM=1  msieveshared`
                 `cp libsmsieve.so ../../usr/lib/libsmsieve.so`
             end
         end),smsieve, os = :Unix)

if Int == Int32
    provides(Binaries, Dict(URI("https://fs.quyo.net/lfs/julia/primesieve_deps_win32_p4_20170130155654.tar.gz") => deps), os = :Windows)
else
    provides(Binaries, Dict(URI("https://fs.quyo.net/lfs/julia/primesieve_deps_win64_k8-sse3_20170130155107.tar.gz") => deps), os = :Windows)
end

isdir(joinpath(pkgdir, "deps", "usr")) && rm(joinpath(pkgdir, "deps", "usr"), recursive=true)

@BinDeps.install Dict([(:gmpecm, :gmpecm),(:primecount, :primecount), (:primesieve, :primesieve),
                       (:cprimecount, :cprimecount), (:smsieve, :smsieve) ])
