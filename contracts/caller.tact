import "@stdlib/deploy";
import "./messages.tact";

contract Caller with Deployable {
    oracle: Address;
    number: Int = 0;

    init(_oracle: Address){
        self.oracle = _oracle;
    }

    get fun Number(): Int {
        return self.number;
    }

    inline fun multiplyPrice(price: Int, multiplier: Int, decimals: Int): Int {
        return price * multiplier / decimals;
    }

    // Receive arbitrary message
    receive(msg: Slice){}

    // Receive callback from oracle
    receive(msg: PriceResponse){
        require(sender() == self.oracle, "Only oracle can call this method");
        require(msg.success == true, "Oracle failed to get the price");
        let s: Slice = msg.callback.beginParse();
        let op: Int = s.loadUint(8);
        if (op == 1) {
            // BUG: The below line will cause a compilation error
            // let multiplier: Int = s.loadRef().beginParse().loadUint(256);

            let paramSlice: Slice = s.loadRef().beginParse();
            let multiplier: Int = paramSlice.loadUint(256);
            self.number = self.multiplyPrice(msg.price, multiplier, msg.decimals);
        }
    }

    // Call oracle to get the price
    receive("call"){
        // Expected to multiply the price by 2
        send(SendParameters{
                to: self.oracle,
                value: 0,
                mode: SendRemainingValue,
                body: GetLatestPrice{
                    queryId: 1,
                    symbol: "ETH",
                    callback: beginCell().storeUint(1, 8).storeRef(beginCell().storeUint(2, 256).endCell()).endCell()
                }.toCell()
            }
        );
    }
}