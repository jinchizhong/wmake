require 'test/unit'

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
  def test
    Dir.chdir(File.dirname __FILE__)

    run_cmd "wmake ."
    assert_directory "wmake.projs"
    assert_file "Makefile"
    assert_file "wmake.cache.yaml"

    run_cmd "make"
    assert_directory "wmake.output"
    assert_file "wmake.output/bin/hello"
    assert_equal `./wmake.output/bin/hello`, "Hello world!\n"

    run_cmd "make clean"
    assert_no_file "wmake.output/bin/hello"

    run_cmd "make dist-clean"
    assert_no_directory "wmake.projs"
    assert_no_file "wmake.cache.yaml"
    assert_no_file "Makefile"

    run_cmd "wmake ."
    run_cmd "make clean-all"
    assert_no_directory "wmake.output"
  end
end
