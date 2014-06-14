require 'wmake/core'

module WMake
  class LdCompiler < Compiler
    def initialize
      @exts = [".o"]
      @compiler_mode = :all_to_one      # :one_by_one, :all_to_one, :empty
      @output_extention = ""            # output extention
    end
    def get_output_fpath item
      return "bin/" + item.project.name
    end
  end
end
