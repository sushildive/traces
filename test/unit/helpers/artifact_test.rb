#require File.expand_path('../../test_helper', __FILE__)
#require_relative "../../test_helper"

require "helpers/traces_home_helper"
require "test/unit"

class TestArtifact < Test::Unit::TestCase
  include TracesHomeHelper::TracesModel
  def testEqlWithNullObject
    target=Artifact.new("storyId")
    assert_equal(false, target.eql?(nil))
  end
  
  def testEqlWithString
    target=Artifact.new("storyId")
    assert_equal(false, target.eql?("Rahul"))
  end

  def testEqlWithInteger
    target=Artifact.new("storyId")
    assert_equal(false, target.eql?(0))
  end
  
  def testEqlWithMismatchingStoryId
    target=Artifact.new("storyId")
    input=Artifact.new("xxxx")
    assert_equal(false, target.eql?(input))
  end

  def testEqlWithMatchingStoryId
    target=Artifact.new("storyId")
    input=Artifact.new("storyId")
    assert_equal(true, target.eql?(input))
  end

  def testEqlWithEmptyStoryId
    target=Artifact.new("storyId")
    input=Artifact.new("")
    assert_equal(false, target.eql?(input))
  end

  def testEqlWithNullStoryId
    target=Artifact.new("storyId")
    input=Artifact.new(nil)
    assert_equal(false, target.eql?(input))
  end
  
  def testHashWithNullId
    assert_equal(0, Artifact.new(nil).hash)
  end
  
  def testHashWithEmptyStringId
    assert_equal("".hash, Artifact.new("").hash)
  end

  def testHashWithMismatchStringId
    assert_not_equal("Dravid".hash, Artifact.new("Rahul").hash)
  end
  
  def testRevisionWithNewArtifactObject
    artifact = Artifact.new("Rahul")
    assert_equal(nil, artifact.revisions)
  end
  
  def testRevisionWithNewRevisionItem
    artifact = Artifact.new("Rahul")
    artifact.revision 1
    assert_equal(1, artifact.revisions.size)
    assert_equal(1, artifact.revisions[0])
  end

  def testRevisionWithTwoRevisionItem
    artifact = Artifact.new("Rahul")
    artifact.revision 1
    artifact.revision 5
    assert_equal(2, artifact.revisions.size)
    assert_equal([1, 5], artifact.revisions)
  end
  
  def testRevisionWithDuplicateItem
    artifact = Artifact.new("Rahul")
    artifact.revision 1
    artifact.revision 6
    artifact.revision 6
    assert_equal(2, artifact.revisions.size)
    assert_equal([1, 6], artifact.revisions)
  end
  
  def testCategoryRequirementCategory
    assert_equal :cat_requirement, Artifact.new("path/requirements/file").category
  end
  
  def testCategoryDesignCategory
    assert_equal :cat_design, Artifact.new("path/design/file").category
  end
  
  def testCategoryMakeCategory
    assert_equal :cat_make, Artifact.new("path/construction/file").category
  end
  
  def testCategoryTestCategory
    assert_equal :cat_test, Artifact.new("path/tests/file").category
  end
end