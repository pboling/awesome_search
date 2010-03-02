require "active_support" unless defined?(ActiveSupport)

require "search_definitions/bits"
require "search_definitions/locales"
require "search_definitions/types"
require "awesome_search" unless defined?(AwesomeSearch)
require "awesome_search/super_search"
require "awesome_search/search_amazon"
require "awesome_search/search_ebay"
require "awesome_search/search_google"
require "awesome_search/search_local"
