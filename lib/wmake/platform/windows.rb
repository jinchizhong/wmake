module WMake
  class PlatformWindows
    def is_absolute_path fpath
      !!(fpath =~ /^[a-zA-Z]:[\/\\]/)
    end
    def default_toolchain
      "msvc"
    end
    def default_exec_path
      ""
    end
    def exec_prefix
      ""
    end
    def exec_suffix
      ".exe"
    end
  end
  PLATFORM = PlatformWindows.new
end
