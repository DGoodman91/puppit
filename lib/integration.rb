# todo
# shift all options to individual params
# comments !
# better structure!

class Integration

  def initialize(integration, base_image_tag, spec_file_path)

    # set up logger
    @logger = Logger.new(STDOUT)

    @integration = integration
    @base_image_tag = base_image_tag
    @spec_file_path = spec_file_path

  end

  def run(debug)

    begin
    
      print "Running tests for #{@integration['name']}\n"

      # set up some paths we'll need later on
      rundir = Dir.pwd # directory we're running from
      specdir = "#{rundir}/#{@spec_file_path}/.." # directory containing the spec file - all paths defined within it are relative to it
      @tmpdir = "tmp/#{@integration['name']}"

      # create our temporary working directory
      FileUtils.mkdir_p("#{@tmpdir}/modules")

      # pull out our goss tests and write to a file
      File.open("#{@tmpdir}/goss.yaml",'w') do |file|
        file.write(@integration['goss-tests'].to_yaml)
      end

      # build our dockerfile, defining the image which will apply our manifest and run our tests
      build_dockerfile()

      # copy in module fixtures
      add_module_fixtures(rundir)

      # copy in other file fixtures
      FileUtils.mkdir_p("#{@tmpdir}/files")
      file_fixtures = @integration['fixtures']['files']
      if file_fixtures
        for file in file_fixtures do
          FileUtils.cp_r("#{specdir}/#{file}", "#{@tmpdir}/files/")
        end
      end

      # copy in the Puppet manifest to use for our test
      FileUtils.copy_file("#{specdir}/#{@integration['manifest']}", "#{@tmpdir}/site.pp", preserve = false, dereference = true)

      # run our tests
      if !run_tests(debug)
        exit_code = 2
      end

    rescue => ex

      @logger.error ex.message
      @logger.error ex.backtrace.join("\n")
    
    else
    
      print "Test run #{@integration['name']} completed\n"
    
    ensure
    
      # always remove the output directory unless we're running in debug mode
      if !debug
        FileUtils.rm_r("#{@tmpdir}")
      end
        
    
    end

  end

  def build_dockerfile()
    # build the Dockerfile from the ERB template
    dockerfile_contents = ERB.new(File.read('main.dockerfile.erb')).result(binding)
    File.open("#{@tmpdir}/Dockerfile",'w') do |file|
      file.write(dockerfile_contents)
    end
  end

  def add_module_fixtures(rundir)
    specdir = "#{rundir}/#{@spec_file_path}/.." # directory containing the spec file - all paths defined within it are relative to it
    module_fixtures = @integration['fixtures']['modules']
    if module_fixtures
      for mod in module_fixtures do
        module_name = mod['name']
        module_path = "#{specdir}/#{mod['path']}"
        files = []
        FileUtils.mkdir_p("#{@tmpdir}/modules/#{module_name}")
        Dir.chdir("#{module_path}"){
          # since we might be nested inside the module, we need to exclude our own directory
          files = Dir.glob("*").reject { |file| file.start_with?('@integration') }
          FileUtils.cp_r(files, "#{rundir}/#{@tmpdir}/modules/#{module_name}")
        }
      end
    end
  end

  # our tests are run by building a docker image which applies a Puppet manifest then runs the goss tests
  def run_tests(debug)

    # run the docker build from inside the 'out' directory
    image_name = "puppit-#{@integration['name']}-#{Time.now.to_i}"
    cmd = "docker build -t #{image_name} --progress=plain --no-cache ."
    Dir.chdir("#{@tmpdir}"){
      return system(cmd)
    }

    # remove the created image unless we're in debug mode
    if !debug
      system("docker image rm #{image_name}")
    end

  end

end