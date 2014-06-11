require 'yaml'

module WMake
  class Cache 
    def initialize 
      @cache = {}
    end
    def load fpath
      @cache = YAML.load_file fpath
    end
    def save fpath
      open(fpath, "w") do |fd|
        fd.write @cache.to_yaml
      end
    end
    def [] k
      @cache[k]
    end
    def []= k, v
      @cache[k] = v
    end
  end
  CACHE = Cache.new

  class Options
    attr_accessor :source_root
    attr_accessor :binary_root
    attr_accessor :main_wmake
    attr_accessor :cache_file
    def projs_dir
      binary_root + "/wmake.projs"
    end
    def output_dir
      binary_root + "/wmake.output"
    end
  end
  OPTIONS = Options.new

  def self.load_generator gen_name
    require 'wmake/generator/' + gen_name
  end
  def self.load_platform plat_name
    require 'wmake/platform/' + plat_name
  end
  def self.load_toolchains toolchains_name
    require 'wmake/toolchains/' + toolchains_name
  end
  def self.init_wmake source_root, binary_root, wmake_file
    CACHE[:source_root] = OPTIONS.source_root = File.expand_path(source_root)
    CACHE[:binary_root] = OPTIONS.binary_root = File.expand_path(binary_root)
    CACHE[:main_wmake] = OPTIONS.main_wmake = File.expand_path(wmake_file)
    OPTIONS.cache_file = OPTIONS.binary_root + "/wmake.cache.yaml"
  end
  def self.load fpath
    FRONT.load fpath
  end
  def self.configure
    PROJECTS.each do |name, proj|
      proj.configure
    end
  end
  def self.gen
    GENERATOR.gen
  end
  def self.save_cache
    CACHE.save OPTIONS.cache_file
  end

  def self.help
    puts "Usage: wmake <path_to_source_dir_or_binary_dir_or_wmake_file> [args...]"
    exit 0
  end
  def self.die msg, code = 1
    $stderr.puts msg
    exit code
  end
end

require 'wmake/front'
require 'wmake/project'
