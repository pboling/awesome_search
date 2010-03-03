module Awesome
  module Definitions
    module Bits

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods

        def get_class(name)
          const_get(name) unless name.blank?
        end

        def modifier_regex_from_array(arr, whitespace = false)
          self.modifier_regex(self.array_to_middle_regex(arr, whitespace))
        end

        def array_to_middle_regex(arr, whitespace = false)
          whitespace ? '\s?' + arr.join('\s?|\s?') + '\s?' :
                  arr.join('|')
        end

        def modifier_regex(middle)
          Regexp.new(middle)
        end

        # In dealing with symbols and strings and params from requests
        #  comparisons can fail even when we want them to pass.
        # This prevents those unwanted failures
        # We will compare strings of this format ":ebay"
        def symring_equalizer(one, two)
          return self.make_symring(one) == self.make_symring(two)
        end

        def make_symring(var)
          if var.is_a?(Symbol)
            return ":#{var}"
          elsif var.is_a?(String)
            var.include?(':') ? var.strip : ":#{var.strip}"
          end
        end

        def unmake_symring(var)
          return "#{var}".delete(':')
        end

        #def modifier_regex_from_arrays(arr, whitespace = false)
        #  self.modifier_regex(array_of_arrays_to_middle_regex(arr, whitespace))
        #end

        #Returns a string of a partial regex
        #def array_of_arrays_to_middle_regex(arr, whitespace = false)
        #  arr = arr.map do |array|
        #    "(" + self.array_to_middle_regex(array, whitespace) + ")"
        #  end
        #  arr.join('|')
        #end

        #def looped_array(a)
        #  b = []
        #  a.length.times do
        #    b << Array.new(a.insert(0,a.pop))
        #  end
        #  b
        #end

      end
    end
  end
end
