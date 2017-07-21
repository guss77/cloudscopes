require 'ffi'

require 'cloudscopes/version'
require 'cloudscopes/configuration'
require 'cloudscopes/options'
require 'cloudscopes/globals'
require 'cloudscopes/sample'
require 'cloudscopes/memory'
require 'cloudscopes/system'
require 'cloudscopes/process'
require 'cloudscopes/filesystem'
require 'cloudscopes/redis'
require 'cloudscopes/network'
require 'cloudscopes/ec2'

module Cloudscopes

  def self.get_binding
    return binding()
  end

  def self.method_missing(*args)
    Cloudscopes.const_get(args.shift.to_s.capitalize).new(*args)
  end

end
