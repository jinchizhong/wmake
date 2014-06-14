module WMake
  def self.fill_logic_map logic_map, job
    dirt = false
    job.inputs.each do |a|
      job.outputs.each do |b|
        if not logic_map[[a, b]]
          logic_map[[a, b]] = job.compiler
          dirt = true
        elsif logic_map[[a, b]] != job.compiler
          die "Compiler conflict!"
        end
      end
    end
    return dirt
  end
  def self.get_all_fileitems proj
    proj.files.collect do |f|
      FileItem.new proj, f, :source
    end
  end
  def self.check_all_file_refed_by_compiler proj
    remain = get_all_fileitems proj
    proj.compilers.each do |compiler|
      remain = remain - compiler.filter(remain)
    end
    die "WMake don't known how to process follow files: #{remain}" unless remain.empty?
  end
  def self.gen_jobs proj
    check_all_file_refed_by_compiler proj
    
    all_files = get_all_fileitems proj
    logic_map = {}  # [from, to] => compiler
    
    dirt = true
    30.times do
      dirt = false
      proj.compilers.each do |compiler|
        #p all_files
        filtered = compiler.filter(all_files)
        #p filtered
        compiler.jobs(filtered).each do |job|
          dirt ||= fill_logic_map logic_map, job
        end
      end
      break if not dirt

      logic_map.each do |x, c|
        all_files << x[0] << x[1]
      end
      all_files.uniq!
    end
    die "Compiler dead lock!" if dirt
 
    jobs = proj.compilers.collect do |compiler|
      compiler.jobs(compiler.filter(all_files))
    end.flatten

    proj.products.each do |product|
      fitem_matched = nil
      jobs.each do |job| 
        job.outputs.each do |x| 
          fitem_matched = x if x.fpath == product and x.type == :intermediate 
        end
      end
      if fitem_matched
        fitem_matched.type = :product
      else
        die "Can not generate #{product} by any way!"
      end
    end
    
    jobs
  end
end
