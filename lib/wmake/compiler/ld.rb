require 'wmake/core'

module WMake
  class LdCompiler < Compiler
    def initialize
      @exts = [".o"]
      @compiler_mode = :all_to_one      # :one_by_one, :all_to_one, :empty
      @output_extention = ""            # output extention
    end
    def get_output_fpath item
      return PLATFORM.exec_prefix + item.project.name + PLATFORM.exec_suffix
    end
    def command_line job
      "g++ #{job.inputs.join ' '} -o #{job.outputs.first}"
    end
  end
end
