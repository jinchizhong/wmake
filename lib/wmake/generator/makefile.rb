require 'fileutils'

module WMake
  class MakefileGen
    def escape str
      # TODO
      str
    end
    def try_write fpath, cont
      old_cont = File.read(fpath) if File.exists? fpath
      if old_cont != cont
        open(fpath, "w") do |fd|
          fd.write cont
        end
      end
    end
    def touch fpath
      FileUtils.touch fpath
    end
    def gen
      FileUtils.mkdir_p OPTIONS.projs_dir

      gen_pre_check
      PROJECTS.each_value do |proj|
        gen_project proj
      end
    end
    def gen_pre_check
      prj_dir = OPTIONS.projs_dir + "/pre_check"
      stamp_file = prj_dir + "/timestamp"
      makefile_file = prj_dir + "/Makefile"
      FileUtils.mkdir_p prj_dir

      lines = []
      lines << "all: #{escape stamp_file}" << ""
      PROJECTS.each do |name, proj|
        proj.pre_check_files.each do |f|
          lines << "#{escape stamp_file}: #{escape f}"
        end
      end
      lines << "\tcd ../..; wmake ."
      lines << ""
      try_write makefile_file, lines.join("\n")

      touch stamp_file
    end
    def get_file_depends fpath
      # TODO
      []
    end
    def gen_project proj
      prj_dir = OPTIONS.projs_dir + "/" + proj.name
      makefile_file = prj_dir + "/Makefile"
      app_name = PLATFORM.app_name proj.name
      FileUtils.mkdir_p prj_dir

      lines = []
      lines << "all: #{app_name}"
      lines << ""
      proj.files.each do |fpath|
        # TODO
        deps = get_file_depends fpath
        deps.each do |dep|
          lines << "#{fpath}.o: #{dep}"
        end
        lines << "#{fpath}.o: #{fpath}"
        lines << "\tgcc -c #{fpath} -o #{fpath}.o"
        lines << ""
      end
      lines << ""
      try_write makefile_file, lines.join("\n")
    end
  end
  GENERATOR = MakefileGen.new
end
