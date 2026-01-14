# Gemini on Rails

This is a proof of concept showing how to run a Ruby on Rails application using the Gemini protocol.

## Getting Started

### Prerequisites
- Ruby 3.4+
- OpenSSL (for certificate generation)

### Setup
Run the setup script to install dependencies, prepare the database, and generate SSL certificates:

```bash
bin/setup --skip-server
```

> [!NOTE]
> The setup script automatically generates self-signed SSL certificates in `config/ssl/`. This folder is ignored by Git for security and to allow local-only development.

### Running the Gemini Server
Start the Gemini server using the standard Rails command:

```bash
bin/rails server
```

Alternatively, you can use the direct script:

```bash
bin/gemini_server
```

### Testing with the Client
You can use the included test client to verify the connection:

```bash
ruby bin/gemini_client.rb gemini://localhost/
```

## Protocol Details
The Gemini protocol is a lightweight alternative to HTTP. 
- It requires TLS for all connections.
- It uses a simplified request/response format.
- It prioritizes text content (Gemtext).
- It does not support cookies, JavaScript, or CSS.

## Implementation Notes
This project uses a custom Rack adapter (`bin/gemini_server`) that translates Gemini requests into Rack calls, allowing Rails controllers to handle them as if they were standard GET requests.
