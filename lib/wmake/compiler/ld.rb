require 'wmake/compiler'

module WMake
  class LdCompiler < Compiler
    def filter proj, files
      return files.dup.keep_if { |f| f =~ /\.o$/ }
    end
    def steps proj, files
      [Step.new(files, [proj.products[0]], self)]
    end
    def command_line proj, step
      "g++ #{step.from.collect{|x| GENERATOR.get_file_location proj, x}.join ' '} -o #{step.to[0]}"
    end
  end
  COMPILERS << LdCompiler.new
end
