module WMake
  class Find
    def initialize 
      @cache = {}
    end
    def find k
      if not @cache[k]
        require 'wmake/find/' + k
        raise "find #{k} failed!" if not @cache['find/' + k]
      end
      return @cache['find/' + k]
    end
    alias :"[]" :find
    def []= k, v
      @cache['find/' + k] = v
    end
  end
  FIND = Find.new
end