class Integration

  def initialize(integration, base_image_tag, spec_file_path)

    # set up logger
    @logger = Logger.new(STDOUT)

    @integration = integration
    @tmpdir = "tmp/#{@integration['name']}"
    @base_image_tag = base_image_tag
    @spec_dir = "#{Dir.pwd}/#{spec_file_path}/.." # directory containing the spec file - all paths defined within it are relative to it

  end

  def run(debug)

    success = true

    begin
    
      print "Running tests for #{@integration['name']}\n"

      # create our temporary working directory
      FileUtils.mkdir_p("#{@tmpdir}/modules")

      # pull out our goss tests and write to a file
      File.open("#{@tmpdir}/goss.yaml",'w') do |file|
        file.write(@integration['goss-tests'].to_yaml)
      end

      # build our dockerfile, defining the image which will apply our manifest and run our tests
      ContainerHelper.build_dockerfile('main.dockerfile.erb', "#{@tmpdir}/Dockerfile", {:base_image => @base_image_tag})

      # copy in module fixtures
      add_module_fixtures()

      # copy in other file fixtures
      FileUtils.mkdir_p("#{@tmpdir}/files")
      file_fixtures = @integration['fixtures']['files']
      if file_fixtures
        for file in file_fixtures do
          FileUtils.cp_r("#{@spec_dir}/#{file}", "#{@tmpdir}/files/")
        end
      end

      # run our tests
      success = run_tests(debug)

    rescue => ex

      success = false
      @logger.error ex.message
      @logger.error ex.backtrace.join("\n")
    
    else
    
      print "Test run #{@integration['name']} completed\n"
    
    ensure
    
      # always remove the output directory unless we're running in debug mode
      if !debug
        FileUtils.rm_r("#{@tmpdir}")
      end

      return success
    
    end

  end

  def add_module_fixtures()

    rundir = Dir.pwd
    module_fixtures = @integration['fixtures']['modules']

    if module_fixtures
      for mod in module_fixtures do
        module_name = mod['name']
        module_path = "#{@spec_dir}/#{mod['path']}"
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

    result = false

    # copy in the Puppet manifest to use for our test
    FileUtils.copy_file("#{@spec_dir}/#{@integration['manifest']}", "#{@tmpdir}/site.pp", preserve = false, dereference = true)

    # run the docker build from inside the 'out' directory
    image_name = "puppit-#{@integration['name']}-#{Time.now.to_i}"
    cmd = "docker build -t #{image_name} --progress=plain --no-cache ."
    Dir.chdir("#{@tmpdir}"){
      result = system(cmd)
    }

    # remove the created image unless we're in debug mode
    if !debug
      system("docker image rm #{image_name}")
    end

    return result

  end

end