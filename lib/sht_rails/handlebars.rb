require "handlebars"
require "active_support"

module ShtRails

  module Handlebars
    def self.call(template)
      if template.locals.include?(ShtRails.action_view_key.to_s) || template.locals.include?(ShtRails.action_view_key.to_sym)
<<-SHT
  hbs_context_for_sht = Handlebars::Context.new
  hbs_context_for_sht.register_helper('helperMissing') do |name, *args|
    meth, *params, options = args

    if handlebars.respond_to?(meth)
      handlebars.send(meth, *params)
    elsif self.respond_to?(meth)
      params_for_helper = params.map do |param|
        if param.kind_of?(V8::Object)
          param.to_a.inject({}) do |hash, value|
            hash[value.first] = value.last
            hash
          end
        else
          param
        end
      end
      result = self.send(meth, *params_for_helper)
      if result.respond_to?(:html_safe?) and result.html_safe?
        Handlebars::SafeString.new(result)
      else
        result
      end

    elsif params.size == 0
      ""
    else
      raise "Could not find property '\#\{meth\}'"
    end
  end
  partials.each do |key, value|
    hbs_context_for_sht.register_partial(key, value)
  end if defined?(partials) && partials.is_a?(Hash)
  hbs_context_for_sht.compile(#{template.source.inspect}).call(#{ShtRails.action_view_key.to_s} || {}).html_safe
SHT
      else
        "#{template.source.inspect}.html_safe"
      end
    end
  end
end

ActiveSupport.on_load(:action_view) do
  ActionView::Template.register_template_handler(::ShtRails.template_extension.to_sym, ::ShtRails::Handlebars)
end