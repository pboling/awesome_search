module Awesome
  module Definitions
    module Locales

      def self.included(base)
        base.extend ClassMethods
        base.cattr_accessor :search_locales
        base.cattr_accessor :verbose_locales
      end

      module ClassMethods

        def stopwords_for_locale(locale)
          self.search_locales[:search_locales_to_stopwords][locale]
        end

        def search_locales_enabled
          self.search_locale_keys(false)
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
          puts "checking valid_locale_modifiers: #{anytext}, locale: #{locale.inspect}" if self.verbose_locales
          locale = self.make_symring(locale)
          return false unless self.search_locale_keys.include?(locale)
          mods = self.get_locale_modifiers(anytext, locale)
          valid_mods = mods.select do |mod|
            puts "locale mod #{mod.inspect} => #{self.get_search_locale_from_modifier(mod)} == #{locale.inspect}" if self.verbose_locales
            self.symring_equalizer(self.get_search_locale_from_modifier(mod), locale)
          end
          puts "valid_locale_modifiers: #{valid_mods.inspect}" if self.verbose_locales
          return valid_mods
        end

        def get_locale_modifiers(anytext, locale = nil)
          mods = anytext.scan(self.search_locale_modifiers_regex(false)).flatten.compact
          #If no locale mods are in the search string then the locale requested is valid so we pretend it was requested as a modifier
          mods = !locale.blank? && mods.empty? ? [self.make_symring(locale)] : mods
          puts "get_locale_modifiers: #{mods.reject {|x| x == ''}.inspect}" if self.verbose_locales
          mods.reject {|x| x == ''}
        end

        def get_search_locale_from_modifier(mod)
          self.search_locales[:locale_modifiers_to_search_locales][mod]
        end

        def search_locale_modifiers_regex(whitespace = false)
          self.modifier_regex_from_array(self.search_locale_modifiers, whitespace)
        end
      end # end of ClassMethods

      #INSTANCE METHODS

    end
  end
end
