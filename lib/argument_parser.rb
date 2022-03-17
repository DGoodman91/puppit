require 'optparse'

class ArgumentParser

  def self.parse

      # parse command line opts
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

      return options

  end

end