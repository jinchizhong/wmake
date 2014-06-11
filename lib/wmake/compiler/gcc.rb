require 'wmake/compiler'

module WMake
  class GccCompiler < Compiler
    def filter proj, files
      files.dup.keep_if { |f| f =~ /\.c$|\.cpp$|\.cxx$|\.cc$|\.C$/ }
    end
    def steps proj, files
      files.collect do |f|
        Step.new([f], ["#{f}.o"], self)
      end
    end
    def command_line proj, step
      "g++ -c #{step.from.collect{|x| GENERATOR.get_file_location proj, x}.join ' '} -o #{GENERATOR.get_file_location proj, step.to[0]}"
    end
  end
  COMPILERS << GccCompiler.new

  # a fake compiler, do nothing
  class GccHeaderCompiler < Compiler
    def filter proj, files
      return files.dup.keep_if { |f| f =~ /\.h$|\.hpp$|\.hxx$|\.hh$|\.H$/ }
    end
    def steps proj, files
      [Step.new([files], [], self)]
    end
    def command_line proj, step
    end
  end
  COMPILERS << GccHeaderCompiler.new
end
