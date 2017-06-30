#require File.expand_path('../../test_helper', __FILE__)
#require_relative "../../test_helper"

require "helpers/traces_home_helper"
require "test/unit"

class TestStory < Test::Unit::TestCase
  include TracesHomeHelper::TracesModel
  def testEqlWithNullObject
    target=Story.new("storyId", "summary")
    assert_equal(false, target.eql?(nil))
  end
  
  def testEqlWithString
    target=Story.new("storyId", "summary")
    assert_equal(false, target.eql?("Rahul"))
  end

  def testEqlWithInteger
    target=Story.new("storyId", "summary")
    assert_equal(false, target.eql?(0))
  end
  
  def testEqlWithMismatchingStoryId
    target=Story.new("storyId", "summary")
    input=Story.new("xxxx", "summary")
    assert_equal(false, target.eql?(input))
  end

  def testEqlWithMatchingStoryId
    target=Story.new("storyId", "summary")
    input=Story.new("storyId", "summary")
    assert_equal(true, target.eql?(input))
  end

  def testEqlWithEmptyStoryId
    target=Story.new("storyId", "summary")
    input=Story.new("", "summary")
    assert_equal(false, target.eql?(input))
  end

  def testEqlWithNullStoryId
    target=Story.new("storyId", "summary")
    input=Story.new(nil, "summary")
    assert_equal(false, target.eql?(input))
  end
  
  def testHashWithNullId
    assert_equal(0, Story.new(nil, nil).hash)
  end
  
  def testHashWithEmptyStringId
    assert_equal("".hash, Story.new("", nil).hash)
  end

  def testHashWithMismatchStringId
    assert_not_equal("Dravid".hash, Story.new("Rahul", nil).hash)
  end
  
  def testArtifactWithFirstValue
    story = Story.new("Rahul", nil)
    artifact = Artifact.new("some/requirements")
    artifact.revision(100)
    story.artifact(artifact, :cat_requirement)
    assert_equal(1,story.requirements.size)
  end

  def testArtifactWithSecondValue
    story = Story.new("Rahul", nil)
    artifact = Artifact.new("some/requirements")
    artifact.revision(200)
    story.artifact(artifact, :cat_requirement)
    artifact = Artifact.new("some/requirements")
    artifact.revision(100)
    story.artifact(artifact, :cat_requirement)
    assert_equal(1,story.requirements.size)
  end

end