require 'handlebars-rails/version'
require 'handlebars-rails/tilt'
require 'handlebars-rails/template_handler'
require 'handlebars'

module Handlebars::Rails
  class Engine < ::Rails::Engine

    unless config.respond_to?(:handlebars)
      config.handlebars = ActiveSupport::OrderedOptions.new
    end
    config.handlebars.override_ember_precompiler = false

    initializer 'handlebars.handler.setup', :before => :add_view_paths do |app|
      app.paths['app/views'] << 'app/assets/javascripts/'
      ActiveSupport.on_load(:action_view) do
        ActionView::Template.register_template_handler(:hbs, ::Handlebars::TemplateHandler)
      end
    end

    initializer 'handlebars.precompiler.setup', :group => :all, :after => 'ember_rails.setup' do |app|
      if !defined?(Ember) || config.handlebars.override_ember_precompiler
        app.assets.append_path 'app/templates'
        app.assets.register_engine '.hbs', Handlebars::Tilt
      end
    end
  end
end
