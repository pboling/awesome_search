module SearchDefinitions
  module Types
    def self.included(base)
      base.extend ClassMethods
      base.cattr_accessor :search_types
    end

    module ClassMethods


      def configure_search_types(&block)
        yield @@search_types
      end

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

      def match_types(anytext)
        return self.search_types[:search_type_regexes].map do |key,value|
          self.clean_search_text(anytext).match(value) ? key : nil
        end.compact
      end

      def valid_type_modifiers(anytext, type)
        type = self.make_symring(type)
        # Weed out invalid type requests
        return false unless self.search_type_keys.include?(type)
        mods = self.get_type_modifiers(anytext, type)
        searchie = self.type_modifiers_to_search_types
        matchie = self.match_types(anytext)
        valid_mods = mods.select do |mod|
          indy = matchie.index(searchie[mod])
          puts "mod #{mod.class} #{mod.inspect} => #{searchie[mod].inspect} == #{indy ? matchie[indy].inspect : "nil"} == #{type.inspect} #{type.class} type" if self.verbose
          !indy.nil? &&
            !matchie.nil? &&
            !searchie.nil? &&
            self.symring_equalizer(searchie[mod], type) &&
            self.symring_equalizer(matchie[indy], type)
        end
        puts "valid_mods: #{valid_mods.inspect}" if self.verbose
        return valid_mods
      end

      def get_type_modifiers(anytext, type)
        mods = anytext.scan(self.search_type_modifiers_regex(false)).flatten.compact
        #If no type mods are in the search string then the type requested is valid so we pretend it was requested as a modifier
        puts "mods #{mods.inspect}" if self.verbose
        mods.empty? ? [self.search_types[:search_types_to_type_modifiers][self.make_symring(type)]] : mods
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
