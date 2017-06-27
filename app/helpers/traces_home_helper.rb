require "yaml"


class String
  def wrap(using)
    return self unless !using.nil?
    (using + self + using)
  end
end


module TracesHomeHelper
  # Jugad, need to find correct way!
  APP_CFG = YAML.load_file(File.dirname(__FILE__)+"/../../config/traces.yml")['config']
  
  module TracesModel
    class Artifact
      attr_accessor :path, :revisions
      def revision (revision)
        @revisions ||= []
        @revisions.push(revision) unless @revisions.member?(revision) 
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
      #storyIdPattern = '%' << TracesHomeHelper::APP_CFG["query_story_id_pattern"] << '%'
      storyIdPattern = TracesHomeHelper::APP_CFG["query_story_id_pattern"].wrap('%')
      # Find list of issues in the input project matching to the story id pattern
      issueList = Issue.select("issues.id, subject").joins("INNER JOIN projects ON projects.id=issues.project_id").where(["subject like ?", storyIdPattern]).where("issues.id=issues.root_id").where(["projects.id=?", projectId])
      
      # Initialize empty result
      result=[]
      # Now, for each identified issue, extract story Ids and load the trace data
      issueList.each do |issueData|
        toStories(issueData)
      end
    end
    
    def toStories (issueData)
      storyIdPattern=TracesHomeHelper::APP_CFG["text_story_id_pattern"]
      #WIP
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