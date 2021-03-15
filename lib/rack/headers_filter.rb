# lib/rack/headers_filter.rb

module Rack
  class HeadersFilter
    ALLOWED_HOSTS = %w[localhost]

    def initialize(app)
      @app = app
    end

    def call(env)
      env.delete('HTTP_X_FORWARDED_HOST')
      return redirect unless allowed_host?(env)

      @app.call(env)
    end

    private

    def allowed_host?(env)
      return true if env['PATH_INFO'].to_s == '/healthcheck'

      domain_with_port = ActionDispatch::Http::URL.extract_domain env['HTTP_HOST'], 1
      domain = domain_with_port.gsub(/:\d+$/, '')
      ALLOWED_HOSTS.include?(domain)
    end

    def redirect
      [
        301,
        { 'Location' => 'https://mysite.com', 'Content-Type' => 'text/html' },
        ['Moved Permanently']
      ]
    end
  end
end
