import Foundation
class CryptoCompareClient: APIClient{
    var session: URLSession
    var defaultCurrency: String
    typealias ExchangeListResult = [String:[String:[String]]]
    typealias Price = [String: Double]
    init(configuration: URLSessionConfiguration, currency: String? = priceType){
        self.session = URLSession(configuration: configuration)
        self.defaultCurrency = currency!
    }
    convenience init(){
        self.init(configuration: .default)
    }
    func getCoinList(completion: @escaping (Result<CryptoCompareCoinListResult?, APIError>) -> Void){
        let endpoint = CryptoCompareEndpoint(type: CryptoComparePath.coinlist)
        let request = endpoint.request
        fetch(with: request, decode:{ json -> CryptoCompareCoinListResult? in
            guard let coinListResult = json as? CryptoCompareCoinListResult else {return nil}
            return coinListResult
        }, completion: completion)
    }
    func getExchangesResult(completion: @escaping (Result<ExchangeListResult?, APIError>) -> Void){
        let endpoint = CryptoCompareEndpoint(type: CryptoComparePath.exchanges)
        let request = endpoint.request
        fetch(with: request, decode:{ json -> ExchangeListResult? in
            guard let exchangeList = json as? ExchangeListResult else {return nil}
            return exchangeList
        }, completion: completion)
    }
    func getTradePrice(from: String, to: String?=nil, exchange: String?=nil, completion: @escaping (Result<Price?, APIError>) -> Void) {
        let fsym = "fsym=" + from
        let toSymbel = to ?? self.defaultCurrency
        let tsym = "tsyms=" + toSymbel
        var queryStr = [fsym, tsym].joined(separator: "&")
        if (exchange != nil){
            queryStr = [queryStr, "e=" + exchange!].joined(separator: "&")
        }
        let endpoint = CryptoCompareEndpoint(type: CryptoComparePath.price)
        endpoint.query = queryStr
        let request = endpoint.request
        fetch(with: request, decode: { json -> Price? in
            guard let price = json as? Price else {return nil}
            return price
        }, completion: completion)
    }
    func getTradePrices(from: String, to: String?=nil, exchange: String?=nil, completion: @escaping (Result<Price?, APIError>) -> Void) {
        let fsym = "fsym=" + from
        let toSymbel = to ?? self.defaultCurrency
        let tsym = "tsyms=" + toSymbel
        var queryStr = [fsym, tsym].joined(separator: "&")
        if (exchange != nil){
            queryStr = [queryStr, "e=" + exchange!].joined(separator: "&")
        }
        let endpoint = CryptoCompareEndpoint(type: CryptoComparePath.price)
        endpoint.query = queryStr
        let request = endpoint.request
        fetch(with: request, decode: { json -> Price? in
            guard let price = json as? Price else {return nil}
            return price
        }, completion: completion)
    }
}
