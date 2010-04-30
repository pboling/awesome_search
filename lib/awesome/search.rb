module Awesome
  class Search

    # Mixins
    include Definitions::Bits
    include Definitions::Types
    include Definitions::Filters
    include Definitions::Stopwords

    @@search_types ||= {:search_types_to_type_modifiers => {},
                        :search_type_inceptions => {},
                        :search_type_regexes => {}}
    @@search_filters ||= {:search_filters_to_filter_modifiers => {},
                          :filter_modifiers_to_search_filters => {}}

    #Some defaults if stopwords are set to be used (by default they are turned off)
    @@search_stopwords ||= {:standard => %w(an and are as at be but by for if in into is it no not of on or s such t that the their then there these they this to was will with),
                            :custom => []}

    def self.configure_search_types(&block)
      yield @@search_types
    end

    def self.configure_search_filters(&block)
      yield @@search_filters
    end

    def self.configure_search_stopwords(&block)
      yield @@search_stopwords
    end

    #TODO: Put these into a config block
    cattr_accessor :verbose
    cattr_accessor :check_inception
    cattr_accessor :protect_types
    cattr_accessor :protect_filters

    attr_accessor(:search_text,
                  :search_query,
                  :search_type,
                  :search_filters,
                  :search_locale,
                  :stopwords,
                  :found,
                  :tally,
                  :success,
                  :endpoint,
                  :invalid_inception,
                  :redirect_url,
                  :page,
                  :per_page,
                  :replacement_for,
                  :multiple_types_as_one,
                  :tokenize_quoted,
                  :tokenize_unquoted,
                  :tokenize_without_quoted,
                  :quoted_exact_phrases,
                  :unquoted_exact_phrases,
                  :query_without_exact_phrases,
                  :gowords,
                  :search_tokens,
                  :highlight_tokens)

    #CLASS METHODS
    #Main focus of class methods is determining which sort of AwesomeSearch subclass we need to instantiate for the search
    def initialize(*args)
      @multiple_types_as_one = args.first[:multiple_types_as_one]
      @stopwords =  args.first[:stopwords] ?
                      args.first[:stopwords].is_a?(Array) ?
                        args.first[:stopwords] :
                        args.first[:stopwords].is_a?(Symbol) ?
                          self.class.stopwords(args.first[:stopwords]) :
                          self.class.stopwords(:both) :
                      args.first[:stopwords] != false ?
                        self.class.stopwords(:standard) :
                        []
      @page     = args.first[:page]
      @per_page = args.first[:per_page]
      @search_text =    args.first[:search_text]    # a string
      @search_filters = args.first[:search_filters] # a ruby object (string, array, hash) to be used by subclasss search classes as a filter
      #Chicken-egg problem: search_tokens and highlight_tokens both need to be set within clean_search_text (and they are!) because they must work with the text cleaned by the clean_search_text methods
      @search_tokens =  args.first[:search_tokens]  # an array of the query terms as tokens after being cleaned, unless passed in as param (not sure why this would ever be desired, but why not allow it jic?) When not set in args, will be set by clean_search_text methods
      @highlight_tokens =  args.first[:highlight_tokens]  # an array of the query terms as unquoted tokens after being cleaned, unless passed in as param (not sure why this would ever be desired, but why not allow it jic?) When not set in args, will be set by clean_search_text methods
      @search_query =   self.clean_search_text      # a string to be set based on the search text by removing the search modifiers from the search text
      @search_type =    args.first[:search_type]    # a symring (symring methods are in the Bits mixin)
      @search_locale =  args.first[:search_locale]  # a symring (symring methods are in the Bits mixin)
      @found = nil
      @tally = nil
      @success = true
      @redirect_url = nil
      @replacement_for = nil # stores the name of, or explanatory text about, the primary search if this search is a secondary (replacement) search for a primary search that returned no results
      if self.class.check_inception && !self.valid_search_type_inception?
        puts "search type inception is invalid (no type regex matches query string)" if Awesome::Search.verbose
        @invalid_inception = true
      end
    end

    def to_s
      "search_query: #{self.search_query} \
\n\rsearch_tokens: #{self.search_tokens.inspect} \
\n\rhighlight_tokens: #{self.highlight_tokens.inspect} \
\n\rtally: #{self.tally} \
\n\rsuccess? #{self.success ? 'Yes' : 'No'}"
    end

    def clean_search_text
      txt = Awesome::Triage.clean_search_text(self.search_text)
      txt = Awesome::Search.clean_search_text(txt, self.multiple_types_as_one)
      txt = self.process_stopwords(txt)
      txt
    end

    def self.clean_search_text(text, multiple_types_as_one = false)
      txt = text.gsub(self.search_type_modifiers_regex(true, multiple_types_as_one), "")
      txt.gsub(self.search_filter_modifiers_regex(true), "")
    end

    # Main method used by the app to search
    # Instantiates an Awesome::Triage which will handle setting up the search
    def self.results_for(anytext, types, locales, filters = nil, multiple_types_as_one = false, page = nil, per_page = nil)
      # 1. if the search is blank return nil
      puts "anytext is blank" if Awesome::Search.verbose && anytext.blank?
      return nil if anytext.blank?
      Triage.new(:text => anytext, :types => types, :locales => locales, :filters => filters, :multiple_types_as_one => multiple_types_as_one, :page => page, :per_page => per_page)
    end

    #INSTANCE METHODS

    # get_results is called on the instances of the subclasses.
    # The subclasses override the methods called within it to return their customized stuff
    # The subclasses call super to ensure that the data is valid before sending out the search.
    def get_results
      # 1. if the search is blank do NOT run the search (handled in subclasses)
      !self.search_text.blank? && !self.search_query.blank? && !self.search_type.blank? && !self.search_locale.blank?
    end
  end
end

#handles a param of any string, and returns all known matches for that string
#def self.all_matches(search_text = "")
#  self.match_types(search_text).map do |type|
#    {type => self.matches_for_type(type, search_text, true)}
#  end.compact | self.match_types(search_text).map do |type|
#    {type => self.matches_for_type(type, search_text, false)}
#  end.compact
#end
