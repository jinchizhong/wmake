require 'test/unit'

class TestHello < Test::Unit::TestCase
  def assert_directory path
    assert(File.directory? path)
  end
  def assert_file path
    assert(File.exists? path)
  end
  def test
    Dir.chdir(File.dirname __FILE__)

    `wmake .`
    assert_directory "wmake.projs"
    assert_file "Makefile"
    assert_file "wmake.cache.yaml"
  end
end
