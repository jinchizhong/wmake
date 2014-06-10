module WMake
  class Front
    def load fpath
      instance_eval File.read(fpath), fpath
    end
    def project name, type
      raise "TODO"
    end
  end
  FRONT = Front.new
end

