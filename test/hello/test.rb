require 'test/unit'
require 'wmake/find'
require 'wmake/platform'

include WMake

class TestHello < Test::Unit::TestCase
  def assert_directory path
    assert(File.directory? path)
  end
  def assert_no_directory path
    assert(!File.directory?(path))
  end
  def assert_file path
    assert(File.exists? path)
  end
  def assert_no_file path
    assert(!File.exists?(path))
  end
  def run_cmd cmd
    system(cmd)
    if $?.exitstatus != 0
      raise "run command error: #{cmd}"
    end
  end
  def make target = nil
    if PLATFORM.windows?
      makepath = FIND["nmake"]
    else
      makepath = FIND["make"]
    end
    run_cmd "\"#{makepath}\" #{target}"
  end
  def test
    Dir.chdir(File.dirname __FILE__)

    run_cmd "wmake ."
    assert_directory "wmake.projs"
    assert_file "Makefile"
    assert_file "wmake.cache.yaml"

    make
    assert_directory "wmake.output"
    if PLATFORM.windows?
      assert_file "wmake.output/hello.exe"
      assert_equal `wmake.output/hello.exe`, "Hello world!\n"
    else
      assert_file "wmake.output/bin/hello"
      assert_equal `./wmake.output/bin/hello`, "Hello world!\n"
    end

    make "clean"
    assert_no_file "wmake.output/bin/hello"

    make "dist-clean"
    assert_no_directory "wmake.projs"
    assert_no_file "wmake.cache.yaml"
    assert_no_file "Makefile"

    run_cmd "wmake ."
    make "clean-all"
    assert_no_directory "wmake.output"
  end
end
