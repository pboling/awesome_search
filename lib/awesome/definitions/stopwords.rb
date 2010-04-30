module Awesome
  module Definitions
    module Stopwords

      QUOTED_REGEX =    /("[^"]*")/
      UNQUOTED_REGEX =    /"([^"]*)"/
      RM_QUOTED_REGEX = /"[^"]*"/
      BEG_OPERATORS =   /^[+-]/
      END_OPERATORS =   /[,+-]$/
      EXCLUSION_OPERATORS =   /^[-]/
      INCLUSION_OPERATORS =   /^[+]/

      def self.included(base)
        base.extend ClassMethods
        base.cattr_accessor :search_stopwords
        base.cattr_accessor :verbose_stopwords
      end

      module ClassMethods
        def stopwords(key = :both)
          case key
            when :standard then
              self.search_stopwords[:standard]
            when :custom then
              self.search_stopwords[:custom]
            when :both then
              self.search_stopwords[:custom] | self.search_stopwords[:standard]
            else
              Rails.logger.warn("AwesomeSearch: Stopwords Key Invalid, defaulting to :both")
              self.search_stopwords[:custom] | self.search_stopwords[:standard]
          end
        end
      end

      #Instance Methods:

      #remove the stopwords from regular search terms, BUT NOT from exact phrase searches (quoted)
      #example:
      # txt = "+hair    \"in the\"  on the grapes,  \"middle fork\" wrath  \"age  of man\"  -end"
      def process_stopwords(txt = self.search_text)
        #Needs to be set so highlighting will work properly (can't match quotes)
        self.highlight_token_array(txt)
        #Now put humpty dumpty back together without the nasty stopwords, sort the tokens by length
        self.search_token_array(txt).join(" ")
      end

      def search_token_array(txt)
        self.search_tokens ||= (self.quoted_exact_phrases_array(txt) | self.gowords_array(txt)).sort {|a,b| b.length <=> a.length }
      end

      def highlight_token_array(txt)
        self.highlight_tokens ||= begin
          array = (self.unquoted_exact_phrases_array(txt) | self.gowords_array(txt)).sort {|a,b| b.length <=> a.length }
          remove_exclusions(array)
        end
      end

      def remove_exclusions(array)
        array.map do |tok|
          tok.match(Awesome::Definitions::Stopwords::EXCLUSION_OPERATORS) ?
            nil :
            tok.match(Awesome::Definitions::Stopwords::RM_QUOTED_REGEX) ?
              tok :
              tok.gsub(Awesome::Definitions::Stopwords::INCLUSION_OPERATORS, '')
        end.compact
      end
      
      #All tokens that are quoted
      def tokenize_quot(txt)
        self.tokenize_quoted ||= txt.split(Awesome::Definitions::Stopwords::QUOTED_REGEX)
      end

      #All tokens that are quoted, in their unquoted form
      def tokenize_unquot(txt)
        self.tokenize_unquoted ||= txt.split(Awesome::Definitions::Stopwords::UNQUOTED_REGEX)
      end

      #Remove all tokens that are quoted
      def tokenize_without_quot(txt)
        self.tokenize_without_quoted ||= txt.split(Awesome::Definitions::Stopwords::RM_QUOTED_REGEX)
      end

      # ["\"in the\"", "\"middle fork\"", "\"age  of man\""]
      def quoted_exact_phrases_array(txt)
        self.quoted_exact_phrases ||= self.tokenize_quot(txt) - self.tokenize_without_quot(txt) - ['']
      end

      # ["in the", "middle fork", "age  of man"]
      def unquoted_exact_phrases_array(txt)
        self.unquoted_exact_phrases ||= self.tokenize_unquot(txt) - self.tokenize_without_quot(txt) - ['']
      end

      # "+hair     on the grapes,   wrath    -end"
      def query_wo_exact_phrases(txt)
        self.query_without_exact_phrases ||= txt.gsub(Awesome::Definitions::Stopwords::QUOTED_REGEX, '')
      end

      # ["+hair", "on", "the", "grapes,", "wrath", "-end"]
      def array_with_stopwords(txt)
        qa = self.query_wo_exact_phrases(txt).split
        qa.delete(',') #delete works on self (qa here), so won't work chained onto the statement above!
        qa
      end

      # ["+hair", "grapes,", "wrath", "-end"]
      def gowords_array(txt)
        self.gowords ||= self.array_with_stopwords(txt).map do |token|
          cleaned_token = self.clean_token(token)
          self.stopwords.include?(cleaned_token) ? nil : cleaned_token.blank? ? nil : token
        end.compact
      end

      def clean_token(token)
        token.gsub(Awesome::Definitions::Stopwords::BEG_OPERATORS, '').gsub(Awesome::Definitions::Stopwords::END_OPERATORS, '')
      end

    end
  end
end