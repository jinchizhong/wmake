require 'wmake/options'

module WMake
  PROJECTS = {}
  class Project
    def self.option_attr attr
      define_method attr do
        if not @options.has_key? attr
          v = WMake::OPTIONS.send(attr)
          v = v.dup if v.class.respond_to? :new
          @options[attr] = v
        end
        @options[attr]
      end
      define_method (attr.to_s + "=").to_sym do |v|
        @options[attr] = v
      end
    end
    def initialize name, type = :exec, &block
      die "Project named \"#{name}\" already exists!" if PROJECTS[name]
      die "Unknown project type: #{type}" unless [:exec].include? type
      die "Project without config!" unless block
      PROJECTS[name] = self
      @name = name
      @type = type
      @block = block
      @wmake = PROJECT_LOADER.loading_stack.last
      
      @files = []
      @depends = []
      @compilers = TOOLCHAIN.compilers.dup
      @options = {}
    end
    attr_reader :name
    attr_reader :type
    attr_reader :files
    attr_reader :depends
    option_attr :exec_output_dir
    option_attr :exclude_by_default
    
    def configure
      instance_eval &@block
    end
    def add *args
      @files += args
    end
    def pre_check_files
      [@wmake]
    end
    def products
      [PLATFORM.exec_prefix + name + PLATFORM.exec_suffix]
    end
    def dir
      File.dirname @wmake
    end
    def compilers
      @compilers
    end
  end
end
