module WMake
  class GccCompiler < Compiler
    def filter proj, files
      return files.keep_if { |f| f =~ /\.c$|\.cpp$|\.cxx$|\.cc$|\.C$/ }
    end
    def group proj, files
      result = {}
      files.each do |f|
        result[f] = "#{f}.o"
      end
      return result
    end
  end
  COMPILERS << GccCompiler.new

  # a fake compiler, do nothing
  class GccHeaderCompiler < Compiler
    def filter proj, files
      return files.keep_if { |f| f =~ /\.h$|\.hpp$|\.hxx$|\.hh$|\.H$/ }
    end
    def group proj, files
      return {files => []}
    end
  end
  COMPILERS << GccHeaderCompiler.new
end
