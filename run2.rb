# frozen_string_literal: true

# external dependencies
require 'erb'
require 'fileutils'
require 'logger'
require 'time'
require 'yaml'

# local dependencies
require File.join(File.dirname(__FILE__), "lib/argument_parser.rb") 
require File.join(File.dirname(__FILE__), "lib/integration.rb") 

# parse command line arguments
options = ArgumentParser.parse


# set up some paths we'll need later on
rundir = Dir.pwd # directory we're running from
specfile = "#{rundir}/#{options[:specfilepath]}"

# read the config file in and parse its parts
file = YAML.load_file(specfile)

for yaml_int in file['integrations'] do
    
  integration = Integration.new(yaml_int, options)

  integration.run
    
end

