require 'yaml'
require 'wmake/platform'
require 'wmake/algorithm'
require 'wmake/project'
require 'wmake/options'

module WMake
  def self.load_generator gen_name
    require 'wmake/generator/' + gen_name
  end
  def self.load_toolchain toolchains_name
    require 'wmake/toolchains/' + toolchains_name
  end
  def self.init_wmake source_root, build_root, wmake_file
    CACHE[:source_root] = File.expand_path(source_root)
    CACHE[:build_root] = File.expand_path(build_root)
    CACHE[:main_wmake] = File.expand_path(wmake_file)
    OPTIONS.init
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
    def absolute
      case type
      when :source
        File.expand_path(fpath, project.dir)
      when :intermediate
        File.expand_path(fpath.gsub("..", "__"), OPTIONS.projs_dir + "/" + project.name + "/intermediate")
      when :product
        File.expand_path(fpath, project.exec_output_dir)
      else
        raise "Unknown FileItem type: #{type}"
      end
    end
    def inspect
      "{FileItem: project => #{project.name}, fpath => #{fpath}, type => #{type}}"
    end
    def to_s
      absolute
    end
  end
  
  Job = Struct.new :project, :inputs, :outputs, :compiler
  class Job
    def command_line
      compiler.command_line self
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
    def command_line job
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
  PROJECT_LOADER = ProjectLoader.new
  TOOLCHAIN = ToolChain.new
end

