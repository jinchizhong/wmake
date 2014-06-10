module WMake
  class Front
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
      WMake::Project.new name, type, &block
    end
    def configure
      WMake::PROJECTS.each_value do |proj|
        proj.configure
      end
    end
  end
  FRONT = Front.new
end

