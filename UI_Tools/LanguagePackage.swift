import Foundation
import UIKit
var defaultLanguage:String {
    get{
        var language:String = ""
        if let defaultCurrency = UserDefaults.standard.value(forKey: "defaultLanguage") as? String{
            language = defaultCurrency
            return language
        } else {
            return language
        }
    }
}
func textValue(name:String)->String{
    var bundals = Bundle()
    if defaultLanguage == "EN"{
        let path = Bundle.main.path(forResource: "en", ofType: "lproj")
        bundals = Bundle.init(path: path!)!
    }
    return bundals.localizedString(forKey:name,value:nil,table:nil)
}
