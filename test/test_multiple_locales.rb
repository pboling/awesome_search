require 'test/helper'

class TestMultipleLocales < Test::Unit::TestCase

  context "#results_for with multiple locales" do
    setup do
      @searches = Awesome::Search.results_for(":local :amazon :text :isbn this is a test", ":text", [":local",":amazon"])
    end
    should "should return an array" do
      assert @searches.is_a?(Array)
    end

    should "returns 1 result set per type:locale combination" do
      assert @searches.length == 2
    end
    should "all have results" do
      assert @searches.select {|x| x.found.is_a?(Array)}.length == 2
    end
    should "all have tally" do
      assert @searches.select {|x| x.tally.is_a?(Integer)}.length == 2
    end
  end

end
