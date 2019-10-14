import Foundation
protocol TransactionFrom:class{
    func setCoinName(name:String)
    func setCoinAbbName(abbName:String)
    func setExchangesName(exchangeName:String)
    func setTradingPairsName(tradingPairsName:String)
    func setTradingPairsFirstType(firstCoinType:[String])
    func setTradingPairsSecondType(secondCoinType:[String])
    func getExchangeName()->String
    func getCoinName()->String
    func setLoadPrice()
}
