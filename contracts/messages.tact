message PriceResponse {
    queryId: Int as uint256;
    success: Bool;
    decimals: Int as coins;
    price: Int as coins;
    callback: Cell;
}

// Get Latest Price in USD
message GetLatestPrice {
    queryId: Int as uint256;
    symbol: String; // e.g. "ETH"
    callback: Cell; // Callbacks to call after the price is fetched
}