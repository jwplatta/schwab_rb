class BaseClient
  # Sets the timeout for the client session.
  #
  # @param timeout [Integer] The timeout value in seconds.
  # @return [void]
  def set_timeout(timeout)
  end

  def token_age
  end

  # Account balances, positions, and orders for a given account hash.
  #
  # @param fields [Array] Balances displayed by default, additional fields can be
  # added here by adding values from Account::Fields.
  def get_account(account_hash, fields: nil)

    fields = convert_enum_iterable(fields, Account::Fields)

    params = {}
    params[:fields] = fields.join(",") if fields

    path = "/trader/v1/accounts/#{account_hash}"
    get(path, params)
  end
end