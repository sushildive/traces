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
  
  def testLikeWithUnmatchedPattern
    assert_equal([], "Rahul".like(/(NGA)[\w\d-]+/))
  end
  
  def testLikeWithEmptyPattern
    assert_equal([], "Rahul".like(nil))
  end

  def testLikeWithMatchedPattern
    assert_equal(["Rahul"], "Rahul".like(/(Rahul)/))
  end

  def testLikeWithMultipleMatches
    assert_equal(["NGA0-1", "NGA550-1", "NGAXX1-0-3"], "This is just an interesting stringNGA0-1,NGA550-1 AND NGAXX1-0-3".like(/(NGA)[\w\d-]+/))
  end

  def testLikeWithEmptyString
    assert_equal([], "".like(/(NGA)[\w\d-]+/))
  end
end