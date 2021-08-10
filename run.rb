require 'fileutils'
require 'optparse'
require 'yaml'

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

modulename = file['modulename']
modulepath = file['modulepath']

for integration in file['integrations'] do

    begin
    
        print "Running tests for " + integration['name'] + "\n"

        # create our temporary working directory
        FileUtils.mkdir_p('out')
        FileUtils.mkdir_p('out/modules')

        # pull out our goss tests and write to a file
        File.open("out/goss.yaml","w") do |file|
            file.write(integration['tests'].to_yaml)
        end

        # TODO optionally, allow an override of the dockerfile to use
        FileUtils.copy_file('main.dockerfile', 'out/Dockerfile', preserve = false, dereference = true)

        # copy in the module under test (since we might be nested inside the module, we need to exclude our own directory)
        # TODO also allow the exclude list to be specified in the data file
        files = []
        FileUtils.mkdir_p('out/modules/prometheus')

        Dir.chdir(Dir.pwd + "/../../prometheus"){
            print Dir.pwd + "\n"
            files = Dir.glob("*").reject { |file| file.start_with?("spec") }.reject { |file| file.start_with?("integration") }
            FileUtils.cp_r(files, "integration/out/modules/prometheus")
        }

        # copy in the Puppet manifest to use for our test
        FileUtils.copy_file(integration['manifest'], 'out/site.pp', preserve = false, dereference = true)

        # TODO fixtures! files & other modules - this is just a temp filler
        FileUtils.mkdir_p('out/files')

        # TODO can we parse the output of this and return an error code if appropriate?
        # run the docker build from inside the 'out' directory
        FileUtils.mkdir_p('out/images')
        cmd = 'docker build --progress=plain --no-cache -o images .'
        Dir.chdir('out'){
            system(cmd)
        }

    rescue => ex

        # TODO add exception handling
        logger.error e.message
        logger.error e.backtrace.join("\n")
    
    else
    
        # TODO add success handling :)
    
    ensure
    
        # always remove the output directory
        if !options[:debug]
            FileUtils.rm_r('out')
        end
        
    
    end

end