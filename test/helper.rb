require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require File.join(File.dirname(__FILE__), "..", "init")

class Test::Unit::TestCase
  #AwesomeSearch.verbose = true
end
