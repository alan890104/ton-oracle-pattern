import "@stdlib/deploy";
import "./messages.tact";

struct PriceInfo {
    price: Int as coins;
    decimals: Int as coins;
}

contract PriceOracle with Deployable {
    init() {}

    fun getPriceResponse(symbol: String): PriceInfo? {
        if (sha256(symbol) == sha256("ETH")) {
            return PriceInfo{
                price: ton("2000"),
                decimals: ton("1")
            };
        }
        return null;
    }

    receive(msg: GetLatestPrice) {
        let priceInfo: PriceInfo? = self.getPriceResponse(msg.symbol);
        if (priceInfo == null) {
            send(SendParameters{
                to: sender(),
                value: 0,
                mode: SendRemainingValue + SendIgnoreErrors,
                body: PriceResponse {
                    queryId: msg.queryId,
                    price: 0,
                    decimals: 0,
                    success: false,
                    callback: emptyCell()
                }.toCell()
            });
            return;
        } 
        let info: PriceInfo = priceInfo!!;
        send(SendParameters{
            to: sender(),
            value: 0,
            mode: SendRemainingValue,
            body: PriceResponse {
                queryId: msg.queryId,
                price: info.price,
                decimals: info.decimals,
                success: true,
                callback: msg.callback
            }.toCell()
        });
    }
}
