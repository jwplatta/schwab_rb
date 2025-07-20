# Data Objects Analysis for BaseClient

## Analysis Date: July 20, 2025

This document analyzes all API methods in `base_client.rb` to identify:
1. ###   - [x] Use fixture: `spec/fixtures/user_preferences.json`
- [x] **OptionExpirationChain** data object class
  - [x] Create `lib/schwab_rb/data_objects/option_expiration_chain.rb`
  - [x] Create `spec/data_objects/option_expiration_chain_spec.rb`
  - [x] Use fixture: `spec/fixtures/option_expiration_chain.json`

### 📋 Todos
- [ ] **OptionExpirationChain** data object class
  - [ ] Create `lib/schwab_rb/data_objects/option_expiration_chain.rb`
  - [ ] Create `spec/data_objects/option_expiration_chain_spec.rb`
  - [ ] Use fixture: `spec/fixtures/option_expiration_chain.json`

### 📋 Todo
- [ ] **PriceHistory** data object class don't return data objects (only raw JSON)
2. Methods that need data object classes to be created

## Methods NOT Currently Returning Data Objects

### Account-Related Methods
1. **`get_account_numbers`** - Returns raw JSON mapping of account IDs to hashes
   - Status: No `return_data_objects` parameter, always returns raw JSON
   - Needs: `AccountNumbers` data object class

2. **`get_order`** - Returns raw JSON for a specific order
   - Status: No `return_data_objects` parameter, always returns raw JSON
   - Note: Should probably return `Order` data object (which exists)

3. **`cancel_order`** - Returns raw response from order cancellation
   - Status: No `return_data_objects` parameter, always returns raw JSON
   - Note: This is a mutation operation, may not need data object

4. **`get_all_linked_account_orders`** - Returns raw JSON for orders across all accounts
   - Status: No `return_data_objects` parameter, always returns raw JSON
   - Note: Should probably return array of `Order` data objects (which exists)

5. **`place_order`** - Returns raw response from order placement
   - Status: No `return_data_objects` parameter, always returns raw JSON
   - Note: This is a mutation operation, may not need data object

6. **`replace_order`** - Returns raw response from order replacement
   - Status: No `return_data_objects` parameter, always returns raw JSON
   - Note: This is a mutation operation, may not need data object

7. **`get_user_preferences`** - Returns raw JSON for user preferences
   - Status: No `return_data_objects` parameter, always returns raw JSON
   - Needs: `UserPreferences` data object class

### Market Data Methods
8. **`get_option_expiration_chain`** - Returns raw JSON for option expiration chain
   - Status: No `return_data_objects` parameter, always returns raw JSON
   - Needs: `OptionExpirationChain` data object class

9. **`get_price_history`** - Returns raw JSON for price history data
   - Status: No `return_data_objects` parameter, always returns raw JSON
   - Needs: `PriceHistory` data object class

10. **All price history convenience methods** - Return raw JSON (via `get_price_history`)
    - `get_price_history_every_minute`
    - `get_price_history_every_five_minutes`
    - `get_price_history_every_ten_minutes`
    - `get_price_history_every_fifteen_minutes`
    - `get_price_history_every_thirty_minutes`
    - `get_price_history_every_day`
    - `get_price_history_every_week`
    - Status: No `return_data_objects` parameter, always return raw JSON
    - Note: These delegate to `get_price_history`, so fixing that method would fix all

11. **`get_movers`** - Returns raw JSON for market movers
    - Status: No `return_data_objects` parameter, always returns raw JSON
    - Needs: `Movers` data object class

12. **`get_market_hours`** - Returns raw JSON for market hours
    - Status: No `return_data_objects` parameter, always returns raw JSON
    - Needs: `MarketHours` data object class

13. **`get_instruments`** - Returns raw JSON for instrument search results
    - Status: No `return_data_objects` parameter, always returns raw JSON
    - Note: `Instrument` data object exists but method doesn't use it

14. **`get_instrument_by_cusip`** - Returns raw JSON for a specific instrument
    - Status: No `return_data_objects` parameter, always returns raw JSON
    - Note: `Instrument` data object exists but method doesn't use it

## Methods Currently Returning Data Objects ✅

### Account-Related Methods
- `get_account` - Returns `Account` data object ✅
- `get_accounts` - Returns array of `Account` data objects ✅
- `preview_order` - Returns `OrderPreview` data object ✅
- `get_account_orders` - Returns array of `Order` data objects ✅
- `get_transactions` - Returns array of `Transaction` data objects ✅
- `get_transaction` - Returns `Transaction` data object ✅

### Market Data Methods
- `get_quote` - Returns data object via `QuoteFactory.build` ✅
- `get_quotes` - Returns array of data objects via `QuoteFactory.build` ✅
- `get_option_chain` - Returns `OptionChain` data object ✅

## Data Object Classes That Need to Be Created

1. **`AccountNumbers`** - For `get_account_numbers` method
2. **`UserPreferences`** - For `get_user_preferences` method
3. **`OptionExpirationChain`** - For `get_option_expiration_chain` method
4. **`PriceHistory`** - For all price history methods
5. **`Movers`** - For `get_movers` method
6. **`MarketHours`** - For `get_market_hours` method

## Existing Data Object Classes

The following data object classes already exist and are being used:
- `Account` ✅
- `Order` ✅
- `OrderPreview` ✅
- `Transaction` ✅
- `Quote` (via QuoteFactory) ✅
- `OptionChain` ✅
- `Instrument` ✅ (exists but not used by `get_instruments` methods)
- `OrderLeg` ✅
- `Position` ✅
- `Option` ✅

## Recommendations

### High Priority (Methods that should return data objects)
1. Add `return_data_objects` parameter to `get_order` and use existing `Order` class
2. Add `return_data_objects` parameter to `get_all_linked_account_orders` and use existing `Order` class
3. Add `return_data_objects` parameter to `get_instruments` and use existing `Instrument` class
4. Add `return_data_objects` parameter to `get_instrument_by_cusip` and use existing `Instrument` class

### Medium Priority (Need new data object classes)
1. Create `PriceHistory` class and add `return_data_objects` to `get_price_history`
2. Create `Movers` class and add `return_data_objects` to `get_movers`
3. Create `MarketHours` class and add `return_data_objects` to `get_market_hours`
4. Create `AccountNumbers` class and add `return_data_objects` to `get_account_numbers`

### Low Priority
1. Create `UserPreferences` class and add `return_data_objects` to `get_user_preferences`
2. Create `OptionExpirationChain` class and add `return_data_objects` to `get_option_expiration_chain`

### Mutation Operations (May not need data objects)
- `place_order`, `replace_order`, `cancel_order` - These are write operations that typically return success/failure status rather than structured data, so they may not need data objects.

## TODO List - Data Object Implementation

### ✅ Completed
- [x] Collect fixture data from Schwab API
- [x] Analyze fixture data structures
- [x] **AccountNumbers** data object class
  - [x] Create `lib/schwab_rb/data_objects/account_numbers.rb`
  - [x] Create `spec/data_objects/account_numbers_spec.rb`
  - [x] Use fixture: `spec/fixtures/account_numbers.json`
- [x] **UserPreferences** data object class
  - [x] Create `lib/schwab_rb/data_objects/user_preferences.rb`
  - [x] Create `spec/data_objects/user_preferences_spec.rb` 
  - [x] Use fixture: `spec/fixtures/user_preferences.json`

### � In Progress
- [x] **UserPreferences** data object class
  - [x] Create `lib/schwab_rb/data_objects/user_preferences.rb`
  - [x] Create `spec/data_objects/user_preferences_spec.rb` 
  - [x] Use fixture: `spec/fixtures/user_preferences.json`

- [ ] **OptionExpirationChain** data object class
  - [ ] Create `lib/schwab_rb/data_objects/option_expiration_chain.rb`
  - [ ] Create `spec/data_objects/option_expiration_chain_spec.rb`
  - [ ] Use fixture: `spec/fixtures/option_expiration_chain.json`

- [ ] **PriceHistory** data object class
  - [ ] Create `lib/schwab_rb/data_objects/price_history.rb`
  - [ ] Create `spec/data_objects/price_history_spec.rb`
  - [ ] Use fixtures: `spec/fixtures/price_history_*.json`

- [ ] **Movers** data object class  
  - [ ] Create `lib/schwab_rb/data_objects/movers.rb`
  - [ ] Create `spec/data_objects/movers_spec.rb`
  - [ ] Use fixture: `spec/fixtures/movers_basic.json`

- [ ] **MarketHours** data object class
  - [ ] Create `lib/schwab_rb/data_objects/market_hours.rb`
  - [ ] Create `spec/data_objects/market_hours_spec.rb`
  - [ ] Use fixtures: `spec/fixtures/market_hours_*.json`

### 🔄 BaseClient Updates (After Data Objects)
- [ ] Update `get_account_numbers` to support `return_data_objects: true`
- [ ] Update `get_user_preferences` to support `return_data_objects: true`
- [ ] Update `get_option_expiration_chain` to support `return_data_objects: true`
- [ ] Update `get_price_history` to support `return_data_objects: true`
- [ ] Update `get_movers` to support `return_data_objects: true`
- [ ] Update `get_market_hours` to support `return_data_objects: true`

## Summary

- **Total API methods analyzed**: 27
- **Methods currently returning data objects**: 9 (33%)
- **Methods not returning data objects**: 18 (67%)
- **New data object classes needed**: 6
- **Existing classes that could be reused**: 2 (`Order`, `Instrument`)
