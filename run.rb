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

    opts.on('-s', '--specfile=filepath', 'The relative path to the spec yaml file') do |filepath|
        options[:specfilepath] = filepath
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

# read the config file in and parse its parts
file = YAML.load_file(options[:specfilepath])

# set up some paths we'll need later on
rundir = Dir.pwd # directory we're running from
specdir = "#{rundir}/#{options[:specfilepath]}/.." # directory containing the spec file - all paths defined within it are relative to it

# iterate over our defined integrations, performing the provisioning, dependency setup, puppet run and test run for each
for integration in file['integrations'] do

    begin
    
        print "Running tests for #{integration['name']}\n"

        # create our temporary working directory
        FileUtils.mkdir_p('out')
        FileUtils.mkdir_p('out/modules')

        # pull out our goss tests and write to a file
        File.open("out/goss.yaml","w") do |file|
            file.write(integration['goss-tests'].to_yaml)
        end

        # copy in the Dockerfile
        FileUtils.copy_file('main.dockerfile', 'out/Dockerfile', preserve = false, dereference = true)

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
                    files = Dir.glob("*").reject { |file| file.start_with?("integration") }
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