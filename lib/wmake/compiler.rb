module WMake
  Step = Struct.new :from, :to, :compiler

  COMPILERS = []

  class Compiler
    def filter proj, files
      # [in]  files in project
      # [out] files this compiler need to deal
      # You have to reimplement this method for a new compiler
      raise 'You have to implement this method'
    end
    def steps proj, files
      # [in]  files need to compiler
      # [out] groups for compiler unit   [Step, ...]
      # You have to reimplement this method for a new compiler
      raise 'You have to implement this method'
    end
    def command_line proj, step
      raise 'You have to implement this method'
    end
  end
end
