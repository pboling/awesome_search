require 'test/helper'

class TestAwesomeSearch < Test::Unit::TestCase

  context "An Awesome::Search instance" do
    setup do
      @awesome = Awesome::Search.new({:search_text => "this is a test", :search_type => :isbn, :search_locale => :amazon})
    end

    should "return search_query" do
      assert_equal 'this is a test', @awesome.search_query
    end
    should "return search_type" do
      assert_equal :isbn, @awesome.search_type
    end
    should "return search_locale" do
      assert_equal :amazon, @awesome.search_locale
    end
  end

  context "An Awesome::Search instance with query modifiers" do
    setup do
      @awesome = Awesome::Search.new({:search_text => ":ebay :sku this is a test"})
    end

    should "return search_query without query modifiers" do
      assert_equal 'this is a test', @awesome.search_query
    end
    should "search_type should be nil" do
      assert_equal nil, @awesome.search_type
    end
    should "return search_locale" do
      assert_equal nil, @awesome.search_locale
    end
  end

  context "#results_for with invalid params" do
    setup do
      @invalid_search = Awesome::Search.results_for(":local :text this is a test", ":upc", ":ebay")
    end

    should "invalid search should return nil" do
      assert @invalid_search.empty?
    end
  end

  context "#results_for with valid params" do
    setup do
      @searches = Awesome::Search.results_for(":local :amazon :text :isbn this is a test", ":text", ":local")
    end

    should "should return an array" do
      assert @searches.is_a?(Array)
    end

    should "for a single type, get a single result set" do
      assert @searches.length == 1
    end
    should "for a single type result set has results" do
      assert !@searches.first.found.nil?
    end
    should "valid search should return integer count" do
      assert @searches.first.count.is_a?(Integer)
    end
  end
end
