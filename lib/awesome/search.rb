module Awesome
  class Search

    # Mixins
    include Definitions::Bits
    include Definitions::Types
    include Definitions::Filters

    @@search_types ||= {:search_types_to_type_modifiers => {},
                        :search_type_inceptions => {},
                        :search_type_regexes => {}}
    @@search_filters ||= {:search_filters_to_filter_modifiers => {},
                          :filter_modifiers_to_search_filters => {}}

    def self.configure_search_types(&block)
      yield @@search_types
    end

    def self.configure_search_filters(&block)
      yield @@search_filters
    end

    #TODO: Put these into a config block
    cattr_accessor :verbose
    cattr_accessor :check_inception

    attr_accessor(:search_text,
                  :search_query,
                  :search_type,
                  :search_filters,
                  :search_locale,
                  :found,
                  :count,
                  :endpoint,
                  :invalid_inception,
                  :redirect_url)

    #CLASS METHODS
    #Main focus of class methods is determining which sort of AwesomeSearch subclass we need to instantiate for the search
    def initialize(*args)
      @search_text =    args.first[:search_text]    # a string
      @search_filters =  args.first[:search_filters]  # a ruby object (string, array, hash) to be used by subclasss search classes as a filter
      @search_query =   self.clean_search_text      # a string to be set based on the search text by removing the search modifiers from the search text
      @search_type =    args.first[:search_type]    # a symring (symring methods are in the Bits mixin)
      @search_locale =  args.first[:search_locale]  # a symring (symring methods are in the Bits mixin)
      @count = nil
      @found = nil
      @redirect_url = nil
      if self.class.check_inception && !self.valid_search_type_inception?
        puts "search type inception is invalid (no type regex matches query string)" if Awesome::Search.verbose
        @invalid_inception = true
      end
    end

    def clean_search_text
      txt = Awesome::Triage.clean_search_text(self.search_text)
      Awesome::Search.clean_search_text(txt)
    end

    def self.clean_search_text(text)
      txt = text.gsub(self.search_type_modifiers_regex(true), "")
      txt.gsub(self.search_filter_modifiers_regex(true), "")
    end

    # Main method used by the app to search
    # Instantiates an Awesome::Triage which will handle setting up the search
    def self.results_for(anytext, types, locales, filters = nil, multiple_types_as_one = false)
      # 1. if the search is blank return nil
      puts "anytext is blank" if Awesome::Search.verbose && anytext.blank?
      return nil if anytext.blank?
      Triage.new(:text => anytext, :types => types, :locales => locales, :filters => filters, :multiple_types_as_one => multiple_types_as_one)
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
