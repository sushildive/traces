require "yaml"

class String
  # Wrap this string with input String
  def wrap(using)
    return self unless !using.nil?
    (using + self + using)
  end
  
  # Return array of strings matching to the input pattern
  def like(ptrn)
    return [] unless !ptrn.nil?
    pos=0
    result=[]
    while matched=self.match(ptrn, pos)
      matchedTxt=matched[0]
      result.push matchedTxt
      pos=matched.offset(0)[1]
    end
    
    result
  end
end

module TracesHomeHelper
  # Jugad, need to find correct way!
  APP_CFG = YAML.load_file(File.dirname(__FILE__)+"/../../config/traces.yml")['config']
  
  module TracesModel
    module ArtifactUtil
      def category
        return nil unless !self.path.nil?
        artifactCategories = TracesHomeHelper::APP_CFG[:artifact_cateogry.to_s]
        artifactCategories.each do |artifactCategory|
          if self.path.index artifactCategory[1]
            return ("cat_" + artifactCategory[0]).to_sym
          end
        end
        
        nil
      end
    end
    
    module StoryUtil
      def artifact(artifactObject, category)
        target=nil
        case category
          when :cat_requirement
            target = self.requirements ||= []
          when :cat_design
            target = self.designs ||= []
          when :cat_make
            target = self.makes ||= []
          when :cat_test
            target = self.tests ||= []
        end
        
        if !target.nil?
          if target.member?(artifactObject)
            target[artifactObject].revision artifactObject.revisions[0]
          else
            target.push artifactObject
          end
        end
      end
    end
  
    class Artifact
      include ArtifactUtil
      attr_accessor :path, :revisions
      def revision (rev)
        @revisions ||= []
        @revisions.push(rev) unless @revisions.member?(rev) 
        self
      end
      
      def initialize(pathVal)
        @path = pathVal
      end
      
      def eql?(other)
        return false unless !other.nil?
        return false unless (other.kind_of? Artifact)
        @path.eql?other.path
      end
      
      def hash
        return 0 unless !@path.nil?
        @path.hash
      end
    end
    
    class Story
      include StoryUtil
      attr_accessor :requirements, :designs, :makes, :tests
      attr_accessor :id, :summary
      
      def initialize(storyId, summaryText)
        @id = storyId
        @summary = summaryText
      end
      
      def eql? (other)
        return false unless !other.nil?
        return false unless (other.kind_of? Story)
        self.id.eql?other.id
      end
      
      def hash
        return 0 unless !@id.nil?
        @id.hash
      end
      
      def entries
        (CollectionUtil.size(@requirements) + CollectionUtil.size(@designs) + CollectionUtil.size(@makes) + CollectionUtil.size(@tests)) 
      end
    end
  end

  module TracesEngine
    include TracesModel
    
    def loadTestData
      result=[]
      story = Story.new "NGAXXX", "New XXX feature"
      result.push story
      
      reqs=[]
      reqa=Artifact.new("some/path")
      reqa.revision(1).revision(2)
      reqs.push(reqa);
      story.requirements=reqs
      desg=[reqa]
      desgb=Artifact.new("some/other/path")
      desgb.revision(5).revision(6)
      desg.push desgb
      story.designs=desg
      result
    end
    
    def self.loadData(projectId)
      return [] unless !projectId.nil?
      storyIdPattern = TracesHomeHelper::APP_CFG[:query_story_id_pattern.to_s].wrap('%')
      # Find list of issues in the input project matching to the story id pattern
      issueList = Issue.select("issues.id, subject").joins("INNER JOIN projects ON projects.id=issues.project_id").where(["subject like ?", storyIdPattern]).where("issues.id=issues.root_id").where(["projects.id=?", projectId])
      
      # Initialize empty result
      stories=[]
      # Now, for each identified issue, extract story Ids and load the trace data
      issueList.each do |issueData|
        stories = stories + toStories(issueData)
      end
      # Prepare unique story objects
      stories.uniq
      # Now, for each story, find the commits
      stories.each do |story|
        loadArtifacts story
      end
      
      stories
    end
    
    def self.loadArtifacts (story)
      storyPattern = story.id.wrap('%')
      #storyChanges = Change.joins("INNER JOIN changesets ON changesets.id=changes.changeset_id").where(["comments like ?", storyPattern])
      storyChanges = Change.select("changes.path, changesets.revision").joins("INNER JOIN changesets ON changesets.id=changes.changeset_id").where(["comments like ?", storyPattern])
      
      storyChanges.each do |changeObject|
        artifact = Artifact.new changeObject.path
        artifact.revision changeObject.revision
        artifactCat = artifact.category
        
        if !artifactCat.nil?
          story.artifact artifact, artifactCat
        end
      end
      
    end
    
    def self.toStories (issueData)
      storyIdPattern = TracesHomeHelper::APP_CFG[:text_story_id_pattern.to_s]
      storyIds = issueData.subject.like(storyIdPattern).uniq
      stories = []
      storyIds.each do |story|
        storyObj = Story.new story, issueData.subject
        stories.push storyObj
      end
      
      stories
    end
  end
  
  module CollectionUtil
    def self.size (obj)
      return 0 unless !obj.nil?
      return 0 unless obj.kind_of? Array
      return obj.size
    end
  end
end
