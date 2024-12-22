# frozen_string_literal: true

require "spec_helper"

describe SchwabRb::Client do
  let(:api_key) { "test_api_key" }
  let(:app_secret) { "test_app_secret" }
  let(:token_manager) do
    token = SchwabRb::Auth::Token.new(
      token: "foobar",
      expires_in: 3600,
      token_type: "Bearer",
      scope: "openid",
      refresh_token: "refresh_token",
      id_token: "id_token",
      expires_at: Time.now.to_i + 3600
    )
    SchwabRb::Auth::TokenManager.new(token, Time.now.to_i)
  end
  let(:session) do
    oauth = OAuth2::Client.new(
      api_key,
      app_secret,
      site: SchwabRb::Constants::SCHWAB_BASE_URL,
      token_url: "/v1/oauth/token"
    )
    OAuth2::AccessToken.new(
      oauth,
      token_manager.token,
      refresh_token: token_manager.token.refresh_token,
      expires_at: token_manager.token.expires_at
    )
  end
  let(:client) do
    SchwabRb::Client.new(
      api_key,
      session,
      token_manager: token_manager,
      enforce_enums: true
    )
  end

  it "does not raise" do
    expect { described_class.new(nil, nil, token_manager: nil, enforce_enums: true) }.not_to raise_error
  end

  describe "accounts" do
    it "returns an array of accounts" do
      allow(session).to receive(:get).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory::AccountsResponse.body,
          status: ResponseFactory::AccountsResponse.status
        )
      )
      resp = client.get_accounts
      expect(resp.status).to eq(ResponseFactory::AccountsResponse.status)
      expect(resp.body).to eq(ResponseFactory::AccountsResponse.body)
    end
    it "returns account numbers" do
      allow(session).to receive(:get).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory::AccountNumbersResponse.body,
          status: ResponseFactory::AccountNumbersResponse.status
        )
      )
      resp = client.get_account_numbers
      expect(resp.status).to eq(ResponseFactory::AccountNumbersResponse.status)
      expect(resp.body).to eq(ResponseFactory::AccountNumbersResponse.body)
    end
    it "returns a specific account" do
      allow(session).to receive(:get).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory::AccountResponse.body,
          status: ResponseFactory::AccountResponse.status
        )
      )

      account_hash = "1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1"
      resp = client.get_account(account_hash)
      expect(resp.status).to eq(ResponseFactory::AccountResponse.status)
      expect(resp.body).to eq(ResponseFactory::AccountResponse.body)
    end
  end
  describe "quotes" do
  end

  describe "orders" do
  end

  describe "options chains" do
  end
end
