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
    def intermediate_filename str
      "intermediate/" + str.gsub("..", "__") + ".o"
    end
    def gen_project proj
      src_dir = proj.dir
      bin_dir = OPTIONS.projs_dir + "/" + proj.name
      makefile_file = bin_dir + "/Makefile"
      products = proj.products
      product = products.first
      FileUtils.mkdir_p bin_dir

      obj_files = []

      lines = []
      lines << "all: #{products.join ' '}"
      lines << ""
      proj.files.each do |fpath|
        # TODO
        deps = get_file_depends fpath
        in_file = File.expand_path fpath, src_dir
        out_file = intermediate_filename fpath
        deps.each do |dep|
          lines << "#{out_file}: #{File.expand_path dep, src_dir}"
        end
        lines << "#{out_file}: mkdirs #{in_file}"
        lines << "\tgcc -c #{in_file} -o #{out_file}"
        lines << ""
        obj_files << out_file
      end
      lines << "mkdirs: "
      (obj_files + products).collect{|f| File.dirname f}.uniq.each do |dir|
        lines << "\tmkdir -p #{dir}"
      end
      lines << ""
      obj_files.each do |obj|
        lines << "#{product}: #{obj}"
      end
      lines << "\tgcc #{obj_files.join ' '} -o #{product}"
      lines << ""
      lines << ""
      try_write makefile_file, lines.join("\n")
    end
  end
  GENERATOR = MakefileGen.new
end
