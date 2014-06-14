require 'wmake/core'

module WMake
  class GccCompiler < Compiler
    def initialize
      @exts = [".c", ".cpp", ".cxx", ".cc", ".C"]
      @compiler_mode = :one_by_one      # :one_by_one, :all_to_one, :empty
      @output_extention = ".o"          # output extention
    end
    def command_line job
      "g++ #{job.inputs.join ' '} -c -o #{job.outputs.first}"
    end
  end

  # a fake compiler, do nothing
  class GccHeaderCompiler < Compiler
    def initialize
      @exts = [".h", ".hpp", ".hxx", ".hh", ".H"]
      @compiler_mode = :empty           # :one_by_one, :all_to_one, :empty
      @output_extention = nil           # output extention
    end
  end
end
