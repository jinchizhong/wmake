require 'fileutils'

task :default => :build do
end

desc "build gem"
task :build => :clean do
  system("gem build *.gemspec")
end

task :clean do
  FileUtils.rm Dir.glob("*.gem")
end

task :install => :build do 
  system("gem install ./*.gem")
end

task :uninstall do 
  system("gem uninstall wmake")
end

task :rununit do
  dir = File.dirname(__FILE__)
  bin_path = File.join dir, "bin"
  lib_path = File.join dir, "lib"
  if Gem.win_platform? 
    bin_path.gsub! "/", "\\"
    ENV["PATH"] = bin_path + ";" + ENV["PATH"]
    ENV["RUBYLIB"] = lib_path
    system("#{Gem.ruby} #{dir}/test/run_all_test.rb")
  else
    raise "TODO"
  end
end