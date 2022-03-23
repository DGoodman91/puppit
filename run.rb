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

# create our temp directory
FileUtils.mkdir_p('tmp')

# set up some paths we'll need later on
rundir = Dir.pwd # directory we're running from
specfile = "#{rundir}/#{options[:specfilepath]}"

# read the config file in and parse its parts
file = YAML.load_file(specfile)


# if we're not using a base image from a remote repo, build the base docker image
if !options[:userepoimage]
  cmd = "docker build -t #{options[:imagetag]} -f base.dockerfile --progress=plain ."
  system(cmd)
end

for yaml_int in file['integrations'] do

  integration = Integration.new(yaml_int, options[:imagetag], options[:specfilepath])

  integration.run(options[:debug])
    
end

