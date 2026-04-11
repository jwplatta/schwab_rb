# frozen_string_literal: true

require "spec_helper"
require "stringio"

describe SchwabRb::Auth do
  describe ".build_auth_context" do
    it do
      SchwabRb::Auth.build_auth_context(
        "api_key", "https://127.0.0.1:8182", state: nil
      )
    end
  end

  describe ".open_browser" do
    before do
      %i[mac? windows? linux?].reject { |e| e == os_signal }.each do |signal|
        allow(described_class::OS).to receive(signal).and_return(false)
      end
      allow(described_class::OS).to receive(os_signal).and_return(true)
    end

    let(:launcher) do
      Class.new do
        attr_reader :open_args

        def open(args)
          @open_args = args
        end
      end.new
    end

    let(:os_signal) { raise "should be implemented for each scenario" }

    context 'when on Mac' do
      let(:os_signal) { :mac? }

      it "interprets a browser application argument" do
        described_class.open_browser("/Applications/Some Fake Browser", "example.com", browser_launcher: launcher)
        expect(launcher.open_args).to eq [
          "open",
          "-a",
          "/Applications/Some\\ Fake\\ Browser",
          "\"example.com\""
        ]
      end

      it "ignores a nil browser application argument" do
        described_class.open_browser(nil, "example.net", browser_launcher: launcher)
        expect(launcher.open_args).to eq [
          "open",
          "\"example.net\""
        ]
      end
    end

    context 'when on Linux' do
      let(:os_signal) { :linux? }

      it "ignores a browser application argument" do
        described_class.open_browser("/Applications/Some Fake Browser", "example.com", browser_launcher: launcher)
        expect(launcher.open_args).to eq [
          "xdg-open",
          "\"example.com\""
        ]
      end

      it "ignores a nil browser application argument" do
        described_class.open_browser(nil, "example.net", browser_launcher: launcher)
        expect(launcher.open_args).to eq [
          "xdg-open",
          "\"example.net\""
        ]
      end
    end

    context 'when on Windows' do
      let(:os_signal) { :windows? }

      it "ignores a browser application argument" do
        described_class.open_browser("/Applications/Some Fake Browser", "example.com", browser_launcher: launcher)
        expect(launcher.open_args).to eq [
          "start",
          "msedge",
          "\"example.com\""
        ]
      end

      it "ignores a nil browser application argument" do
        described_class.open_browser(nil, "example.net", browser_launcher: launcher)
        expect(launcher.open_args).to eq [
          "start",
          "msedge",
          "\"example.net\""
        ]
      end
    end
  end

  describe ".from_login_flow" do
    xit do
      expect do
        client = SchwabRb::Auth.init_client_login(
          ENV.fetch("SCHWAB_API_KEY", nil),
          ENV.fetch("SCHWAB_APP_SECRET", nil),
          ENV.fetch("APP_CALLBACK_URL", nil),
          ENV.fetch("TOKEN_PATH", nil)
        )
        puts client
      end.to_not raise_error
    end
  end

  describe ".init_client_login" do
    it "reads the enter prompt from the provided input instead of ARGF" do
      cert_file = instance_double(Tempfile, path: "/tmp/cert.pem")
      key_file = instance_double(Tempfile, path: "/tmp/key.pem")
      auth_context = instance_double(SchwabRb::Auth::AuthContext, authorization_url: "https://example.com/auth")
      queue = instance_double(Thread::Queue, empty?: false, pop: "https://127.0.0.1:8182?code=abc")
      http = instance_double(Net::HTTP)
      response = Net::HTTPSuccess.new("1.1", "200", "OK")
      input = StringIO.new("\n")

      allow(described_class).to receive(:create_ssl_certificate).and_return([cert_file, key_file])
      allow(SchwabRb::Auth::LoginFlowServer).to receive(:run_in_thread)
      allow(SchwabRb::Auth::LoginFlowServer).to receive(:stop)
      allow(SchwabRb::Auth::LoginFlowServer).to receive(:queue).and_return(queue)
      allow(described_class).to receive(:build_auth_context).and_return(auth_context)
      allow(described_class).to receive(:open_browser)
      allow(described_class).to receive(:client_from_received_url).and_return(:client)
      allow(Net::HTTP).to receive(:new).and_return(http)
      allow(http).to receive(:use_ssl=)
      allow(http).to receive(:ca_file=)
      allow(http).to receive(:set_debug_output)
      allow(http).to receive(:get).and_return(response)

      original_argv = ARGV.dup
      ARGV.replace(["login"])

      expect(
        described_class.init_client_login(
          "api-key",
          "app-secret",
          "https://127.0.0.1:8182",
          "/tmp/token.json",
          input: input
        )
      ).to eq(:client)
    ensure
      ARGV.replace(original_argv || [])
    end
  end
end
