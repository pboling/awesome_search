module Awesome
  class Triage < Array

    # Mixins
    include Definitions::Bits
    include Definitions::Locales

    #The following is set in a config block
    @@search_locales ||= {:search_locales_to_classes => {},
                          :search_locales_to_locale_modifiers => {},
                          :locale_modifiers_to_search_locales => {}}

    def self.configure_search_locales(&block)
      yield @@search_locales
    end

    #TODO: Put these into a config block
    cattr_accessor :verbose

    attr_accessor( :text,
                   :types,
                   :locales,
                   :filters,
                   :multiple_types_as_one )

    def initialize(*args)
      super()
      @text     = args.first[:text]     # a string
      @types    = args.first[:types].respond_to?(:each) ? args.first[:types] : [args.first[:types]]       # a symring, or array thereof (symring methods are in the Bits mixin)
      @locales  = args.first[:locales].respond_to?(:each) ? args.first[:locales] : [args.first[:locales]] # a symring, or array thereof (symring methods are in the Bits mixin)
      @filters  = args.first[:filters] # a ruby object (string, array, hash) to be used by subclasss search classes as a filter
      @multiple_types_as_one = args.first[:multiple_types_as_one] || false# Boolean: should the array of types be sent through to a single search, or iterated over to separate searches like locales?
      # 1. Handle all locale modifiers, by creating a different search for each
      self.locales.each do |locale|
        puts "initializing locale: #{locale}" if self.class.verbose_locales
        locale = self.class.make_symring(locale)
        klass = self.class.get_class_for_locale(locale)
        # 2. if there is no matching class for the locale return nil
        puts "klass is nil" if Awesome::Triage.verbose && klass.nil?
        next if klass.nil?
        # 3. If there is a locale modifier, then make sure it matches the locale being searched or return nil
        locale_mods = self.class.valid_locale_modifiers(self.text, locale)
        puts "locale_mods is empty" if Awesome::Triage.verbose && locale_mods.empty?
        next if locale_mods.empty?
        # 4. Handle all type modifiers, by creating a different search for each
        if self.multiple_types_as_one
          self << self.new_search_for_types_and_locale(klass, self.types, locale)
        else
          self.types.each do |type|
            self << self.new_search_for_type_and_locale(klass, type, locale)
          end
        end
      end
      self.compact!
      self
    end

    # single type
    def new_search_for_type_and_locale(klass, type, locale)
      new_search = nil
      type = self.class.make_symring(type)
      # 6. If there is a type modifier, then make sure it matches the type being searched or return nil
      type_mods = klass.valid_type_modifiers(self.text, type, false)
      puts "type_mods is empty" if Awesome::Triage.verbose && type_mods.empty?
      unless type_mods.empty?
        new_search = klass.new({:search_text => self.text, :search_type => type, :search_locale => locale, :search_filters => self.filter_mods(klass)})
        new_search.get_results
      end
      return new_search
    end

    # multiple types
    def new_search_for_types_and_locale(klass, types, locale)
      new_search = nil
      # 6. If there is a type modifier, then make sure it matches the type being searched or return nil
      type_mods = klass.valid_type_modifiers(self.text, types, true)
      puts "type_mods is empty" if Awesome::Triage.verbose && type_mods.empty?
      unless type_mods.empty?
        new_search = klass.new({:search_text => self.text, :search_type => type_mods, :search_locale => locale, :search_filters => self.filter_mods(klass)})
        new_search.get_results
      end
      return new_search
    end

    def filter_mods(klass)
      f = nil
      if self.filters
        # 5. If there is a filter modifier, then make sure it matches the locale being searched or return nil
        f = klass.valid_filter_modifiers(self.text, self.filters)
        puts "filter_mods is empty" if Awesome::Triage.verbose && filter_mods.empty?
      end
      f
    end

    def clean_search_text
      txt = Awesome::Triage.clean_search_text(self.search_text)
      Awesome::Search.clean_search_text(txt)
    end

    def self.clean_search_text(text)
      text.gsub(self.search_locale_modifiers_regex(true), "")
    end

  end
end
