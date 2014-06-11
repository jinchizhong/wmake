Gem::Specification.new do |s|
  s.name = 'wmake'
  s.version = '0.0.1'
  s.summary = "WPS Make system"
  s.description = "WPS Make system"
  s.authors = ["Chizhong Jin"]
  s.email = "jinchizhong@kingsoft.com"
  s.files = [
    "bin/wmake",
    "lib/wmake.rb",
    "lib/wmake/core.rb",
    "lib/wmake/front.rb",
    "lib/wmake/project.rb",
    "lib/wmake/compiler.rb",
    "lib/wmake/generator/makefile.rb",
    "lib/wmake/platform/linux.rb",
    "lib/wmake/tools/cref.rb",
    "lib/wmake/toolchains/gcc.rb",
    "lib/wmake/compiler/gcc.rb",
    "lib/wmake/compiler/ld.rb",
  ]
  s.executables << 'wmake'
  s.homepage = 'http://www.wps.com'
  s.license = 'BSD'
end
