require 'helper'

class TestAwesomeSearch < Test::Unit::TestCase
  context "An AwesomeSearch instance" do
    setup do
      @awesome = AwesomeSearch.new({:search_text => "this is a test", :search_type => :isbn, :search_locale => :amazon})
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

  context "An AwesomeSearch instance with query modifiers" do
    setup do
      @awesome = AwesomeSearch.new({:search_text => ":ebay :sku this is a test"})
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

  context "#results_for_type_and_locale with invalid params" do
    setup do
      @invalid_search = AwesomeSearch.results_for_type_and_locale(":local :text this is a test", ":upc", ":ebay")
    end

    should "invalid search should return nil" do
      assert @invalid_search.nil?
    end
  end

  context "#results_for_type_and_locale with valid params" do
    setup do
      @search = AwesomeSearch.results_for_type_and_locale(":local :amazon :text :isbn this is a test", ":text", ":local")
    end

    should "valid search should not return nil results" do
      assert !@search.results.nil?
    end
    should "valid search should return integer count" do
      assert @search.count.is_a?(Integer)
    end
  end
end
