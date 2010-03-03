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
                   :multiple_types_as_one,
                   :redirect_url,
                   :page,
                   :per_page )

    def initialize(*args)
      super()
      @page     = args.first[:page]
      @per_page = args.first[:per_page]
      @text     = args.first[:text]     # a string
      @types    = args.first[:types].respond_to?(:each) ? args.first[:types] : [args.first[:types]]       # a symring, or array thereof (symring methods are in the Bits mixin)
      @locales  = args.first[:locales].respond_to?(:each) ? args.first[:locales] : [args.first[:locales]] # a symring, or array thereof (symring methods are in the Bits mixin)
      @filters  = args.first[:filters] # a ruby object (string, array, hash) to be used by subclasss search classes as a filter
      @multiple_types_as_one = args.first[:multiple_types_as_one] || false# Boolean: should the array of types be sent through to a single search, or iterated over to separate searches like locales?
      @redirect_url = nil
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
        self.add_search(klass, locale)
        #if we hit a search that tells us to redirect, do not continue
        break if self.redirect_url
      end
      self.compact!
      self
    end

    def add_search(klass, locale)
      # 4. Handle all type modifiers, by creating a different search for each
      if self.multiple_types_as_one
        new_search = self.new_search_for_types_and_locale(klass, self.types, locale)
        self.redirect_url = new_search.redirect_url
        self << new_search
      else
        self.types.each do |typ|
          new_search = self.new_search_for_type_and_locale(klass, typ, locale)
          self.redirect_url = new_search.redirect_url
          self << new_search
        end
      end
    end

    # single type
    def new_search_for_type_and_locale(klass, type, locale)
      new_search = nil
      type = self.class.make_symring(type)
      # 6. If there is a type modifier, then make sure it matches the type being searched or return nil
      valid_type_mods = Awesome::Search.protect_types ? klass.valid_type_modifiers(self.text, type, false) : [type]
      puts "valid_type_mods is empty" if Awesome::Triage.verbose && valid_type_mods.empty?
      unless valid_type_mods.empty?
        new_search = klass.new({:search_text => self.text, :search_type => type, :search_locale => locale, :search_filters => self.filter_mods(klass), :page => self.page, :per_page => self.per_page})
        new_search.get_results
      end
      return new_search
    end

    # multiple types
    def new_search_for_types_and_locale(klass, types, locale)
      new_search = nil
      # 6. If there is a type modifier, then make sure it matches the type being searched or return nil
      valid_type_mods = Awesome::Search.protect_types ? klass.valid_type_modifiers(self.text, types, true) : types
      puts "valid_type_mods is empty" if Awesome::Triage.verbose && valid_type_mods.empty?
      unless valid_type_mods.empty?
        new_search = klass.new({:search_text => self.text, :search_type => valid_type_mods, :search_locale => locale, :search_filters => self.filter_mods(klass), :page => self.page, :per_page => self.per_page})
        new_search.get_results
      end
      return new_search
    end

    def filter_mods(klass)
      valid_filter_mods = nil
      if self.filters
        # 5. If there is a filter modifier, then make sure it matches the locale being searched or return nil
        valid_filter_mods = Awesome::Search.protect_filters ? klass.valid_filter_modifiers(self.text, self.filters) : self.filters
        puts "valid_filter_mods is empty" if Awesome::Triage.verbose && valid_filter_mods.empty?
      end
      valid_filter_mods
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
