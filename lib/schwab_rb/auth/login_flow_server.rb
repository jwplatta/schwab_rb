require "sinatra"
require "puma"
require "thread"

module SchwabRb::Auth
  class LoginFlowServer < Sinatra::Base
    class << self
      attr_accessor :queue
    end

    self.queue = Queue.new

    disable :logging

    get "/status" do
      "running"
    end

    def self.create_routes(root_path)
      get root_path do
        self.class.queue.push(request.url)
        "Callback received! You may now close this window/tab."
      end
    end

    def self.run_in_thread(callback_port: 4567, callback_path: "/", cert_file: nil, key_file: nil)
      create_routes(callback_path)

      thread = Thread.new do
        set :server, "puma"
        set :port, callback_port
        set :bind, "127.0.0.1"

        ctx = Puma::MiniSSL::Context.new.tap do |ctx|
          ctx.key = key_file.path
          ctx.cert = cert_file.path
          ctx.verify_mode = Puma::MiniSSL::VERIFY_NONE
        end

        puts ctx.inspect

        Puma::Server.new(self).tap do |server|
          server.add_ssl_listener("127.0.0.1", callback_port, ctx)
          server.run
        end
      end
      sleep 0.5
      thread
    end

    def self.stop
      Thread.list.each { |t| t.exit if t != Thread.main }
    end
  end
end
