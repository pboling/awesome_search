require 'test/helper'

class TestMultipleFilters < Test::Unit::TestCase

  context "#results_for with multiple filters" do
    setup do
      @searches = Awesome::Search.results_for(":local :amazon :text :isbn :old this is a test 1234567890", ":text", ":local", [":old",":spotted",":shiny",":new"])
    end
    should "should return an array" do
      assert @searches.is_a?(Array)
    end

    should "returns 1 result set per type:locale combination" do
      assert @searches.length == 1
    end
    should "all have results" do
      assert @searches.select {|x| !x.results.nil?}.length == 1
    end
    should "all have count" do
      assert @searches.select {|x| x.count.is_a?(Integer)}.length == 1
    end
    should "all have search_filters" do
      assert @searches.select {|x| !x.search_filters.nil?}.length == 1
    end
    should "have search_filters == [':old',':spotted',':new']" do
      #:shiny is filtered out, as it is not a filter mod for the backend, only an alias for the front end
      assert @searches.select {|x| x.search_filters == [":old",":spotted",":new"]}.length == 1
    end
  end

end
