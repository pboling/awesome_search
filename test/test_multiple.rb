require 'test/helper'

class TestMultiple < Test::Unit::TestCase

  context "#results_for with multiple types AND multiple locales" do
    setup do
      @searches = Awesome::Search.results_for(":local :amazon :text :isbn this is a test 1234567890", [":text",":isbn"], [":local",":amazon"])
    end
    should "should return an array" do
      assert @searches.is_a?(Array)
    end

    should "returns multiple result sets" do
      assert @searches.length > 1
    end
    should "all have results" do
      assert @searches.select {|x| !x.results.nil?}.length == 4
    end
    should "all have count" do
      assert @searches.select {|x| x.count.is_a?(Integer)}.length == 4
    end
  end

end
