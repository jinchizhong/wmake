require 'wmake/core'

module WMake
  class MsvcClCompiler < Compiler
    def initialize
      @exts = [".c", ".cpp", ".cxx", ".cc", ".C"]
      @compiler_mode = :one_by_one      # :one_by_one, :all_to_one, :empty
      @output_extention = ".obj"        # output extention      
    end
    def command_line job
      "cl /c #{job.inputs.join ' '} /Fo#{job.outputs.first}" 
    end
  end
  
  # a fake compiler, do nothing
  class MsvcHeaderCompiler < Compiler
    def initialize
      @exts = [".h", ".hpp", ".hxx", ".hh", ".H"]
      @compiler_mode = :empty           # :one_by_one, :all_to_one, :empty
      @output_extention = nil           # output extention
    end
  end
  
  class MsvcLinkCompiler < Compiler
    def initialize
      @exts = [".obj"]
      @compiler_mode = :all_to_one      # :one_by_one, :all_to_one, :empty
      @output_extention = ""            # output extention
    end
    def get_output_fpath item
      return PLATFORM.exec_prefix + item.project.name + PLATFORM.exec_suffix
    end
    def command_line job
      "link #{job.inputs.join ' '} /OUT:#{job.outputs.first}"
    end
  end
end