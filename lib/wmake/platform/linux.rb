module WMake
  class PlatformLinux
    def windows?
      false
    end
    def is_absolute_path fpath
      !!(fpath =~ /^\//)
    end
    def default_toolchain
      "gcc"
    end
    def default_exec_path
      "/bin"
    end
    def exec_prefix
      ""
    end
    def exec_suffix
      ""
    end
  end
  PLATFORM = PlatformLinux.new
end
