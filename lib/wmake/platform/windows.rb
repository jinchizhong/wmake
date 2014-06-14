module WMake
  class PlatformWindows
    def app_name basename
      basename + ".exe"
    end
    def lib_name basename
      basename + ".dll"
    end
    def is_absolute_path fpath
      !!(fpath =~ /^[a-zA-Z]:[\/\\]/)
    end
  end
  PLATFORM = PlatformWindows.new
end
