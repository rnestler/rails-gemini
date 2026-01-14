require 'openssl'
require 'socket'

module Gemini
  class Server
    def self.start(app, host: 'localhost', port: 1965, cert_path: 'config/ssl/server.crt', key_path: 'config/ssl/server.key')
      new(app, host: host, port: port, cert_path: cert_path, key_path: key_path).start
    end

    def initialize(app, host:, port:, cert_path:, key_path:)
      @app = app
      @host = host
      @port = port
      @cert = OpenSSL::X509::Certificate.new(File.read(cert_path))
      @key = OpenSSL::PKey::RSA.new(File.read(key_path))
    end

    def start
      server_socket = TCPServer.new(@port)
      ssl_context = OpenSSL::SSL::SSLContext.new
      ssl_context.cert = @cert
      ssl_context.key = @key
      ssl_server = OpenSSL::SSL::SSLServer.new(server_socket, ssl_context)

      puts "Gemini server started on gemini://#{@host}:#{@port}"

      loop do
        begin
          client = ssl_server.accept
          handle_request(client)
        rescue => e
          puts "Error handling request: #{e.message}"
          puts e.backtrace
        end
      end
    end

    private

    def handle_request(client)
      request = client.gets
      return unless request

      uri = URI.parse(request.strip) rescue nil
      unless uri
        client.print "59 Invalid request\r\n"
        client.close
        return
      end

      env = {
        'REQUEST_METHOD' => 'GET',
        'SCRIPT_NAME'    => '',
        'PATH_INFO'      => uri.path.empty? ? '/' : uri.path,
        'QUERY_STRING'   => uri.query || '',
        'SERVER_NAME'    => uri.host || @host,
        'SERVER_PORT'    => uri.port || @port,
        'rack.version'   => Rack::VERSION,
        'rack.url_scheme'=> 'gemini',
        'rack.input'     => StringIO.new(''),
        'rack.errors'    => $stderr,
        'rack.multithread' => true,
        'rack.multiprocess' => false,
        'rack.run_once'     => false,
        'CONTENT_TYPE'      => 'text/gemini',
        'HTTP_ACCEPT'       => 'text/gemini',
        'HTTP_HOST'         => uri.host || @host
      }

      puts "Request: #{request.strip}"
      status, headers, body = @app.call(env)
      
      gemini_status = case status
                      when 200..299 then "20"
                      when 300..399 then "30"
                      when 404 then "51"
                      else "40"
                      end

      puts "Response Status: #{status} -> Gemini: #{gemini_status}"

      if gemini_status == "20"
        mime_type = headers['Content-Type']&.split(';')&.first || 'text/gemini'
        client.print "#{gemini_status} #{mime_type}\r\n"
        body.each { |part| client.print part }
      elsif gemini_status == "30"
        location = headers['Location']
        client.print "#{gemini_status} #{location}\r\n"
      else
        client.print "#{gemini_status} Server Error\r\n"
      end

      client.close
    end
  end
end
