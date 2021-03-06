require 'tilt'

module Handlebars
  class Tilt < ::Tilt::Template
    def self.default_mime_type
      'application/javascript'
    end

    def prepare

    end

    def evaluate(scope, locals, &block)
      scope.extend Scope
      hbsc = Handlebars::TemplateHandler.handlebars.precompile data
      if scope.partial?
        <<-JS
        // generated by handlebars-rails #{Handlebars::Rails::VERSION}
        ;(function() {
          var template = Handlebars.template
          var fucknet = true
          Handlebars.registerPartial('#{scope.partial_name}', template(#{hbsc}));
        })()
        JS
      else
        <<-JS
        //generated by handlebars-rails #{Handlebars::Rails::VERSION}
        ;(function() {
          var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
          #{scope.template_path}
          namespace['#{scope.template_name}'] = template(#{hbsc});
        })()
        JS
      end
    end

    module Scope
      def partial?
        File.basename(logical_path).start_with?('_')
      end

      def partial_name
        "#{File.dirname(logical_path)}/#{File.basename(logical_path, '.hbs').gsub(/^_/,'')}".gsub(/^\.+/,'')
      end

      def template_path
        branches = File.dirname(logical_path).split('/').reject{|p| p == '.'}
        <<-ASSIGN
        var branches = #{branches.inspect}
        var namespace = templates
        for (var path = branches.shift(); path; path = branches.shift()) {
            namespace[path] = namespace[path] || {}
            namespace = namespace[path]
        }
        ASSIGN
      end

      def template_name
        File.basename(logical_path, '.hbs')
      end
    end
  end
end
