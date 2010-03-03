module Awesome
  module Definitions
    module Filters

      def self.included(base)
        base.extend ClassMethods
        base.cattr_accessor :search_filters
        base.cattr_accessor :verbose_filters
      end

      module ClassMethods

        def search_filters_enabled
          self.search_filter_keys(false)
        end

        def get_class_for_filter(filter)
          self.get_class(self.search_filters[:search_filters_to_classes][filter])
        end

        def search_filter_keys(symring = true)
          self.search_filters[:search_filters_to_filter_modifiers].map {|k,v| symring ? k : self.unmake_symring(k)}
        end

        def search_filter_modifiers(symring = true)
          # Needs to be flattened because the values are arrays
          self.search_filters[:search_filters_to_filter_modifiers].map {|k,v| symring ? v : self.unmake_symring(v)}.flatten
        end

        # filter param is an array of filters
        def valid_filter_modifiers(anytext, filter)
          # Weed out invalid filter requests
          puts "checking valid_filter_modifiers: #{anytext}, filter: #{filter.inspect}" if self.verbose_filters
          # We do not make_symring for two reasons:
          #  1. people will use whatever kind of filter value they need, and ruby can compare it.
          #  2. the filter param is an array
          # #filter = self.make_symring(filter)
          # Weed out invalid filter requests
          allowed = (self.search_filter_keys & filter)
          return false if !filter.empty? && allowed.empty?
          valid_filter_mods = self.get_filter_modifiers(anytext, allowed)
          valid_search_filters = valid_filter_mods.map do |fmod|
            puts "filter mod #{fmod.inspect} => #{self.search_filters[:filter_modifiers_to_search_filters][fmod]}" if self.verbose_filters
            self.search_filters[:filter_modifiers_to_search_filters][fmod]
          end.compact
          puts "valid_filter_modifiers: #{valid_search_filters.inspect}" if self.verbose_filters
          return valid_search_filters
        end

        def get_filter_modifiers(anytext, allowed)
          mods = anytext.scan(self.search_filter_modifiers_regex(false)).flatten.compact
          #If no filter mods are in the search string then the filter requested is valid so we pretend it was requested as a modifier
          mods = (self.search_filter_modifiers & mods) | allowed
          puts "get_filter_modifiers #{mods.inspect}" if self.verbose_filters
          mods
        end

        def search_filter_modifiers_regex(whitespace = false)
          return self.modifier_regex_from_array(self.search_filter_modifiers, whitespace)
        end
      end # end of ClassMethods

      #INSTANCE METHODS

    end
  end
end
