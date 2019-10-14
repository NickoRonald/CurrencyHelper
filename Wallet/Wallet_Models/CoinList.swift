import Foundation
import RealmSwift
class CoinList:Object{
    @objc dynamic var id = ""
    @objc dynamic var coinName = ""
    @objc dynamic var coinSymbol = ""
    @objc dynamic var logoUrl = ""
    override class func primaryKey() -> String {
        return "coinSymbol"
    }
}
