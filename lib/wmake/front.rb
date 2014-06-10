module WMake
  class Front
    def load fpath
      instance_eval File.read(fpath), fpath
    end
    def project name, type, &block
      WMake::Project.new name, type, &block
    end
  end
  FRONT = Front.new
end

