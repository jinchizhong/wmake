module WMake
  module Algorithm
    def fill_logic_map logic_map, step
      dirt = false
      step.from.each do |a|
        step.to.each do |b|
          if not logic_map[[a, b]]
            logic_map[[a, b]] = step.compiler
            dirt = true
          elsif logic_map[[a, b]] != step.compiler
            die "Compiler conflict!"
          end
        end
      end
      return dirt
    end
    def gen_steps proj
      remain = proj.files
      COMPILERS.each do |compiler|
        remain = remain - compiler.filter(proj, proj.files)
      end
      die "WMake don't known how to process follow files: #{remain}" unless remain.empty?

      logic_map = {}  # [from, to] => compiler
      all_files = proj.files
      #p all_files
      dirt = true
      30.times do
        dirt = false
        COMPILERS.each do |compiler|
          #p all_files
          filtered = compiler.filter(proj, all_files)
          #p filtered
          compiler.steps(proj, filtered).each do |step|
            p step
            dirt ||= fill_logic_map logic_map, step
          end
        end
        break if not dirt

        logic_map.each do |x, c|
          all_files << x[0] << x[1]
        end
        all_files.uniq!
      end
      die "Compiler dead lock!" if dirt
      
      proj.products.each do |product|
        if not all_files.include? product
          die "Can not generate #{product}!"
        end
      end

      steps = []
      COMPILERS.each do |compiler|
        steps += compiler.steps(proj, compiler.filter(proj, all_files))
      end
      return steps
    end
  end
  
  include Core
end
