require 'rubygems'

#require 'bundler/setup' #if ENV['BUNDLE_GEMFILE'] && File.exists?(ENV['BUNDLE_GEMFILE'])

require 'aws-sdk'
require 'optparse'
require 'ffi'

require 'cloudscopes/version'
require 'cloudscopes/configuration'
require 'cloudscopes/options'
require 'cloudscopes/globals'
require 'cloudscopes/sample'
require 'cloudscopes/memory'
require 'cloudscopes/system'
require 'cloudscopes/filesystem'
require 'cloudscopes/redis'
require 'cloudscopes/network'

module Cloudscopes

  def self.get_binding
    return binding()
  end

  def self.method_missing(*args)
    Cloudscopes.const_get(args.shift.to_s.capitalize).new(*args)
  end

end
