# Place Order Samples

Below, you will find examples specific to orders for use in the Schwab Trader API POST and PUT Order endpoints. Order entry will only be available for the assetType 'EQUIT' and 'OPTION as of this time.

Trader API applications (Individual and Commercial) are limited in the number of PUT/POST/DELETE order requests per minute per account based on the properties of the application specified during registration or follow-up process. Throttle limits for orders can be set from zero (0) to 120 requests per minute per account. Get order requests are unthrottled. Contact TraderAPI@schwab.com for further information.

Options and their Symbology:
Options symbols are broken down as:
Underlying Symbol (6 characters including spaces) | Expiration (6 characters) | Call/Put (1 character) | Strike Price (5+3=8 characters)

```
Option Symbol: XYZ 210115C00050000
Stock Symbol: XYZ
Expiration: 2021/01/15
Type: Call
Strike Price: $50.00

Option Symbol: XYZ 210115C00055000
Stock Symbol: XYZ
Expiration: 2021/01/15
Type: Call
Strike Price: $55.00

Option Symbol: XYZ 210115C00062500
Stock Symbol: XYZ
Expiration: 2021/01/15
Type: Call
Strike Price: $62.50
```

Instruction for EQUITY and OPTION

Instruction	EQUITY (Stocks and ETFs)	Option
BUY	ACCEPTED	REJECT
SELL	ACCEPTED	REJECT
BUY_TO_OPEN	REJECT	ACCEPTED
BUY_TO_COVER	ACCEPTED	REJECT
BUY_TO_CLOSE	REJECT	ACCEPTED
SELL_TO_OPEN	REJECT	ACCEPTED
SELL_SHORT	ACCEPTED	REJECT
SELL_TO_CLOSE	REJECT	ACCEPTED
Buy Market: Stock
Buy 15 shares of XYZ at the Market good for the Day.

```json
{
  "orderType": "MARKET",
  "session": "NORMAL",
  "duration": "DAY",
  "orderStrategyType": "SINGLE",
  "orderLegCollection": [
   {
    "instruction": "BUY",
    "quantity": 15,
    "instrument": {
     "symbol": "XYZ",
     "assetType": "EQUITY"
    }
   }
  ]
}
```

## Buy Limit: Single Option

Buy to open 10 contracts of the XYZ March 15, 2024 $50 CALL at a Limit of $6.45 good for the Day.

```json
{
  "complexOrderStrategyType": "NONE",
  "orderType": "LIMIT",
  "session": "NORMAL",
  "price": "6.45",
  "duration": "DAY",
  "orderStrategyType": "SINGLE",
  "orderLegCollection": [
   {
    "instruction": "BUY_TO_OPEN",
    "quantity": 10,
    "instrument": {
     "symbol": "XYZ   240315C00500000",
     "assetType": "OPTION"
    }
   }
  ]
}
```

## Buy Limit: Vertical Call Spread
Buy to open 2 contracts of the XYZ March 15, 2024 $45 Put and Sell to open 2 contract of the XYZ March 15, 2024 $43 Put at a LIMIT price of $0.10 good for the Day.

```json
{
  "orderType": "NET_DEBIT",
  "session": "NORMAL",
  "price": "0.10",
  "duration": "DAY",
  "orderStrategyType": "SINGLE",
  "orderLegCollection": [
   {
    "instruction": "BUY_TO_OPEN",
    "quantity": 2,
    "instrument": {
     "symbol": "XYZ   240315P00045000",
     "assetType": "OPTION"
    }
   },
   {
    "instruction": "SELL_TO_OPEN",
    "quantity": 2,
    "instrument": {
     "symbol": "XYZ   240315P00043000",
      "assetType": "OPTION"
    }
   }
  ]
}
```

## Conditional Order: One Triggers Another
Buy 10 shares of XYZ at a Limit price of $34.97 good for the Day. If filled, immediately submit an order to Sell 10 shares of XYZ with a Limit price of $42.03 good for the Day. Also known as 1st Trigger Sequence.

```json
{
  "orderType": "LIMIT",
  "session": "NORMAL",
  "price": "34.97",
  "duration": "DAY",
  "orderStrategyType": "TRIGGER",
  "orderLegCollection": [
   {
    "instruction": "BUY",
    "quantity": 10,
    "instrument": {
     "symbol": "XYZ",
     "assetType": "EQUITY"
    }
   }
  ],
  "childOrderStrategies": [
   {
    "orderType": "LIMIT",
    "session": "NORMAL",
    "price": "42.03",
    "duration": "DAY",
    "orderStrategyType": "SINGLE",
    "orderLegCollection": [
     {
      "instruction": "SELL",
      "quantity": 10,
      "instrument": {
       "symbol": "XYZ",
       "assetType": "EQUITY"
      }
     }
    ]
   }
  ]
}
```


## Conditional Order: One Cancels Another

Sell 2 shares of XYZ at a Limit price of $45.97 and Sell 2 shares of XYZ with a Stop Limit order where the stop price is $37.03 and limit is $37.00. Both orders are sent at the same time. If one order fills, the other order is immediately cancelled. Both orders are good for the Day. Also known as an OCO order.

```json
{
  "orderStrategyType": "OCO",
  "childOrderStrategies": [
   {
    "orderType": "LIMIT",
    "session": "NORMAL",
    "price": "45.97",
    "duration": "DAY",
    "orderStrategyType": "SINGLE",
    "orderLegCollection": [
     {
      "instruction": "SELL",
      "quantity": 2,
      "instrument": {
       "symbol": "XYZ",
       "assetType": "EQUITY"
      }
     }
    ]
   },
   {
    "orderType": "STOP_LIMIT",
    "session": "NORMAL",
    "price": "37.00",
    "stopPrice": "37.03",
    "duration": "DAY",
    "orderStrategyType": "SINGLE",
    "orderLegCollection": [
     {
      "instruction": "SELL",
      "quantity": 2,
      "instrument": {
       "symbol": "XYZ",
       "assetType": "EQUITY"
      }
     }
    ]
   }
  ]
}
```


## Conditional Order: One Triggers A One Cancels Another

Buy 5 shares of XYZ at a Limit price of $14.97 good for the Day. Once filled, 2 sell orders are immediately sent: Sell 5 shares of XYZ at a Limit price of $15.27 and Sell 5 shares of XYZ with a Stop order where the stop price is $11.27. If one of the sell orders fill, the other order is immediately cancelled. Both Sell orders are Good till Cancel. Also known as a 1st Trigger OCO order.

```json
{
  "orderStrategyType": "TRIGGER",
  "session": "NORMAL",
  "duration": "DAY",
  "orderType": "LIMIT",
  "price": 14.97,
  "orderLegCollection": [
   {
    "instruction": "BUY",
    "quantity": 5,
    "instrument": {
     "assetType": "EQUITY",
     "symbol": "XYZ"
    }
   }
  ],
  "childOrderStrategies": [
   {
    "orderStrategyType": "OCO",
    "childOrderStrategies": [
     {
      "orderStrategyType": "SINGLE",
      "session": "NORMAL",
      "duration": "GOOD_TILL_CANCEL",
      "orderType": "LIMIT",
      "price": 15.27,
      "orderLegCollection": [
       {
        "instruction": "SELL",
        "quantity": 5,
        "instrument": {
         "assetType": "EQUITY",
         "symbol": "XYZ"
        }
       }
      ]
     },
     {
      "orderStrategyType": "SINGLE",
      "session": "NORMAL",
      "duration": "GOOD_TILL_CANCEL",
      "orderType": "STOP",
      "stopPrice": 11.27,
      "orderLegCollection": [
       {
        "instruction": "SELL",
        "quantity": 5,
        "instrument": {
         "assetType": "EQUITY",
         "symbol": "XYZ"
        }
       }
      ]
     }
    ]
   }
  ]
}
```

## Sell Trailing Stop: Stock

Sell 10 shares of XYZ with a Trailing Stop where the trail is a -$10 offset from the time the order is submitted. As the stock price goes up, the -$10 trailing offset will follow. If stock XYZ goes from $110 to $130, your trail will automatically be adjusted to $120. If XYZ falls to $120 or below, a Market order is submitted. This order is good for the Day.

```json
{
  "complexOrderStrategyType": "NONE",
  "orderType": "TRAILING_STOP",
  "session": "NORMAL",
  "stopPriceLinkBasis": "BID",
  "stopPriceLinkType": "VALUE",
  "stopPriceOffset": 10,
  "duration": "DAY",
  "orderStrategyType": "SINGLE",
  "orderLegCollection": [
   {
    "instruction": "SELL",
    "quantity": 10,
    "instrument": {
     "symbol": "XYZ",
     "assetType": "EQUITY"
    }
   }
  ]
}
```