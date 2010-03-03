module Awesome
  class SuperSearch < Awesome::Search
    # Instance method Mixins
    def get_results
      return nil unless super
      # initialize the search result values since
      # if we've gotten this far we have a real search being executed
      # tally and results are set to nil in the main initializer
      # so that we can differentiate between searches that aborted
      # and searches that completed but had no results.
      self.found = []
      self.tally = 0
      return true
    end
  end
end
