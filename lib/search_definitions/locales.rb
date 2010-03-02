module SearchDefinitions
  module Locales

    def self.included(base)
      base.extend ClassMethods
      base.cattr_accessor :search_locales
    end

    module ClassMethods

      def configure_search_locales(&block)
        yield @@search_locales
      end

      def search_locales_enabled
        self.search_locale_keys(false) - ["google","ebay","amazon"]
      end

      def get_class_for_locale(locale)
        self.get_class(self.search_locales[:search_locales_to_classes][locale])
      end

      def search_locale_keys(symring = true)
        self.search_locales[:search_locales_to_locale_modifiers].map {|k,v| symring ? k : self.unmake_symring(k)}
      end

      def search_locale_modifiers(symring = true)
        # Needs to be flattened because the values are arrays
        self.search_locales[:search_locales_to_locale_modifiers].map {|k,v| symring ? v : self.unmake_symring(v)}.flatten
      end

      def valid_locale_modifiers(anytext, locale)
        # Weed out invalid locale requests
        locale = self.make_symring(locale)
        return false unless self.search_locale_keys.include?(locale)
        mods = self.get_locale_modifiers(anytext, locale)
        valid_mods = mods.select do |mod|
          puts "mod #{mod.class} #{mod.inspect} => #{self.search_locales[:locale_modifiers_to_search_locales][mod]} == #{locale.inspect} #{locale.class} locale" if self.verbose
          self.symring_equalizer(self.search_locales[:locale_modifiers_to_search_locales][mod], locale)
        end
        puts "valid_mods: #{valid_mods.inspect}" if self.verbose
        return valid_mods
      end

      def get_locale_modifiers(anytext, locale)
        mods = anytext.scan(self.search_locale_modifiers_regex(false)).flatten.compact
        #If no locale mods are in the search string then the locale requested is valid so we pretend it was requested as a modifier
        puts "mods #{mods.inspect}" if self.verbose
        mods.empty? ? [self.make_symring(locale)] : mods
      end

      def search_locale_modifiers_regex(whitespace = false)
        return self.modifier_regex_from_array(self.search_locale_modifiers, whitespace)
      end
    end # end of ClassMethods

    #INSTANCE METHODS

  end
end
