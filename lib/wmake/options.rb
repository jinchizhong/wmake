module WMake
  class Options
    @@options = {}
    def self.declare_option attr, defval, access = :ro
      @@options[attr] = defval
      define_singleton_method attr do
        @@options[attr]
      end
      if access == :rw
        define_singleton_method (attr.to_s + "=").to_sym do |v|
          @@options[attr] = v
        end
      end
    end
    def self.init
      declare_option :source_root, CACHE[:source_root], :ro
      declare_option :build_root, CACHE[:build_root], :ro
      declare_option :main_wmake, CACHE[:main_wmake], :ro
      declare_option :cache_file, build_root + "/wmake.cache.yaml", :ro
      declare_option :projs_dir, build_root + "/wmake.projs", :ro
      declare_option :output_dir, build_root + "/wmake.output", :ro

      declare_option :exec_output_dir, output_dir + PLATFORM.default_exec_path, :rw
      declare_option :exclude_by_default, false, :rw
    end
  end
  
  OPTIONS = Options
end