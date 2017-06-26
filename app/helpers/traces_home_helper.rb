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
    end
  end

  module TracesEngine
     
  end
end