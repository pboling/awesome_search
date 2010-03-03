require 'test/helper'

class TestMultipleTypes < Test::Unit::TestCase

  context "#results_for with multiple types as multiple types" do
    setup do
      @searches = Awesome::Search.results_for(":local :amazon :text :isbn this is a test 1234567890", [":text", ":isbn"], ":local")
    end
    should "should return an array" do
      assert @searches.is_a?(Array)
    end

    should "returns 1 result set per type:locale combination" do
      assert @searches.length == 2
    end
    should "all have results" do
      assert @searches.select {|x| !x.results.nil?}.length == 2
    end
    should "all have count" do
      assert @searches.select {|x| x.count.is_a?(Integer)}.length == 2
    end
  end

  context "#results_for with multiple types as single type" do
    setup do
      @searches = Awesome::Search.results_for(":local :amazon :text :isbn this is a test 1234567890", [":text", ":isbn"], ":local", nil, true)
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
  end
end
