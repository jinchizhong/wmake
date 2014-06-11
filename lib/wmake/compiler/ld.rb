module WMake
  class LdCompiler < Compiler
    def filter proj, files
      return files.keep_if { |f| f =~ /\.o$/ }
    end
    def group proj, files
      return { files => proj.product[0] }
    end
  end
  COMPILERS << LdCompiler.new
end
