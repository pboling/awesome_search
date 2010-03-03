require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require File.join(File.dirname(__FILE__), "..", "init")

require "test/search_classes/amazon"
require "test/search_classes/ebay"
require "test/search_classes/google"
require "test/search_classes/local"

class Test::Unit::TestCase
  Awesome::Search.verbose = false
  Awesome::Search.verbose_types = false
  Awesome::Search.verbose_filters = false
  Awesome::Triage.verbose = false
  Awesome::Triage.verbose_locales = false

  Awesome::Triage.configure_search_locales do |config|
    config[:search_locales_to_classes] =
      { ":local" =>   "Local",
        ":amazon" =>  "Amazon",
        ":google" =>  "Google",
        ":ebay" =>    "Ebay" }
    config[:search_locales_to_locale_modifiers] =
      {
        ":local" =>
          [ ":local" ],
        ":amazon" =>
          [ ":amazon",
            ":amzn",
            ":amz",
            ":am"],
        ":google" =>
          [ ":google",
            ":goog",
            ":goo",
            ":go"],
        ":ebay" =>
          [ ":ebay",
            ":eby",
            ":eb"]
      }
    config[:locale_modifiers_to_search_locales] =
      {
        ":local"  => ":local",
        ":amazon" => ":amazon",
        ":amz"    => ":amazon",
        ":amzn"   => ":amazon",
        ":am"     => ":amazon",
        ":google" => ":google",
        ":goog"   => ":google",
        ":goo"    => ":google",
        ":go"     => ":google",
        ":ebay"   => ":ebay",
        ":eby"    => ":ebay",
        ":eb"     => ":ebay"
      }
  end

  Awesome::Search.configure_search_types do |config|
    config[:search_types_to_type_modifiers] =
      {
        ":isbn" => ":isbn",
        ":sku" => ":sku",
        ":upc" => ":upc",
        ":asin" => ":asin",
        ":id" => ":dbid",
        ":text" => ":text"
      }
      # When using observer, how long should we wait before sending out search queries?
    config[:search_type_inceptions] =
      {
        ":isbn" => 10,
        ":sku" => 8,
        ":upc" => 10,
        ":asin" => 10,
        ":id" => 1,
        ":text" => 4
      }
    config[:search_type_regexes] =
      {
        ":isbn" => /\d{10}$|^\d{13}/,            #match 10 or 13 digits for isbn
        ":sku" => /[0-9a-zA-Z\-]+/,              #match any alphanumeric
        ":upc" => /\d{10}$|^\d{12}/,
        ":asin" => /\w{10}/,
        ":id" => /\d+/,
        ":text" => /\w{4}/
      }
  end

  Awesome::Search.configure_search_filters do |config|
    config[:search_filters_to_filter_modifiers] =
      {
        ":all" =>
          [ ":all",
            ":every" ],
        ":spotted" =>
          [ "spotted" ],
        ":old" =>
          [ ":old",
            ":ancient",
            ":wrinkly",
            ":grey"],
        ":new" =>
          [ ":new",
            ":shiny",
            ":fresh"]
      }
    config[:filter_modifiers_to_search_filters] =
      {
        ":all"      => ":all",
        ":every"    => ":all",
        ":spotted"  => ":spotted",
        ":old"      => ":old",
        ":ancient"  => ":old",
        ":wrinkly"  => ":old",
        ":grey"     => ":old",
        ":new"      => ":new",
        ":shiny"    => ":new",
        ":fresh"    => ":new"
      }
  end
end
