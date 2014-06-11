module WMake
  def self.fill_logic_map logic_map, f, t, compiler
    dirt = false
    f = [f] if f.class != Hash
    t = [t] if t.class != Hash
    f.each do |a|
      t.each do |b|
        if not logic_map[[a, b]]
          logic_map[[a, b]] = compiler
          dirt = true
        elsif logic_map[[a, b]] != compiler
          die "Compiler conflict!"
        end
      end
    end
    return dirt
  end
  def self.gen_steps proj
    remain = proj.files
    COMPILERS.each do |compiler|
      remain -= compiler.filter proj.files
    end
    die "WMake don't known how to process follow files: #{remain}" unless remain.empty?

    logic_map = {}  # [from, to] => compiler
    all_files = []
    dirt = true
    30.times do
      dirt = false
      COMPILERS.each do |compiler|
        compiler.group(proj, compiler.filter(all_files)).each do |f, t|
          dirt ||= fill_logic_map logic_map, f, t, compiler
        end
      end
      break if not dirt

      logic_map.each do |x|
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
      compiler.group(proj, compiler.filter(all_files)).each do |f, t|
        steps << [f, t, compiler]
      end
    end
  end
end
