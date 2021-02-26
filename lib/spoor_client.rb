# frozen_string_literal: true

require 'digest'
require 'email_address'
require 'maxmind/geoip2'

require_relative "spoor_client/metadata_builder"
require_relative "spoor_client/sanitiser"
require_relative "spoor_client/version"

module SpoorClient
  class Error < StandardError; end
  # Your code goes here...
end
