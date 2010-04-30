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
        def match_types
          return self.search_types[:search_type_regexes].map do |key,value|
            self.search_query.match(value) ? key : nil
          end.compact
        end

        # type param might be an array of types
        def valid_type_modifiers(anytext, type, multiple_types_as_one = false)
          puts "checking valid_type_modifiers: #{anytext}, type: #{type.inspect}, multiple_types_as_one: #{multiple_types_as_one}" if self.verbose_types
          # Weed out invalid type requests
          if multiple_types_as_one
            #when using multiple types as one the keys are the modifiers, and the values are the search types
            allowed = self.search_type_keys & type
            valid_mods = allowed.map do |mod|
              self.get_search_type_from_modifier(mod)
            end.flatten.compact
          else
            #when NOT using multiple types as one the keys are the types, and the values are the modifiers
            type = self.make_symring(type)
            return [] unless self.search_type_keys.include?(type)
            mods = self.get_type_modifiers(anytext, type)
            searchie = self.type_modifiers_to_search_types
            matchie = self.match_types
            valid_mods = mods.select do |mod|
              indy = matchie.index(searchie[mod])
              puts "type mod #{mod.inspect} => #{searchie[mod].inspect} == #{indy ? matchie[indy].inspect : "nil"} == #{type.inspect}" if self.verbose_types
              !indy.nil? &&
                !matchie.nil? &&
                !searchie.nil? &&
                self.symring_equalizer(searchie[mod], type) && self.symring_equalizer(matchie[indy], type)
#                (multiple_types_as_one ? type.include?(searchie[mod]) : self.symring_equalizer(searchie[mod], type)) &&
#                (multiple_types_as_one ? type.include?(matchie[indy]) : self.symring_equalizer(matchie[indy], type))
            end
          end
          puts "valid_type_modifiers: #{valid_mods.inspect}" if self.verbose_types
          return valid_mods
        end

        def get_type_modifiers(anytext, type = nil, multiple_types_as_one = false)
          mods = anytext.scan(self.search_type_modifiers_regex(false, multiple_types_as_one)).flatten.compact.reject {|x| x == ''}
          #If no type mods are in the search string then the type requested is valid so we pretend it was requested as a modifier
          mods = mods.empty? ? multiple_types_as_one ? type : [self.search_types[:search_types_to_type_modifiers][self.make_symring(type)]] : mods
          puts "get_type_modifiers: #{mods.inspect}" if self.verbose_types
          mods
        end

        def get_search_type_from_modifier(mod)
          self.search_types[:search_types_to_type_modifiers][mod]
        end
        
        def search_type_modifiers_regex(whitespace = false, multiple_types_as_one = false)
          #return self.modifier_regex_from_arrays(self.looped_array(self.search_type_modifiers), whitespace)
          self.modifier_regex_from_array(multiple_types_as_one ? self.search_type_keys : self.search_type_modifiers, whitespace)
        end

      end # end of ClassMethods

      #INSTANCE METHODS
      def valid_search_type_inception?
        self.class.search_types[:search_type_inceptions][self.search_type] <= self.search_query.length
      end

    end
  end
end
