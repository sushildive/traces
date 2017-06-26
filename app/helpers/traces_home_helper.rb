module TracesHomeHelper
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
  end
  
  module CollectionUtil
    def self.size (obj)
      return 0 unless !obj.nil?
      return 0 unless obj.kind_of? Array
      return obj.size
    end
  end
end