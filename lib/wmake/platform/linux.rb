module WMake
  class PlatformLinux
    def app_name basename
      basename
    end
    def lib_name basename
      "lib" + basename + ".so"
    end
  end
  PLATFORM = PlatformLinux.new
end
