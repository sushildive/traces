require "helpers/traces_home_helper"
require "test/unit"


class TestCollectionUtil < Test::Unit::TestCase
  include TracesHomeHelper
  def testSizeWithNullObject
    assert_equal(0, CollectionUtil.size(nil))
  end

  def testSizeWithNonArrayObject
    assert_equal(0, CollectionUtil.size(""))
  end

  def testSizeWithEmptyArrayObject
    assert_equal(0, CollectionUtil.size([]))
  end

  def testSizeWithFilledArrayObject
    assert_equal(1, CollectionUtil.size([1]))
  end
end