require "helpers/traces_home_helper"
require "test/unit"


class TestStringExtension < Test::Unit::TestCase
  include TracesHomeHelper

  def testWrappWithNullWrapper
    assert_equal("Rahul", "Rahul".wrap(nil))
  end
  
  def testWrappWithNullWrapper
    assert_equal("-Rahul-", "Rahul".wrap('-'))
  end
  
end