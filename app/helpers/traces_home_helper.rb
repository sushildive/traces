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
          idx=target.index {|o| artifactObject.eql? o}
          unless idx.nil?
            ele = target[idx]
          end
          if ele
            ele.revision artifactObject.revisions[0]
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
        self.path.eql? other.path
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

    def self.loadData(projectId,offset)
      return [] unless !projectId.nil?
      limit = TracesHomeHelper::APP_CFG[:limit.to_s]
      ulimit = limit.to_i+1
      # Find list of issues in the input project matching to the story id pattern
      issueList = Issue.select("issues.id, subject").joins("INNER JOIN projects ON projects.id=issues.project_id").where("issues.id=issues.root_id").where(["projects.id=?", projectId]).order("issues.updated_on desc").limit(ulimit).offset(offset)

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

    def self.loadDataByIssueId(issue)
      return [] unless !issue.nil?
      # Initialize empty result
      stories=[]
      # Now, for identified issue, extract story Ids and load the trace data
      stories = stories + toStories(issue)
      # Now, for story, find the commits
      stories.each do |story|
        loadArtifacts story
      end
      stories
    end

    def self.loadDataByCriteria(criteria,projectId,offset)
      return [] unless !criteria.nil?
      limit = TracesHomeHelper::APP_CFG[:limit.to_s]
      ulimit = limit.to_i+1
      # Find issue in the input project matching to the issue id
      issueList = Issue.select("issues.id, subject").joins("INNER JOIN projects ON projects.id=issues.project_id").where(["projects.id=?", projectId]).where(["lower(issues.subject) like lower(?)", "%".concat(criteria).concat("%")]).order("issues.updated_on desc").limit(ulimit).offset(offset)

      # Initialize empty result
      stories=[]
      # Now, for each identified issue, extract story Ids and load the trace data
      issueList.each do |issueData|
        stories = stories + toStories(issueData)
      end
      # Now, for each story, find the commits
      stories.each do |story|
        loadArtifacts story
      end
      stories
    end

    def self.loadAllData(criteria,projectId)
      return [] unless !criteria.nil?
      limit = TracesHomeHelper::APP_CFG[:limit.to_s]
      ulimit = limit.to_i+1
      # Find issue in the input project matching to the issue id
      issueList = Issue.select("issues.id, subject").joins("INNER JOIN projects ON projects.id=issues.project_id").where(["projects.id=?", projectId]).where(["lower(issues.subject) like lower(?)", "%".concat(criteria).concat("%")]).order("issues.updated_on desc")

      # Initialize empty result
      stories=[]
      # Now, for each identified issue, extract story Ids and load the trace data
      issueList.each do |issueData|
        stories = stories + toStories(issueData)
      end
      # Now, for each story, find the commits
      stories.each do |story|
        loadArtifacts story
      end
      stories
    end

    def self.loadArtifacts (story)
      storyId = story.id
      #storyChanges = Change.joins("INNER JOIN changesets ON changesets.id=changes.changeset_id").where(["comments like ?", storyPattern])
      #storyChanges = Change.select("changes.path, changesets.revision, changesets.comments").joins("INNER JOIN changesets ON changesets.id=changes.changeset_id").where(["comments like ?", storyId])
      storyChanges = Changeset.select("changes.path, changesets.revision, changesets.id").joins(:issues).joins(:filechanges).where(["issues.id in (?)", Issue.select("issues.id").where(["issues.root_id = ?", storyId])]).all

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
      stories = []
      storyObj = Story.new issueData.id, issueData.subject
      stories.push storyObj
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
