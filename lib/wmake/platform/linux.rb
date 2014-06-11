module WMake
  class PlatformLinux
    def app_name basename
      basename
    end
    def lib_name basename
      "lib" + basename + ".so"
    end
    def products proj
      case proj.type
      when :exec
        [OPTIONS.output_dir + "/bin/" + proj.name]
      else
        raise "TODO"
      end
    end
  end
  PLATFORM = PlatformLinux.new
end
