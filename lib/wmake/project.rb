module WMake
  PROJECTS = {}
  class Project
    def initialize name, type = :exec, &block
      WMake.die "Project named \"#{name}\" already exists!" if WMake::PROJECTS[name]
      WMake.die "Unknown project type: #{type}" unless [:exec].include? type
      WMake.die "Project no config!" unless block
      PROJECTS[name] = self
      @name = name
      @type = type
      @block = block
    end
  end
end
