module Awesome
  module Definitions
    module Types
      def self.included(base)
        base.extend ClassMethods
        base.cattr_accessor :search_types
        base.cattr_accessor :verbose_types
      end

      module ClassMethods

        def search_types_enabled
          self.search_type_keys(false) - []
        end

        def search_type_keys(symring = true)
          self.search_types[:search_types_to_type_modifiers].map {|k,v| symring ? k : self.unmake_symring(k)}
        end

        def search_type_modifiers(symring = true)
          self.search_types[:search_types_to_type_modifiers].map {|k,v| symring ? v : self.unmake_symring(v)}
        end

        def type_modifiers_to_search_types
          self.search_types[:search_types_to_type_modifiers].invert
        end

        # match a regex for the type
        def match_types(anytext)
          return self.search_types[:search_type_regexes].map do |key,value|
            self.clean_search_text(anytext).match(value) ? key : nil
          end.compact
        end

        # type param might be an array of types
        def valid_type_modifiers(anytext, type, multiple_types_as_one = false)
          puts "checking valid_type_modifiers: #{anytext}, type: #{type.inspect}, multiple_types_as_one: #{multiple_types_as_one}" if self.verbose_types
          type = self.make_symring(type) unless multiple_types_as_one
          # Weed out invalid type requests
          allowed = multiple_types_as_one ? (self.search_type_keys & type) : nil
          return false if multiple_types_as_one && !type.empty? && allowed.empty?
          return false if !multiple_types_as_one && !self.search_type_keys.include?(type)
          mods = self.get_type_modifiers(anytext, multiple_types_as_one ? allowed : type, multiple_types_as_one)
          searchie = self.type_modifiers_to_search_types
          matchie = self.match_types(anytext)
          valid_mods = mods.select do |mod|
            indy = matchie.index(searchie[mod])
            puts "type mod #{mod.inspect} => #{searchie[mod].inspect} == #{indy ? matchie[indy].inspect : "nil"} == #{type.inspect}" if self.verbose_types
            !indy.nil? &&
              !matchie.nil? &&
              !searchie.nil? &&
              (multiple_types_as_one ? type.include?(searchie[mod]) : self.symring_equalizer(searchie[mod], type)) &&
              (multiple_types_as_one ? type.include?(matchie[indy]) : self.symring_equalizer(matchie[indy], type))
          end
          puts "valid_type_modifiers: #{valid_mods.inspect}" if self.verbose_types
          return valid_mods
        end

        def get_type_modifiers(anytext, type, multiple_types_as_one = false)
          mods = anytext.scan(self.search_type_modifiers_regex(false)).flatten.compact
          #If no type mods are in the search string then the type requested is valid so we pretend it was requested as a modifier
          mods = mods.empty? ? multiple_types_as_one ? type : [self.search_types[:search_types_to_type_modifiers][self.make_symring(type)]] : mods
          puts "get_type_modifiers: #{mods.inspect}" if self.verbose_types
          mods
        end

        def search_type_modifiers_regex(whitespace = false)
          #return self.modifier_regex_from_arrays(self.looped_array(self.search_type_modifiers), whitespace)
          return self.modifier_regex_from_array(self.search_type_modifiers, whitespace)
        end

      end # end of ClassMethods

      #INSTANCE METHODS
      def valid_search_type_inception?
        self.search_types[:search_type_inceptions][self.search_type] <= self.search_query.length
      end

    end
  end
end
