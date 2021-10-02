# frozen_string_literal: true

require 'erb'
require 'fileutils'
require 'logger'
require 'optparse'
require 'time'
require 'yaml'

# set up logger
logger = Logger.new(STDOUT)

# parse command line args
options = {:debug => false, :imagetag => 'goodmandev/puppit', :userepoimage => false}

parser = OptionParser.new do|opts|
	opts.banner = "Usage: ruby run.rb [options]"

    opts.on('-s', '--specfile=filepath', 'The relative path to the spec yaml file. Required') do |filepath|
        options[:specfilepath] = filepath
    end

    opts.on('-i', '--imagetag=tag', 'The tag to give the base Dockerfile created. Default goodmandev/puppit') do |tag|
        options[:imagetag] = tag
    end

    opts.on('-r', '--userepoimage', 'Skip the building of the base image, instead pulling the image from a local/remote repository') do
		options[:userepoimage] = true;
	end

	opts.on('-d', '--debug', 'Turn on debug mode') do
		options[:debug] = true;
	end

	opts.on('-h', '--help', 'Displays Help') do
		puts opts
		exit
	end
end

parser.parse!

exit_code = 0

# if we're not using a base image from a remote repo, build the base docker image
base_image_name = options[:imagetag]
if !options[:userepoimage]
    cmd = "docker build -t #{base_image_name} -f base.dockerfile --progress=plain ."
    system(cmd)
end

# set up some paths we'll need later on
rundir = Dir.pwd # directory we're running from
specfile = "#{rundir}/#{options[:specfilepath]}"
specdir = "#{specfile}/.." # directory containing the spec file - all paths defined within it are relative to it

# read the config file in and parse its parts
file = YAML.load_file(specfile)

# iterate over our defined integrations, performing the provisioning, dependency setup, puppet run and test run for each
for integration in file['integrations'] do

    begin
    
        print "Running tests for #{integration['name']}\n"

        # create our temporary working directory
        FileUtils.mkdir_p('out')
        FileUtils.mkdir_p('out/modules')

        # pull out our goss tests and write to a file
        File.open('out/goss.yaml','w') do |file|
            file.write(integration['goss-tests'].to_yaml)
        end

        # build the Dockerfile from the ERB template
        dockerfile_contents = ERB.new(File.read('main.dockerfile.erb')).result(binding)
        File.open('out/Dockerfile','w') do |file|
            file.write(dockerfile_contents)
        end

        # copy in module fixtures
        module_fixtures = integration['fixtures']['modules']
        if module_fixtures
            for mod in module_fixtures do
                
                module_name = mod['name']
                module_path = "#{specdir}/#{mod['path']}"

                files = []
                FileUtils.mkdir_p("out/modules/#{module_name}")

                Dir.chdir("#{module_path}"){
                    # since we might be nested inside the module, we need to exclude our own directory
                    files = Dir.glob("*").reject { |file| file.start_with?('integration') }
                    FileUtils.cp_r(files, "#{rundir}/out/modules/#{module_name}")
                }

            end
        end

        # copy in other file fixtures
        FileUtils.mkdir_p('out/files')
        file_fixtures = integration['fixtures']['files']
        if file_fixtures
            for file in file_fixtures do
                FileUtils.cp_r("#{specdir}/#{file}", 'out/files/')
            end
        end

        # copy in the Puppet manifest to use for our test
        FileUtils.copy_file("#{specdir}/#{integration['manifest']}", 'out/site.pp', preserve = false, dereference = true)        

        # run the docker build from inside the 'out' directory
        image_name = "puppit-#{integration['name']}-#{Time.now.to_i}"
        cmd = "docker build -t #{image_name} --progress=plain --no-cache ."
        result = nil
        Dir.chdir('out'){
            result = system(cmd)
        }
        if !result
            exit_code = 2
        end

        # remove the created image unless we're in debug mode
        if !options[:debug]
            system("docker image rm #{image_name}")
        end

    rescue => ex

        logger.error ex.message
        logger.error ex.backtrace.join("\n")
    
    else
    
        print "Test run #{integration['name']} completed\n"
    
    ensure
    
        # always remove the output directory unless we're running in debug mode
        if !options[:debug]
            FileUtils.rm_r('out')
        end
        
    
    end

end

if exit_code == 0
    print "All test runs passed\n"
else
    print "There were test failures\n"
end

exit exit_code