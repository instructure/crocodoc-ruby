require 'cgi'
require 'net/http'
require 'net/https'

require 'rubygems'
require 'json'

require 'crocodoc/api'

module Crocodoc
  class Error < StandardError; end
end
