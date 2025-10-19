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
      app_secret,
      session,
      token_manager: token_manager,
      enforce_enums: true
    )
  end

  it "does not raise" do
    expect { described_class.new(nil, nil, nil, token_manager: nil, enforce_enums: true) }.not_to raise_error
  end

  describe "#get_account" do
    it "returns a specific account" do
      allow(session).to receive(:get).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.account_response.body,
          status: ResponseFactory.account_response.status
        )
      )
      account_hash = "1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1"
      resp = client.get_account(account_hash, return_data_objects: false)
      expect(resp.status).to eq(ResponseFactory.account_response.status)
      expect(resp.body).to eq(ResponseFactory.account_response.body)
    end

    it "accepts account_name parameter" do
      allow(session).to receive(:get).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.account_response.body,
          status: ResponseFactory.account_response.status
        )
      )

      hash_manager = instance_double(SchwabRb::AccountHashManager)
      allow(SchwabRb::AccountHashManager).to receive(:new).and_return(hash_manager)
      allow(hash_manager).to receive(:get_hash_by_name).with("my_trading")
        .and_return("1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1")

      resp = client.get_account(account_name: "my_trading", return_data_objects: false)
      expect(resp.status).to eq(ResponseFactory.account_response.status)
      expect(resp.body).to eq(ResponseFactory.account_response.body)
    end

    it "raises error when account_name not found" do
      hash_manager = instance_double(SchwabRb::AccountHashManager)
      allow(SchwabRb::AccountHashManager).to receive(:new).and_return(hash_manager)
      allow(hash_manager).to receive(:get_hash_by_name).with("nonexistent")
        .and_return(nil)

      expect do
        client.get_account(account_name: "nonexistent")
      end.to raise_error(ArgumentError, /Account name 'nonexistent' not found/)
    end
  end

  describe "#get_accounts" do
    it "returns an array of accounts" do
      allow(session).to receive(:get).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.accounts_response.body,
          status: ResponseFactory.accounts_response.status
        )
      )
      resp = client.get_accounts(return_data_objects: false)
      expect(resp.status).to eq(ResponseFactory.accounts_response.status)
      expect(resp.body).to eq(ResponseFactory.accounts_response.body)
    end
  end

  describe "#get_account_numbers" do
    it "returns account numbers" do
      allow(session).to receive(:get).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.account_numbers_response.body,
          status: ResponseFactory.account_numbers_response.status
        )
      )
      resp = client.get_account_numbers(return_data_objects: false)
      expect(resp.status).to eq(ResponseFactory.account_numbers_response.status)
      expect(resp.body).to eq(ResponseFactory.account_numbers_response.body)
    end
  end

  describe "#get_order" do
    it "returns a specific order" do
      allow(session).to receive(:get).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.order_response.body,
          status: ResponseFactory.order_response.status
        )
      )
      resp = client.get_order("12345", "1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1", return_data_objects: false)
      expect(resp.status).to eq(ResponseFactory.order_response.status)
      expect(resp.body).to eq(ResponseFactory.order_response.body)
    end

    it "accepts account_name parameter" do
      allow(session).to receive(:get).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.order_response.body,
          status: ResponseFactory.order_response.status
        )
      )

      hash_manager = instance_double(SchwabRb::AccountHashManager)
      allow(SchwabRb::AccountHashManager).to receive(:new).and_return(hash_manager)
      allow(hash_manager).to receive(:get_hash_by_name).with("my_trading")
        .and_return("1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1")

      resp = client.get_order("12345", account_name: "my_trading", return_data_objects: false)
      expect(resp.status).to eq(ResponseFactory.order_response.status)
      expect(resp.body).to eq(ResponseFactory.order_response.body)
    end
  end

  describe "#cancel_order" do
    it "cancels a specific order" do
      allow(session).to receive(:delete).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.cancel_order_response.body,
          status: ResponseFactory.cancel_order_response.status
        )
      )
      order_id = "12345"
      account_hash = "1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1"
      resp = client.cancel_order(order_id, account_hash)
      expect(resp.status).to eq(ResponseFactory.cancel_order_response.status)
      expect(resp.body).to eq(ResponseFactory.cancel_order_response.body)
    end

    it "accepts account_name parameter" do
      allow(session).to receive(:delete).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.cancel_order_response.body,
          status: ResponseFactory.cancel_order_response.status
        )
      )

      hash_manager = instance_double(SchwabRb::AccountHashManager)
      allow(SchwabRb::AccountHashManager).to receive(:new).and_return(hash_manager)
      allow(hash_manager).to receive(:get_hash_by_name).with("my_trading")
        .and_return("1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1")

      resp = client.cancel_order("12345", account_name: "my_trading")
      expect(resp.status).to eq(ResponseFactory.cancel_order_response.status)
      expect(resp.body).to eq(ResponseFactory.cancel_order_response.body)
    end
  end

  describe "#get_account_orders" do
    it "returns orders for a specific account" do
      allow(session).to receive(:get).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.account_orders_response.body,
          status: ResponseFactory.account_orders_response.status
        )
      )
      account_hash = "1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1"
      resp = client.get_account_orders(account_hash, return_data_objects: false)
      expect(resp.status).to eq(ResponseFactory.account_orders_response.status)
      expect(resp.body).to eq(ResponseFactory.account_orders_response.body)
    end

    it "accepts account_name parameter" do
      allow(session).to receive(:get).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.account_orders_response.body,
          status: ResponseFactory.account_orders_response.status
        )
      )

      hash_manager = instance_double(SchwabRb::AccountHashManager)
      allow(SchwabRb::AccountHashManager).to receive(:new).and_return(hash_manager)
      allow(hash_manager).to receive(:get_hash_by_name).with("my_trading")
        .and_return("1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1")

      resp = client.get_account_orders(account_name: "my_trading", return_data_objects: false)
      expect(resp.status).to eq(ResponseFactory.account_orders_response.status)
      expect(resp.body).to eq(ResponseFactory.account_orders_response.body)
    end
  end

  describe "#get_all_linked_account_orders" do
    it "returns orders for all linked accounts" do
      allow(session).to receive(:get).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.all_linked_account_orders_response.body,
          status: ResponseFactory.all_linked_account_orders_response.status
        )
      )
      resp = client.get_all_linked_account_orders(return_data_objects: false)
      expect(resp.status).to eq(ResponseFactory.all_linked_account_orders_response.status)
      expect(resp.body).to eq(ResponseFactory.all_linked_account_orders_response.body)
    end
  end

  describe "#place_order" do
    it "places an order for a specific account" do
      allow(session).to receive(:post).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.place_order_response.body,
          status: ResponseFactory.place_order_response.status
        )
      )
      account_hash = "1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1"
      order_spec = double("OrderSpec", build: {})
      resp = client.place_order(account_hash, order_spec)
      expect(resp.status).to eq(ResponseFactory.place_order_response.status)
      expect(resp.body).to eq(ResponseFactory.place_order_response.body)
    end

    it "accepts account_name parameter" do
      allow(session).to receive(:post).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.place_order_response.body,
          status: ResponseFactory.place_order_response.status
        )
      )

      hash_manager = instance_double(SchwabRb::AccountHashManager)
      allow(SchwabRb::AccountHashManager).to receive(:new).and_return(hash_manager)
      allow(hash_manager).to receive(:get_hash_by_name).with("my_trading")
        .and_return("1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1")

      order_spec = double("OrderSpec", build: {})
      resp = client.place_order(order_spec, account_name: "my_trading")
      expect(resp.status).to eq(ResponseFactory.place_order_response.status)
      expect(resp.body).to eq(ResponseFactory.place_order_response.body)
    end
  end

  describe "#replace_order" do
    it "replaces an existing order for an account" do
      allow(session).to receive(:put).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.replace_order_response.body,
          status: ResponseFactory.replace_order_response.status
        )
      )
      account_hash = "1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1"
      order_id = "12345"
      order_spec = double("OrderSpec", build: {})
      resp = client.replace_order(account_hash, order_id, order_spec)
      expect(resp.status).to eq(ResponseFactory.replace_order_response.status)
      expect(resp.body).to eq(ResponseFactory.replace_order_response.body)
    end

    it "accepts account_name parameter" do
      allow(session).to receive(:put).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.replace_order_response.body,
          status: ResponseFactory.replace_order_response.status
        )
      )

      hash_manager = instance_double(SchwabRb::AccountHashManager)
      allow(SchwabRb::AccountHashManager).to receive(:new).and_return(hash_manager)
      allow(hash_manager).to receive(:get_hash_by_name).with("my_trading")
        .and_return("1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1")

      order_spec = double("OrderSpec", build: {})
      resp = client.replace_order("12345", order_spec, account_name: "my_trading")
      expect(resp.status).to eq(ResponseFactory.replace_order_response.status)
      expect(resp.body).to eq(ResponseFactory.replace_order_response.body)
    end
  end

  describe "#preview_order" do
    it "previews an order" do
      allow(session).to receive(:post).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.preview_order_response.body,
          status: ResponseFactory.preview_order_response.status
        )
      )
      account_hash = "1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1"
      order_spec = double("OrderSpec", build: {})
      resp = client.preview_order(account_hash, order_spec, return_data_objects: false)
      expect(resp.status).to eq(ResponseFactory.preview_order_response.status)
      expect(resp.body).to eq(ResponseFactory.preview_order_response.body)
    end

    it "accepts account_name parameter" do
      allow(session).to receive(:post).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.preview_order_response.body,
          status: ResponseFactory.preview_order_response.status
        )
      )

      hash_manager = instance_double(SchwabRb::AccountHashManager)
      allow(SchwabRb::AccountHashManager).to receive(:new).and_return(hash_manager)
      allow(hash_manager).to receive(:get_hash_by_name).with("my_trading")
        .and_return("1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1")

      order_spec = double("OrderSpec", build: {})
      resp = client.preview_order(order_spec, account_name: "my_trading", return_data_objects: false)
      expect(resp.status).to eq(ResponseFactory.preview_order_response.status)
      expect(resp.body).to eq(ResponseFactory.preview_order_response.body)
    end
  end
  describe "#get_transactions" do
    it "returns transactions for a specific account" do
      allow(session).to receive(:get).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.transactions_response.body,
          status: ResponseFactory.transactions_response.status
        )
      )
      allow(URI).to receive(:encode_www_form).and_call_original

      account_hash = "1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1"
      start_date = DateTime.new(2024, 11, 19, 2, 35, 31.075)
      end_date = DateTime.new(2025, 1, 18, 2, 35, 31.075)
      expected_params = {
        "types" => "ACH_DISBURSEMENT,ACH_RECEIPT,CASH_DISBURSEMENT,CASH_RECEIPT,DIVIDEND_OR_INTEREST,ELECTRONIC_FUND,JOURNAL,MARGIN_CALL,MEMORANDUM,MONEY_MARKET,RECEIVE_AND_DELIVER,SMA_ADJUSTMENT,TRADE,WIRE_IN,WIRE_OUT",
        "startDate" => "2024-11-19T02:35:31.075Z",
        "endDate" => "2025-01-18T02:35:31.075Z"
      }
      resp = client.get_transactions(account_hash, start_date: start_date, end_date: end_date, return_data_objects: false)

      expect(URI).to have_received(:encode_www_form).with(expected_params)
      expect(resp.status).to eq(ResponseFactory.transactions_response.status)
      expect(resp.body).to eq(ResponseFactory.transactions_response.body)
    end

    it "accepts account_name parameter" do
      allow(session).to receive(:get).and_return(
        instance_double(
          OAuth2::Response,
          body: ResponseFactory.transactions_response.body,
          status: ResponseFactory.transactions_response.status
        )
      )
      allow(URI).to receive(:encode_www_form).and_call_original

      hash_manager = instance_double(SchwabRb::AccountHashManager)
      allow(SchwabRb::AccountHashManager).to receive(:new).and_return(hash_manager)
      allow(hash_manager).to receive(:get_hash_by_name).with("my_trading")
        .and_return("1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1")

      start_date = DateTime.new(2024, 11, 19, 2, 35, 31.075)
      end_date = DateTime.new(2025, 1, 18, 2, 35, 31.075)
      resp = client.get_transactions(account_name: "my_trading", start_date: start_date, end_date: end_date, return_data_objects: false)

      expect(resp.status).to eq(ResponseFactory.transactions_response.status)
      expect(resp.body).to eq(ResponseFactory.transactions_response.body)
    end
  end
  describe "#get_transaction" do
    let(:transaction_resp) { ResponseFactory.transaction_response }
    it "returns a specific transaction" do
      allow(session).to receive(:get).and_return(
        instance_double(
          OAuth2::Response,
          body: transaction_resp.body,
          status: transaction_resp.status
        )
      )

      account_hash = "1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1"
      order_id = "12345"
      resp = client.get_transaction(account_hash, order_id, return_data_objects: false)

      expect(resp.status).to eq(transaction_resp.status)
      expect(resp.body).to eq(transaction_resp.body)
    end

    it "accepts account_name parameter" do
      allow(session).to receive(:get).and_return(
        instance_double(
          OAuth2::Response,
          body: transaction_resp.body,
          status: transaction_resp.status
        )
      )

      hash_manager = instance_double(SchwabRb::AccountHashManager)
      allow(SchwabRb::AccountHashManager).to receive(:new).and_return(hash_manager)
      allow(hash_manager).to receive(:get_hash_by_name).with("my_trading")
        .and_return("1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1")

      resp = client.get_transaction(nil, "12345", account_name: "my_trading", return_data_objects: false)

      expect(resp.status).to eq(transaction_resp.status)
      expect(resp.body).to eq(transaction_resp.body)
    end
  end

  describe "#get_movers" do
    let(:movers_response_body) do
      File.read("spec/fixtures/movers_volume.json")
    end

    it "returns MarketMovers object by default" do
      allow(session).to receive(:get).and_return(
        instance_double(
          OAuth2::Response,
          body: movers_response_body,
          status: 200
        )
      )

      result = client.get_movers("$SPX")
      expect(result).to be_a(SchwabRb::DataObjects::MarketMovers)
      expect(result.count).to eq(10)
      expect(result.movers.first.symbol).to eq("NVDA")
    end

    it "returns raw response when return_data_objects is false" do
      mock_response = instance_double(OAuth2::Response, body: movers_response_body, status: 200)

      allow(session).to receive(:get).and_return(mock_response)

      result = client.get_movers("$SPX", return_data_objects: false)
      expect(result).to eq(mock_response)
    end

    it "passes sort_order and frequency parameters correctly" do
      allow(session).to receive(:get).and_return(
        instance_double(OAuth2::Response, body: movers_response_body, status: 200)
      )

      client.get_movers("$SPX", sort_order: "VOLUME", frequency: 1)

      expect(session).to have_received(:get).once
    end
  end

  describe "user preferences" do
  end
  describe "quotes" do
  end
  describe "options" do
    xit do
      api_key = ENV.fetch("SCHWAB_API_KEY", nil)
      app_secret = ENV.fetch("SCHWAB_APP_SECRET", nil)
      token_path = ENV.fetch("TOKEN_PATH", nil)
      client = SchwabRb::Auth.init_client_token_file(api_key, app_secret, token_path)
      # resp = client.get_option_chain('SPY', exp_month: SchwabRb::Option::ExpirationMonths::JANUARY)
      client.get_option_chain("/ESH25", strike_count: 1)
    end
  end

  describe "price history" do
  end

  describe "movers" do
  end

  describe "market hours" do
  end

  describe "instruments" do
  end

  describe "#refresh!" do
    it "refreshes the token if needed" do
      allow(session).to receive(:expired?).and_return(true)
      allow(token_manager).to receive(:refresh_token).and_return(session)
      client.refresh!
      expect(session).to have_received(:expired?)
      expect(token_manager).to have_received(:refresh_token)
    end
  end

  describe "#set_timeout" do
    it "sets the timeout for the client session" do
      client.set_timeout(30)
      expect(client.timeout).to eq(30)
    end
  end

  describe "#token_age" do
    it "returns the token age" do
      expect(client.token_age).to eq(token_manager.token_age)
    end
  end
end
