module MyModule::TokenPriceDashboard {
    use aptos_framework::signer;
    use std::string::String;
    use aptos_framework::timestamp;
    
    /// Struct representing a token's price information
    struct TokenPrice has store, key {
        price: u64,           // Token price in smallest unit (e.g., cents)
        last_updated: u64,    // Timestamp of last price update
        token_symbol: String, // Token symbol (e.g., "BTC", "ETH")
    }
    
    /// Error codes
    const E_TOKEN_PRICE_NOT_EXISTS: u64 = 1;
    const E_NOT_AUTHORIZED: u64 = 2;
    
    /// Function to set/update token price (only callable by price oracle/admin)
    public fun set_token_price(
        oracle: &signer, 
        token_symbol: String, 
        price: u64
    ) acquires TokenPrice {
        let oracle_address = signer::address_of(oracle);
        
        if (exists<TokenPrice>(oracle_address)) {
            // Update existing token price
            let token_price = borrow_global_mut<TokenPrice>(oracle_address);
            token_price.price = price;
            token_price.last_updated = timestamp::now_seconds();
            token_price.token_symbol = token_symbol;
        } else {
            // Create new token price entry
            let token_price = TokenPrice {
                price,
                last_updated: timestamp::now_seconds(),
                token_symbol,
            };
            move_to(oracle, token_price);
        }
    }
    
    /// Function to get current token price and metadata
    public fun get_token_price(oracle_address: address): (u64, u64, String) acquires TokenPrice {
        assert!(exists<TokenPrice>(oracle_address), E_TOKEN_PRICE_NOT_EXISTS);
        let token_price = borrow_global<TokenPrice>(oracle_address);
        (token_price.price, token_price.last_updated, token_price.token_symbol)
    }
}