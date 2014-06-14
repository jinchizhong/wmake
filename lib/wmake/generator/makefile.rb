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
    def generate
      FileUtils.mkdir_p OPTIONS.projs_dir

      gen_pre_check
      PROJECTS.each_value do |proj|
        gen_project proj
      end
      gen_main_makefile
      gen_root_makefile
    end
    def format_targets targets
      targets = [targets] unless targets.is_a? Array
      targets.collect do |t|
        if t.is_a? FileItem
          t.absolute
        else
          t
        end
      end.join " "
    end
    def gen_target outputs, refs, cmds = []
      cmds = [cmds] unless cmds.is_a? Array
      
      lines = []
      lines << format_targets(outputs) + ": " + format_targets(refs)
      lines += cmds.collect { |cmd| "\t" + cmd }
      lines << ""
      lines
    end
    def gen_pre_check
      prj_dir = OPTIONS.projs_dir + "/pre_check"
      stamp_file = prj_dir + "/timestamp"
      makefile_file = prj_dir + "/Makefile"
      FileUtils.mkdir_p prj_dir

      lines = []
      lines << gen_target("all", stamp_file)
      prechks = PROJECTS.values.collect do |prj| 
        prj.pre_check_files.collect do |f|
          File.expand_path f, prj.dir
        end
      end.flatten
      lines << gen_target(stamp_file, prechks, "cd ../../; wmake .")
      
      try_write makefile_file, lines.join("\n")
      touch stamp_file
    end
    def gen_project proj
      src_dir = proj.dir
      bin_dir = OPTIONS.projs_dir + "/" + proj.name
      makefile_file = bin_dir + "/Makefile"
      FileUtils.mkdir_p bin_dir

      jobs = WMake.gen_jobs proj
      products = []
      dirs_need_to_gen = []
      products = jobs.collect {|job| job.outputs.select{|item| item.product?}}.flatten
      jobs.each do |job|
        job.outputs.each do |item|
          products << item if item.product?
          dirs_need_to_gen << File.dirname(item.absolute) if item.type != :source
        end
      end
      dirs_need_to_gen.uniq!

      lines = []
      lines << gen_target(".PHONY", ["all", proj.name])
      lines << gen_target("all", proj.name)
      dirs_need_to_gen.each do |dir|
        lines << gen_target(dir, [], "mkdir -p \"#{dir}\"")
      end
      lines << gen_target(proj.name, products)
      jobs.each do |job|
        next if job.inputs.empty? or job.outputs.empty?
        dir_deps = job.outputs.collect{|item| File.dirname(item.absolute)}.uniq
        lines << gen_target(job.outputs, dir_deps + job.inputs, job.command_line)
      end

      try_write makefile_file, lines.join("\n")
    end
    def all_product_fileitems proj
      proj.products.collect do |product|
        FileItem.new proj, product, :product
      end
    end
    def gen_main_makefile
      makefile_file = OPTIONS.projs_dir + "/Makefile"
      def_prjs = PROJECTS.values.delete_if {|prj| prj.exclude_by_default}.collect{|prj| prj.name}
      all_prjs = PROJECTS.keys
      
      lines = []
      lines << gen_target(".PHONY", ["all", "clean"] + all_prjs.collect{|x| [x, x + "/clean",  x + "/build"]}.flatten)
      lines << gen_target("all", def_prjs)
      lines << gen_target("clean", def_prjs.collect{|x| x + "/clean"})
      lines << gen_target("pre_check", [], "cd pre_check && $(MAKE)")
      PROJECTS.each_value do |prj|
        products = all_product_fileitems prj
        lines << gen_target(prj.name, prj.depends + products)
        lines << gen_target(products, prj.name + "/build")
        lines << gen_target(prj.name + "/build", ["pre_check"], "cd #{prj.name} && $(MAKE)")
        lines << gen_target(prj.name + "/clean", [], "cd #{prj.name} && $(MAKE) clean")
      end

      try_write makefile_file, lines.join("\n")
    end
    def gen_root_makefile
      makefile_file = OPTIONS.binary_root + "/Makefile"
      prjs_dir = OPTIONS.projs_dir

      targets = ["all", "clean"] + PROJECTS.keys.collect{|x| [x, x + "/clean"]}.flatten
      
      lines = []
      targets.each do |target|
        lines << gen_target(target, [], "cd \"#{prjs_dir}\" && $(MAKE) #{target}")
      end
      lines << gen_target("dist-clean", [], ["rm -rf \"#{OPTIONS.projs_dir}\"", "rm -rf \"#{OPTIONS.cache_file}\"", "rm -rf Makefile"])
      lines << gen_target("clean-all", [], "rm -rf \"#{OPTIONS.output_dir}\"")

      try_write makefile_file, lines.join("\n")
    end
  end
  GENERATOR = MakefileGen.new
end
