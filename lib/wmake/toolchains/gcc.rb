require 'wmake/compiler/gcc'
require 'wmake/compiler/ld'

module WMake
  TOOLCHAIN.compilers << GccCompiler.new
  TOOLCHAIN.compilers << GccHeaderCompiler.new
  TOOLCHAIN.compilers << LdCompiler.new
end