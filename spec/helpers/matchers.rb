# custom matcher for chefspec to help testing the web_app definition from apache cookbook
# actually should rather be part of the apache cookbook
# adaption of : https://github.com/stevendanna/logrotate/pull/38

# example

# it "should create appropriate log rotate config for foobar log" do
#   expect(runner).to enable_apache_web_app("foobar").with(
#     ssl_keyfile_path  = "/etc/ssl/private/ssl-cert-snakeoil.key"
#     ssl_certfile: "/etc/ssl/certs/ssl-cert-snakeoil.pem"
#    )
# end

if defined?(ChefSpec)
  def enable_apache_web_app(name)
    ApacheWebAppMatcher.new(name)
  end

  class ApacheWebAppMatcher
    def initialize(name)
      @name = name
    end

    def with(parameters = {})
      params.merge!(parameters)
      self
    end

    def at_compile_time
      raise ArgumentError, 'Cannot specify both .at_converge_time and .at_compile_time!' if @converge_time
      @compile_time = true
      self
    end

    def at_converge_time
      raise ArgumentError, 'Cannot specify both .at_compile_time and .at_converge_time!' if @compile_time
      @converge_time = true
      self
    end

    #
    # Allow users to specify fancy #with matchers.
    #
    def method_missing(m, *args, &block)
      if m.to_s =~ /^with_(.+)$/
        with($1.to_sym => args.first)
        self
      else
        super
      end
    end

    def description
      %Q{"enable" #{@name} "web_app"}
    end

    def matches?(runner)
      @runner = runner

      if resource
        resource.performed_action?('create') && unmatched_parameters.empty? && correct_phase?
      else
        false
      end
    end

    def failure_message
      if resource
        if resource.performed_action?('create')
          if unmatched_parameters.empty?
            if @compile_time
              %Q{expected "#{resource.to_s}" to be run at compile time}
            else
              %Q{expected "#{resource.to_s}" to be run at converge time}
            end
          else
            %Q{expected "#{resource.to_s}" to have parameters:} \
            "\n\n" \
            "  " + unmatched_parameters.collect { |parameter, h|
              "#{parameter} #{h[:expected].inspect}, was #{h[:actual].inspect}"
            }.join("\n  ")
          end
        else
          %Q{expected "#{resource.to_s}" actions #{resource.performed_actions.inspect}} \
          " to include : create"
        end
      else
        %Q{expected "web_app[#{@name}] with"} \
        " enable : true to be in Chef run. Other" \
        " #{@name} resources:" \
        "\n\n" \
        "  " + similar_resources.map(&:to_s).join("\n  ") + "\n "
      end
    end

    def failure_message_when_negated
      if resource
        message = %Q{expected "#{resource.to_s}" actions #{resource.performed_actions.inspect} to not exist}
      else
        message = %Q{expected "#{resource.to_s}" to not exist}
      end

      message << " at compile time"  if @compile_time
      message << " at converge time" if @converge_time
      message
    end

    private
      def unmatched_parameters
        return @_unmatched_parameters if @_unmatched_parameters

        @_unmatched_parameters = {}

        params.each do |parameter, expected|
          unless matches_parameter?(parameter, expected)
            @_unmatched_parameters[parameter] = {
              expected: expected,
              actual:   safe_send('variables')[:params][parameter],
            }
          end
        end

        @_unmatched_parameters
      end

      def matches_parameter?(parameter, expected)
        # apache web_app stores "anything" inside :params as array, so we just lookup for variables[:params]
        #expected == safe_send('variables')['params']
        expected == safe_send('variables')[:params][parameter]
      end

      def correct_phase?
        if @compile_time
          resource.performed_action('create')[:compile_time]
        elsif @converge_time
          resource.performed_action('create')[:converge_time]
        else
          true
        end
      end

      def safe_send(parameter)
        resource.send(parameter)
      rescue NoMethodError
        nil
      end

      def similar_resources
        @_similar_resources ||= @runner.find_resources('template')
      end

      def resource
        @_resource ||= @runner.find_resource('template',  "/etc/apache2/sites-available/#{@name}.conf")
      end

      def params
        @_params ||= {}
      end
  end
end