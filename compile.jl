using SnoopCompile

### Log the compiles
# This only needs to be run once (to generate "/tmp/comonicon_compiles.log")

SnoopCompile.@snoopc "/tmp/comonicon_compiles.log" begin
    using Comonicon
    include(joinpath(dirname(dirname(pathof(Comonicon))), "test", "runtests.jl"))
end

### Parse the compiles and generate precompilation scripts
# This can be run repeatedly to tweak the scripts

data = SnoopCompile.read("/tmp/comonicon_compiles.log")

pc = SnoopCompile.parcel(reverse!(data[2]))
SnoopCompile.write("/tmp/precompile", pc)
