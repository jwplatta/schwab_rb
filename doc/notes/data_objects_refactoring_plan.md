# Data Objects Refactoring Plan

## Overview
Moving all data object classes from `options_trader` gem to `schwab_rb` gem, along with their specs, and updating the architecture to support both raw JSON and data object returns.

## Phase 1: Analysis ✅

### Data Objects to Move (from options_trader to schwab_rb):
- `lib/options_trader/schwab/data_objects/account.rb` → `lib/schwab_rb/data_objects/account.rb`
- `lib/options_trader/schwab/data_objects/instrument.rb` → `lib/schwab_rb/data_objects/instrument.rb`
- `lib/options_trader/schwab/data_objects/option.rb` → `lib/schwab_rb/data_objects/option.rb`
- `lib/options_trader/schwab/data_objects/option_chain.rb` → `lib/schwab_rb/data_objects/option_chain.rb`
- `lib/options_trader/schwab/data_objects/order.rb` → `lib/schwab_rb/data_objects/order.rb`
- `lib/options_trader/schwab/data_objects/order_leg.rb` → `lib/schwab_rb/data_objects/order_leg.rb`
- `lib/options_trader/schwab/data_objects/order_preview.rb` → `lib/schwab_rb/data_objects/order_preview.rb`
- `lib/options_trader/schwab/data_objects/position.rb` → `lib/schwab_rb/data_objects/position.rb`
- `lib/options_trader/schwab/data_objects/quote.rb` → `lib/schwab_rb/data_objects/quote.rb`
- `lib/options_trader/schwab/data_objects/transaction.rb` → `lib/schwab_rb/data_objects/transaction.rb`

### Specs to Move:
- All files from `options_trader/spec/schwab/data_objects/` → `schwab_rb/spec/data_objects/`

### Namespace Changes:
- `OptionsTrader::Schwab::DataObjects` → `SchwabRb::DataObjects`

## Phase 2: Move Data Objects ✅ COMPLETED
- [x] Move each data object class
- [x] Update namespaces from OptionsTrader::Schwab::DataObjects to SchwabRb::DataObjects
- [x] Update internal requires and dependencies

## Phase 3: Move and Update Specs ✅ COMPLETED
- [x] Move spec files
- [x] Update spec namespaces and requires
- [x] Copy fixture files from options_trader to schwab_rb
- [x] Ensure all tests pass

## Phase 4: Update Base Client ✅ COMPLETED
- [x] Add `return_data_objects: true` parameter to get_account method
- [x] Add `return_data_objects: true` parameter to get_accounts method  
- [x] Add data object imports to base client
- [x] Maintain backward compatibility with raw JSON responses
- [x] Update method signatures and documentation

## Phase 5: Update Options Trader Schwab Mixin ✅ COMPLETED
- [x] Remove data object instantiation from schwab.rb mixin
- [x] Update account() method to use return_data_objects parameter
- [x] Simplify other methods to remove DataObjects references
- [x] Clean up require statements
- [x] Ensure mixin works with new architecture

## Phase 6: Testing and Cleanup (IN PROGRESS)
- [x] Run schwab_rb tests - all data object tests passing
- [x] Verify options_trader integration works
- [ ] Add return_data_objects parameter to remaining base client methods
- [ ] Update documentation
- [ ] Clean up any remaining references

## Notes
- Started: 2025-07-19
- Phase 5 completed: 2025-07-19
- Current phase: Phase 6 - Testing and Cleanup
- All 37 data object tests passing in schwab_rb
- 14 commits created with systematic refactoring approach
