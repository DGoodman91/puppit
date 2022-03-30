class ContainerHelper
    
  # build a container image with the given tag from the given dockerfile
  def self.build_base_image(image_tag, dockerfile)
    cmd = "docker build -t #{image_tag} -f #{dockerfile} --progress=plain ."
    system(cmd)
  end

  # build a Dockerfile from the ERB template and write to the given location
  def self.build_dockerfile(template_location, dockerfile_location, template_parameters)

    dockerfile_contents = ERBHelper.build_template(File.read(template_location), template_parameters)

    FileHelper.write_file(dockerfile_location, dockerfile_contents)

  end

end