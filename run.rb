# frozen_string_literal: true


# TODO
#   Separate out handling of 'failed tests' from 'encountered errors'
#   Full comments - what's the proper comment structure for ruby classes & functions?
#   Move more into ContainerHelper
#   Decouple from running the script from a single location 


# external dependencies
require 'erb'
require 'fileutils'
require 'logger'
require 'time'
require 'yaml'

# local dependencies
require File.join(File.dirname(__FILE__), "lib/argument_parser.rb") 
require File.join(File.dirname(__FILE__), "lib/integration.rb")
require File.join(File.dirname(__FILE__), "lib/container_helper.rb")
require File.join(File.dirname(__FILE__), "lib/erb_helper.rb")
require File.join(File.dirname(__FILE__), "lib/file_helper.rb")

# parse command line arguments
options = ArgumentParser.parse
use_repo_image = options[:userepoimage]
image_tag = options[:imagetag]
spec_file_path = options[:specfilepath]
debug_mode = options[:debug]

# create our temp directory & set up some paths we'll need later on
FileUtils.mkdir_p('tmp')
rundir = Dir.pwd # directory we're running from
specfile = "#{rundir}/#{spec_file_path}"
base_dockerfile_path = 'base.dockerfile' # relative to location of this script

# read the config file in and parse its parts
file = YAML.load_file(specfile)
integrations = file['integrations']

# if we're not using a base image from a remote repo, build the base docker image
if !use_repo_image
  ContainerHelper.build_base_image(image_tag, 'base.dockerfile')
end


# run build and test each of the integrations one by one
all_tests_passed = true

for yaml_int in integrations do

  integration = Integration.new(yaml_int, image_tag, spec_file_path)

  if !integration.run(debug_mode)
    all_tests_passed = false
  end
    
end


if all_tests_passed
  print "All test passed for all integrations ^_^"
  exit 0
else
  print "There were test failures >.<"
  exit 2
end
