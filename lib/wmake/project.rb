module WMake
  PROJECTS = {}
  class Project
    def initialize name, type = :exec, &block
      WMake.die "Project named \"#{name}\" already exists!" if WMake::PROJECTS[name]
      WMake.die "Unknown project type: #{type}" unless [:exec].include? type
      WMake.die "Project without config!" unless block
      PROJECTS[name] = self
      @name = name
      @type = type
      @block = block
      @wmake = WMake::FRONT.loading_stack.last
      @files = []
    end
    def configure
      instance_eval &@block
    end
    def add *args
      @files += args
    end
  end
end
