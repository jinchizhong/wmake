require 'wmake/platform'

module WMake
  class CRef
    def initialize
      @result_cache = {}
      @file_incs_cache = {}
      @is_file_cache = {}
      @deal_stack = []
      @@exclude_system = true
    end
    def get_includes fpath
      if @file_incs_cache[fpath]
        return @file_incs_cache[fpath]
      end

      incs = []
      cont = File.read fpath
      begin
        cont.scan /^\s*#\s*include\s*([<"])(.*?)[">]\s*$/ do 
          type = ($~[1] == "<") ? :angle : :quote
          filename = $~[2]
          incs << [filename, type]
        end
      rescue 
      end

      @file_incs_cache[fpath] = incs
      return incs
    end
    def is_file? fpath
      @is_file_cache[fpath] = File.file? fpath unless @is_file_cache.include? fpath
      return @is_file_cache[fpath]
    end
    def match_file this_file, inc, inc_dirs
      if inc[1] == :quote
        search_dirs = [File.dirname(this_file)] + inc_dirs
      else
        search_dirs = inc_dirs
      end
      search_dirs.each do |dir|
        fn = File.expand_path inc[0], dir
        return fn if is_file? fn
      end
      return nil
    end
    def exclude? fn
      if @@exclude_system 
        if fn =~ /^\/usr\//
          return true
        end
      end
      return false
    end
    def get_refs fpath, inc_dirs
      raise "test" if $cnt == 100
      raise "This function need absolute path!" unless PLATFORM.is_absolute_path fpath
      if @result_cache[[fpath, inc_dirs]]
        return @result_cache[[fpath, inc_dirs]]
      end

      return [] if @deal_stack.grep(fpath).length == 2
      @deal_stack << fpath

      ref_files = []
      inc_files = get_includes fpath
      inc_files.each do |inc|
        fn = match_file fpath, inc, inc_dirs
        next if exclude? fn
        ref_files += get_refs(fn, inc_dirs) if fn
      end
      ref_files << fpath
      ref_files.uniq!

      @deal_stack.pop

      @result_cache[[fpath, inc_dirs]] = ref_files
      return ref_files
    end
  end
  CREF = CRef.new
end
