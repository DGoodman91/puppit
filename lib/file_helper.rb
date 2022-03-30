class FileHelper

  def self.write_file(dockerfile_location, dockerfile_contents)

    File.open("#{dockerfile_location}",'w') do |file|
      file.write(dockerfile_contents)
    end

  end

end