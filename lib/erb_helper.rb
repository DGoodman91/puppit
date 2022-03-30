class ERBHelper
    
    def self.build_template(template, template_parameters)

        return ERB.new(template).result(binding)
        
    end

end