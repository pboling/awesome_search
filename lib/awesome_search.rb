class AwesomeSearch

  # Instance method Mixins
  include SearchDefinitions::Types
  include SearchDefinitions::Bits
  include SearchDefinitions::Locales
  attr_accessor(:search_text,
                :search_query,
                :search_type,
                :search_locale,
                :results,
                :count,
                :endpoint)

  # Class method Mixins
  cattr_accessor :verbose

  @@search_locales ||= {
    :search_locales_to_classes =>
    { ":local" =>   "SearchLocal",
      ":amazon" =>  "SearchAmazon",
      ":google" =>  "SearchGoogle",
      ":ebay" =>    "SearchEbay" },
    :search_locales_to_locale_modifiers =>
    {
      ":local" =>
        [ ":local" ],
      ":amazon" =>
        [ ":amazon",
          ":amzn",
          ":amz",
          ":am"],
      ":google" =>
        [ ":google",
          ":goog",
          ":goo",
          ":go"],
      ":ebay" =>
        [ ":ebay",
          ":eby",
          ":eb"]
    },
    :locale_modifiers_to_search_locales =>
    {
      ":local"  => ":local",
      ":amazon" => ":amazon",
      ":amz"    => ":amazon",
      ":amzn"   => ":amazon",
      ":am"     => ":amazon",
      ":google" => ":google",
      ":goog"   => ":google",
      ":goo"    => ":google",
      ":go"     => ":google",
      ":ebay"   => ":ebay",
      ":eby"    => ":ebay",
      ":eb"     => ":ebay"
    }
  }

  @@search_types ||= {
    # Each search class will redefine
    # in order to only have specific search types available
    :search_types_to_type_modifiers =>
    {
      ":isbn" => ":isbn",
      ":sku" => ":sku",
      ":upc" => ":upc",
      ":asin" => ":asin",
      ":id" => ":dbid",
      ":text" => ":text"
    },
    # When using observer, how long should we wait before sending out search queries?
    :search_type_inceptions =>
    {
      ":isbn" => 10,
      ":sku" => 8,
      ":upc" => 10,
      ":asin" => 10,
      ":id" => 1,
      ":text" => 4
    },
    :search_type_regexes =>
    {
      ":isbn" => /\d{10}$|^\d{13}/,            #match 10 or 13 digits for isbn
      ":sku" => /[0-9a-zA-Z\-]+/,              #match any alphanumeric
      ":upc" => /\d{10}$|^\d{12}/,
      ":asin" => /\w{10}/,
      ":id" => /\d+/,
      ":text" => /\w{4}/
    }
  }
  
  #CLASS METHODS
  #Main focus of class methods is determining which sort of AwesomeSearch subclass we need to instantiate for the search
  def initialize(*args)
    @search_text =    args.first[:search_text]    # a string
    @search_query =   self.clean_search_text      # a string to be set based on the search text by removing the search modifiers from the search text
    @search_type =    args.first[:search_type]    # a symring (symring methods are in the Bits mixin)
    @search_locale =  args.first[:search_locale]  # a symring (symring methods are in the Bits mixin)
    @count =   nil
    @results = nil
  end

  def clean_search_text
    AwesomeSearch.clean_search_text(self.search_text)
  end

  def self.clean_search_text(text)
    txt = text.gsub(AwesomeSearch.search_type_modifiers_regex(true), "")
    return txt.gsub(AwesomeSearch.search_locale_modifiers_regex(true), "")
  end

  # The is the main method used by the app to search
  # This will instantiate an object of the appropriate Search Class for the given locale, customized for the type
  def self.results_for_type_and_locale(anytext, type, locale)
    # 1. if the search is blank return nil
    puts "anytext is blank" if self.verbose && anytext.blank?
    return nil if anytext.blank?
    locale = self.make_symring(locale)
    klass = self.get_class_for_locale(locale)
    # 2. if there is no matching class for the locale return nil
    puts "klass is nil" if self.verbose && klass.nil?
    return nil if klass.nil?
    # 3. If there is a locale modifier, then make sure it matches the locale being searched or return nil
    locale_mods = klass.valid_locale_modifiers(anytext, locale)
    puts "locale_mods is empty" if self.verbose && locale_mods.empty?
    return nil if locale_mods.empty?
    # 4. If there is a type modifier, then make sure it matches the type being searched or return nil
    type = self.make_symring(type)
    type_mods = klass.valid_type_modifiers(anytext, type)
    puts "type_mods is empty" if self.verbose && type_mods.empty?
    return nil if type_mods.empty?
    new_search = klass.new({:search_text => anytext, :search_type => type, :search_locale => locale})
    puts "search type inception is invalid (no type regex matches query string)" if self.verbose && !new_search.valid_search_type_inception?
    return nil unless new_search.valid_search_type_inception?
    new_search.get_results
    new_search.count = new_search.results.length
    return new_search
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

#handles a param of any string, and returns all known matches for that string
#def self.all_matches(search_text = "")
#  self.match_types(search_text).map do |type|
#    {type => self.matches_for_type(type, search_text, true)}
#  end.compact | self.match_types(search_text).map do |type|
#    {type => self.matches_for_type(type, search_text, false)}
#  end.compact
#end
