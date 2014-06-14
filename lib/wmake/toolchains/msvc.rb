require 'wmake/compiler/msvc'

module WMake
  TOOLCHAIN.compilers << MsvcClCompiler.new
  TOOLCHAIN.compilers << MsvcHeaderCompiler.new
  TOOLCHAIN.compilers << MsvcLinkCompiler.new
end