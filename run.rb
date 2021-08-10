require 'fileutils'
require 'logger'
require 'optparse'
require 'time'
require 'yaml'

# set up logger
logger = Logger.new(STDOUT)

# parse command line args
options = {:debug => false}

parser = OptionParser.new do|opts|
	opts.banner = "Usage: ruby run.rb [options]"
	opts.on('-d', '--debug', 'Turn on debug mode') do
		options[:debug] = true;
	end

	opts.on('-h', '--help', 'Displays Help') do
		puts opts
		exit
	end
end

parser.parse!

# read the config file in and parse its parts
file = YAML.load_file('specs.yml')

for integration in file['integrations'] do

    begin
    
        print "Running tests for #{integration['name']}\n"

        # create our temporary working directory
        FileUtils.mkdir_p('out')
        FileUtils.mkdir_p('out/modules')

        # pull out our goss tests and write to a file
        File.open("out/goss.yaml","w") do |file|
            file.write(integration['tests'].to_yaml)
        end

        # TODO optionally, allow an override of the dockerfile to use
        FileUtils.copy_file('main.dockerfile', 'out/Dockerfile', preserve = false, dereference = true)

        # copy in module fixtures
        for mod in integration['fixtures']['modules'] do
            
            module_name = mod['name']
            module_path = mod['path']

            files = []
            FileUtils.mkdir_p("out/modules/#{module_name}")

            Dir.chdir("#{Dir.pwd}/#{module_path}"){
                # since we might be nested inside the module, we need to exclude our own directory
                files = Dir.glob("*").reject { |file| file.start_with?("integration") }
                FileUtils.cp_r(files, "integration/out/modules/#{module_name}")
            }

        end

        # copy in the Puppet manifest to use for our test
        FileUtils.copy_file(integration['manifest'], 'out/site.pp', preserve = false, dereference = true)

        # TODO file fixtures! this is just a temp filler
        FileUtils.mkdir_p('out/files')

        # TODO can we parse the output of this and return an error code if appropriate?
        # run the docker build from inside the 'out' directory
        image_name = "puppit-#{integration['name']}-#{Time.now.to_i}"
        print image_name
        cmd = "docker build -t #{image_name} --progress=plain --no-cache ."
        Dir.chdir('out'){
            system(cmd)
        }

        # remove the created image unless we're in debug mode
        if !options[:debug]
            system("docker image rm #{image_name}")
        end

    rescue => ex

        # TODO add exception handling
        logger.error ex.message
        logger.error ex.backtrace.join("\n")
    
    else
    
        # TODO add success handling :)
    
    ensure
    
        # always remove the output directory
        if !options[:debug]
            FileUtils.rm_r('out')
        end
        
    
    end

end