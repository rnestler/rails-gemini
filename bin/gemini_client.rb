#!/usr/bin/env ruby

require 'socket'
require 'openssl'
require 'uri'

url = ARGV[0] || "gemini://localhost/"
uri = URI.parse(url)

tcp_client = TCPSocket.new(uri.host || 'localhost', uri.port || 1965)
ssl_context = OpenSSL::SSL::SSLContext.new
# Gemini often uses self-signed certs
ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE 

ssl_client = OpenSSL::SSL::SSLSocket.new(tcp_client, ssl_context)
ssl_client.connect

ssl_client.puts url
puts ssl_client.read

ssl_client.close
