module WMake
  COMPILERS = []

  class Compiler
    def filter proj, files
      # [in]  files in project
      # [out] files this compiler need to deal
      # You have to reimplement this method for a new compiler
      return []
    end
    def group proj, files
      # [in]  files need to compiler
      # [out] groups for compiler unit   {in_files => out_files, ...} in_files and out_files can be String or Array
      # You have to reimplement this method for a new compiler
    end
    def transfer proj, files
      # [in]  input files
      # [out] generated files
      # In most cases, you do not need to reimplement this function
      out = []
      group(proj, files).each do |f, t|
        out +=  t
      end
      return out
    end
  end
end
