module ShtRails
  # Change config options in an initializer:
  #
  # ShtRails.template_extension = 'handlebars'
  #
  # Or in a block:
  #
  # ShtRails.configure do |config|
  #   config.template_extension = 'handlebars'
  # end

  module Config
    attr_accessor :template_base_path, :template_extension, :action_view_key, :template_namespace

    def configure
      yield self
    end
    
    def template_base_path
      @template_base_path ||= Rails.root.join("app", "templates")
    end

    def template_extension
      @template_extension ||= 'hbs'
    end
    
    def action_view_key
      @action_view_key ||= 'hbs'
    end
    
    def template_namespace
      @template_namespace ||= 'SHT'
    end
  end
end