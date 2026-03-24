# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

describe SchwabRb::Auth::TokenManager do
  let(:token) do
    SchwabRb::Auth::Token.new(
      token: "access_token",
      expires_in: 3600,
      token_type: "Bearer",
      scope: "openid",
      refresh_token: "refresh_token",
      id_token: "id_token",
      expires_at: 4_102_444_800
    )
  end

  it "does not raise error when subject is initialized" do
    expect { described_class.new(nil, nil) }.not_to raise_error
  end

  it "creates parent directories before writing the token file" do
    Dir.mktmpdir do |dir|
      token_path = File.join(dir, "nested", "token.json")
      manager = described_class.new(token, Time.now.to_i, token_path: token_path)

      manager.to_file

      expect(File).to exist(token_path)
    end
  end
end
