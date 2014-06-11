#!/usr/bin/ruby

Dir.chdir(File.dirname __FILE__)
Dir.new(".").each do |fname|
  if File.exists? fname + "/test.rb"
    require_relative fname + "/test.rb"
    puts "Load #{fname}/test.rb"
  end
end
