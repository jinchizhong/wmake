require 'yaml'
require 'wmake/algorithm'
require 'wmake/project'

module WMake
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
    PROJECT_LOADER.load fpath
  end
  def self.configure
    PROJECTS.each do |name, proj|
      proj.configure
    end
  end
  def self.generate
    GENERATOR.generate
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
  
  class ProjectLoader
    def initialize
      @loading_stack = []
    end
    attr_reader :loading_stack
    def load fpath
      @loading_stack << fpath
      instance_eval File.read(fpath), fpath
      @loading_stack.pop
    end
    def project name, type, &block
      Project.new name, type, &block
    end
  end
  
  FileItem = Struct.new :project, :fpath, :type  # type => :source, :intermediate, :product
  class FileItem
    def source?
      (self.type == :source)
    end
    def generated?
      (self.type == :intermediate or self.type == :product?)
    end
    def intermediate?
      (self.type == :intermediate)
    end
    def product?
      (self.type == :product)
    end
    def inspect
      "{FileItem: project => #{project.name}, fpath => #{fpath}, type => #{type}}"
    end
    def to_s
      inspect
    end
  end
  
  Job = Struct.new :project, :inputs, :outputs, :compiler
  class Job
    def command_line
      raise "todo"
    end
  end
  
  class Compiler
    def initialize
      # You have to change follow variants in inherted class
      # or reimplement methods for advance
      @exts = []
      @compiler_mode = :one_by_one      # :one_by_one, :all_to_one, :empty
      @output_extention = nil           # output extention
    end
    attr_accessor :exts
    attr_accessor :compiler_mode
    attr_accessor :output_name
    def filter inputs
      # default implement, you can reimplement it if necessary
      # filter files by @exts
      outputs = []
      inputs.each do |item|
        outputs << item if @exts.include?(File.extname item.fpath)
      end
      outputs
    end
    def jobs inputs
      # default implement, you can reimplement it if necessary
      jobs = []
      if @compiler_mode == :one_by_one
        inputs.each do |item|
          output = FileItem.new(item.project, get_output_fpath(item), :intermediate)
          jobs << Job.new(item.project, [item], [output], self)
        end
      elsif @compiler_mode == :all_to_one
        if not inputs.empty?
          output = FileItem.new(inputs.first.project, get_output_fpath(inputs.first), :intermediate)
          jobs << Job.new(inputs.first.project, inputs, [output], self)
        end
      elsif @compiler_mode == :empty
        # do nothing
      else
        raise "Unknown compiler mode"
      end
      jobs
    end
    def get_output_fpath item
      # default implement, you can reimplement it if necessary
      if @compiler_mode == :one_by_one
        return item.fpath + @output_extention
      elsif @compiler_mode == :all_to_one
        return item.project.name + @output_extention
      else
        raise "Unknown compiler mode"
      end
    end
    def command_line
      # no implement, you have to reimplement it
      raise "You have to reimplement this method"
    end
  end
  
  class ToolChain
    def initialize
      @compilers = []
    end
    attr_accessor :compilers
  end

  CACHE = Cache.new
  OPTIONS = Options.new
  PROJECT_LOADER = ProjectLoader.new
  TOOLCHAIN = ToolChain.new
end

