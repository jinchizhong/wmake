require 'find'

libs = Find.find("lib").to_a.grep /\.rb$/

Gem::Specification.new do |s|
  s.name = 'wmake'
  s.version = '0.0.1'
  s.summary = "Designed for WPS"
  s.description = "Still in working"
  s.authors = ["Chizhong Jin"]
  s.email = "jinchizhong@kingsoft.com"
  s.files = libs + [
    "bin/wmake",
  ]
  s.executables << 'wmake'
  s.homepage = 'http://www.wps.com'
  s.license = 'BSD'
end
