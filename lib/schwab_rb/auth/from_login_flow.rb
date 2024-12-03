require 'openssl'
require 'uri'
require 'net/http'
require 'json'
require 'oauth2'
# require 'logger'

module SchwabRb::Auth
  class RedirectTimeoutError < StandardError
    def initialize(msg="Timed out waiting for a callback")
      super(msg)
    end
  end
  class RedirectServerExitedError < StandardError; end
  # class TokenExchangeError < StandardError
  #   def initialize(msg)
  #     super(msg)
  #   end
  # end
  class InvalidHostname < ArgumentError
    def initialize(hostname)
      msg = "Disallowed hostname #{hostname}. from_login_flow only allows callback URLs with hostname 127.0.0.1."
      super(msg)
    end
  end

  def self.from_login_flow(
    api_key,
    app_secret,
    callback_url,
    token_path,
    asyncio: false,
    enforce_enums: false,
    callback_timeout: 300.0,
    interactive: true,
    requested_browser: nil)

    callback_timeout = if not callback_timeout
      callback_timeout = 0
    elsif callback_timeout < 0
      raise ArgumentError, "callback_timeout must be non-negative"
    else
      callback_timeout
    end

    parsed = URI.parse(callback_url)
    raise InvalidHostname.new(parsed.host) unless parsed.host == "127.0.0.1"

    callback_port = parsed.port || 4567
    callback_path = parsed.path.empty? ? "/" : parsed.path

    # NOTE: create a self-signed certificate
    key = OpenSSL::PKey::RSA.new(2048)
    cert = OpenSSL::X509::Certificate.new

    cert.subject = OpenSSL::X509::Name.parse("/CN=127.0.0.1")
    cert.issuer = cert.subject
    cert.public_key = key.public_key
    cert.not_before = Time.now
    cert.not_after = Time.now + (60 * 60 * 24) # 1 day
    cert.serial = 0x0
    cert.version = 2
    cert.sign(key, OpenSSL::Digest::SHA256.new)

    cert_file = Tempfile.new("cert.pem")
    cert_file.write(cert.to_pem)
    cert_file.close

    key_file = Tempfile.new("key.pem")
    key_file.write(key.to_pem)
    key_file.close

    server_thread = SchwabRb::Auth::LoginFlowServer.run_in_thread(
      callback_port: callback_port,
      callback_path: callback_path,
      cert_file: cert_file,
      key_file: key_file
    )

    begin
      # NOTE: wait for server to start
      start_time = Time.now
      while true
        begin
          uri = URI("https://127.0.0.1:#{callback_port}/status")
          # resp = Net::HTTP.get_response(uri)

          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.ca_file = cert_file.path

          http.set_debug_output($stdout)

          resp = http.get(uri.path)

          break if resp.is_a?(Net::HTTPSuccess)
        rescue Errno::ECONNREFUSED
          sleep 0.1
        end

        raise RedirectServerExitedError if Time.now - start_time > 5
      end

      auth_context = self.build_auth_context(api_key, callback_url)

      puts <<~MESSAGE
      ***********************************************************************
      Open this URL in your browser to log in:
      #{auth_context.authorization_url}
      ***********************************************************************
      MESSAGE

      if interactive
        puts "Press ENTER to open the browser..."
        gets
      end

      `open "#{auth_context.authorization_url}}"`

      timeout_time = Time.now + callback_timeout
      received_url = nil

      while Time.now < timeout_time
        unless LoginFlowServer.queue.empty?
          received_url = LoginFlowServer.queue.pop
          break
        end
        sleep 0.1
      end

      raise RedirectTimeoutError.new unless received_url

      self.client_from_received_url(
        api_key,
        app_secret,
        auth_context,
        received_url,
        token_path
      )
    ensure
      LoginFlowServer.stop
    end
  end

  def self.build_auth_context(api_key, callback_url, state: nil)
    oauth = OAuth2::Client.new(
      api_key,
      nil,
      site: SchwabRb::Constants::SCHWAB_BASE_URL,
      authorize_url: "/v1/oauth/authorize",
      connection_opts: { ssl: { verify: false } }
    )

    auth_params = { redirect_uri: callback_url }
    auth_params[:state] = state if state
    authorization_url = oauth.auth_code.authorize_url(auth_params)

    AuthContext.new(callback_url, authorization_url, state)
  end

  def self.client_from_received_url(
    api_key, app_secret, auth_context, received_url, token_path, enforce_enums: true
  )
    oauth = OAuth2::Client.new(
      api_key,
      app_secret,
      site: SchwabRb::Constants::SCHWAB_BASE_URL,
      token_url: "/v1/oauth/token"
    )
    uri = URI.parse(received_url)
    params = URI.decode_www_form(uri.query).to_h
    authorization_code = params["code"]

    token = oauth.auth_code.get_token(authorization_code, redirect_uri: auth_context.callback_url)

    metadata_manager = SchwabRb::Auth::TokenManager.new(
      token,
      Time.now.to_i,
      token_path: token_path
    )
    metadata_manager.to_file

    session = OAuth2::AccessToken.new(
      oauth,
      token.token,
      refresh_token: token.refresh_token,
      expires_at: token.expires_at
    )

    SchwabRb::Client.new(
      api_key,
      session,
      token_metadata: metadata_manager,
      enforce_enums: enforce_enums
    )
  end
end
