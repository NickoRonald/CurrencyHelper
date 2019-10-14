import Foundation
struct  CryptoCompareCoinListResult: Decodable {
    let Data: [String:CryptoCompareCoin]
    init?(json: Data?) 
    {
        if let data = json, let newValue = try? JSONDecoder().decode(CryptoCompareCoinListResult.self, from: data) {
            self = newValue
        } else {
            return nil
        }
    }
    init(data: [String:CryptoCompareCoin]) {
        self.Data = data
    }
}
