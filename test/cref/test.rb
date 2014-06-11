require 'test/unit'
require 'wmake/tools/cref'

class TestCRef < Test::Unit::TestCase
  def setup
    Dir.chdir(File.dirname __FILE__)
  end
  def assert_cref fname, refs
    a = WMake::CREF.get_refs("#{Dir.pwd}/#{fname}", [])
    assert_equal(a.sort, refs.collect{|x| "#{Dir.pwd}/#{x}"}.sort)
  end
  def test
    assert_cref "a.cpp", ["c.h", "b.h", "a.h", "a.cpp"]
    assert_cref "b.cpp", ["c.h", "b.h", "a.h", "b.cpp"]
    assert_cref "a.h", ["c.h", "b.h", "a.h"]
    assert_cref "b.h", ["c.h", "b.h", "a.h"]
    assert_cref "c.cpp", ["c.cpp"]
  end
end
