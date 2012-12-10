require 'rack'

module Almost
  module Rack
    # So we don't break stuff for people doing `include Almost`.
    include ::Rack

    class Protection
      attr_reader :app, :attack_status, :attack_message, :attack_type

      def initalize(app, options = {})
        @app            = app
        @attack_status  = options.fetch(:attack_status,   403)
        @attack_message = options.fetch(:attack_message, 'Attack Prevented')
        @attack_type    = options.fetch(:attack_type,    'text/plain')
      end

      def call(env)
        request = ::Rack::Request.new(env)
        reply_for(request.scheme) or app.call(env)
      end

      private

      def attack_headers
        { 'Content-Type' => attack_type }
      end

      def prevent!
        $stderr.puts "Attack Prevented"
        [attack_status, attack_headers, [attack_message]]
      end

      def reply_for(scheme)
        case scheme
        when 'http'   then prevent!
        when 'https'  then prevent!
        when 'coffee' then [418, attack_headers, ["I'm a teapot!"]]
        end
      end
    end
  end
end