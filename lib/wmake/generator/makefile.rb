require 'fileutils'
require 'wmake/tools/cref'

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
      gen_main_makefile
      gen_root_makefile
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
      CREF.get_refs fpath, []
    end
    def intermediate_filename str
      "intermediate/" + str.gsub("..", "__")
    end
    def get_file_location proj, f
      return f if f =~ /^\//
      return proj.dir + "/" + f if proj.files.include?(f)
      OPTIONS.projs_dir + "/" + proj.name + "/" + intermediate_filename(f)
    end
    def gen_project proj
      src_dir = proj.dir
      bin_dir = OPTIONS.projs_dir + "/" + proj.name
      makefile_file = bin_dir + "/Makefile"
      products = proj.products
      FileUtils.mkdir_p bin_dir

      lines = []
      steps = WMake.gen_steps proj
      lines << ".PHONY: all"
      lines << ""
      lines << "all: #{proj.name}"
      lines << ""
      lines << "#{proj.name}: #{products.join ' '}"
      lines << ""
      steps.each do |step|
        next if step.from.empty? or step.to.empty?
        lines << "#{step.to.collect{|x| get_file_location(proj, x)}.join ' '}: #{step.from.collect{|x| get_file_location(proj, x)}.join ' '}"
        lines << "\t#{step.compiler.command_line proj, step}"
        lines << ""
      end

      try_write makefile_file, lines.join("\n")
    end
    def gen_main_makefile
      makefile_file = OPTIONS.projs_dir + "/Makefile"
      def_prjs = PROJECTS.values.delete_if {|prj| prj.exclude_by_default}.collect{|prj| prj.name}
      all_prjs = PROJECTS.keys
      
      lines = []
      lines << "all: #{def_prjs.join ' '}"
      lines << ""
      lines << ".PHONY: #{all_prjs.collect{|x| "#{x} #{x}/clean #{x}/build"}.join ' '}"
      lines << ""
      lines << "clean: #{def_prjs.collect{|x| x + "/clean"}.join ' '}"
      lines << ""
      PROJECTS.each_value do |prj|
        lines << "#{prj.name}: #{prj.depends.join ' '}" unless prj.depends.empty?
        lines << "#{prj.name}: #{prj.products.join ' '}"
        lines << ""
        prj.products.each do |product|
          lines << "#{product}: #{prj.name}/build"
          lines << ""
        end
        lines << "#{prj.name}/build:"
        lines << "\tcd #{prj.name} && make"
        lines << ""
        lines << "#{prj.name}/clean: #{prj.depends.collect{|x| x + "/clean"}.join ' '}"
        lines << "\tcd #{prj.name} && make clean"
        lines << ""
      end

      try_write makefile_file, lines.join("\n")
    end
    def gen_root_makefile
      makefile_file = OPTIONS.binary_root + "/Makefile"
      prjs_dir = OPTIONS.projs_dir

      targets = ["all", "clean"]
      PROJECTS.each_key do |prj|
        targets << prj << "#{prj}/clean"
      end
      
      lines = []
      targets.each do |target|
        lines << "#{target}: "
        lines << "\tcd \"#{prjs_dir}\" && make #{target}"
        lines << ""
      end
      lines << "dist-clean: "
      lines << "\trm -rf \"#{OPTIONS.projs_dir}\""
      lines << "\trm -rf \"#{OPTIONS.cache_file}\""
      lines << "\trm -rf Makefile"
      lines << ""
      lines << "clean-all: dist-clean"
      lines << "\trm -rf \"#{OPTIONS.output_dir}\""
      lines << ""

      try_write makefile_file, lines.join("\n")
    end
  end
  GENERATOR = MakefileGen.new
end
