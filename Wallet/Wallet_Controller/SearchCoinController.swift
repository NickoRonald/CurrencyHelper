import UIKit
import RealmSwift
class SearchCoinController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
    var tableViews = UITableView()
    var isSearching = false
    let cryptoCompareClient = CryptoCompareClient()
    var color = ThemeColor()
    let realm = try! Realm()
    var allCoinObject = [CoinList]()
    weak var delegate:TransactionFrom?
    var filterObject = [CoinList]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        searchBar.becomeFirstResponder()
        let result = try! Realm().objects(CoinList.self).sorted(byKeyPath: "coinName")
        for coin in result {
                allCoinObject.append(coin)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    func getExchangeList(market:String)->Void{
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filterObject.count
        }
        return allCoinObject.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coins", for: indexPath) as! CoinTypeTableViewCell
        if isSearching{
            cell.coinName.text = filterObject[indexPath.row].coinName
            cell.coinNameAbb.text = filterObject[indexPath.row].coinSymbol
            cell.coinImage.coinImageSetter(coinName: filterObject[indexPath.row].coinSymbol, width: 30, height: 30, fontSize: 5)
        } else {
            cell.coinName.text = allCoinObject[indexPath.row].coinName
            cell.coinNameAbb.text = allCoinObject[indexPath.row].coinSymbol
            cell.coinImage.coinImageSetter(coinName: allCoinObject[indexPath.row].coinSymbol, width: 30, height: 30, fontSize: 5)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let table:CoinTypeTableViewCell = searchResult.cellForRow(at: indexPath) as! CoinTypeTableViewCell
        delegate?.setCoinName(name: table.coinName.text!)
        delegate?.setCoinAbbName(abbName: table.coinNameAbb.text!)
        delegate?.setExchangesName(exchangeName: "Global Average")
        delegate?.setTradingPairsName(tradingPairsName: priceType)
        delegate?.setTradingPairsFirstType(firstCoinType: [])
        delegate?.setTradingPairsSecondType(secondCoinType: [])
        delegate?.setLoadPrice()
        var allPairs = [String]()
        allPairs.append(table.coinNameAbb.text!)
        allPairs.append("%"+table.coinNameAbb.text!)
        delegate?.setTradingPairsFirstType(firstCoinType: allPairs)
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == ""{
            searchBar.setShowsCancelButton(false, animated: true)
            isSearching = false
            view.endEditing(true)
            searchResult.reloadData()
        } else{
            searchBar.setShowsCancelButton(true, animated: true)
            isSearching = true
            filterObject.removeAll()
            var simplyNameReault = allCoinObject.filter({(mod) -> Bool in return mod.coinSymbol.lowercased().contains(searchBar.text!.lowercased())})
            let fullNameResult = allCoinObject.filter({(mod) -> Bool in return mod.coinName.lowercased().contains(searchBar.text!.lowercased())})
            simplyNameReault += fullNameResult
            var list = [String]()
            for value in simplyNameReault{
                if !list.contains(value.coinSymbol){
                    list.append(value.coinSymbol)
                    filterObject.append(value)
                }
            }
            searchResult.reloadData()
        }
    }
    lazy var searchBar:UISearchBar={
        var searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.tintColor = ThemeColor().darkBlackColor()
        searchBar.barTintColor = ThemeColor().darkBlackColor()
        searchBar.layer.borderColor = ThemeColor().darkBlackColor().cgColor
        searchBar.layer.borderWidth = 1
        let attributes = [
            NSAttributedStringKey.foregroundColor : ThemeColor().whiteColor(),
            NSAttributedStringKey.font: UIFont.regularFont(13)
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = textValue(name: "searchBar_cancel")
        var searchTextField:UITextField? = searchBar.value(forKey: "searchField") as? UITextField
        if (searchTextField?.responds(to: #selector(getter: UITextField.attributedPlaceholder)))!{
            searchTextField!.attributedPlaceholder = NSAttributedString(string:textValue(name: "search_placeholder"), attributes:[NSAttributedStringKey.font: UIFont.ItalicFont(13), NSAttributedStringKey.foregroundColor: ThemeColor().textGreycolor()])
        }
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let donebutton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(sortdoneclick))
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let cancelbutton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(sortCancel))
        toolbar.setItems([cancelbutton,flexible,donebutton], animated: false)
        toolbar.backgroundColor = ThemeColor().whiteColor()
        searchBar.inputAccessoryView = toolbar
        return searchBar
    }()
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        view.endEditing(true)
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    @objc func sortdoneclick(){
        searchBar.setShowsCancelButton(false, animated: true)
        view.endEditing(true)
    }
    @objc func sortCancel(){
        searchBar.setShowsCancelButton(false, animated: true)
        view.endEditing(true)
    }
    lazy var searchResult:UITableView = {
        tableViews.separatorInset = UIEdgeInsets.zero
        tableViews.separatorColor = ThemeColor().darkGreyColor()
        tableViews.backgroundColor = color.themeColor()
        tableViews.delegate = self
        tableViews.dataSource = self
        tableViews.rowHeight = 60
        tableViews.register(CoinTypeTableViewCell.self, forCellReuseIdentifier: "coins")
        tableViews.translatesAutoresizingMaskIntoConstraints = false
        return tableViews
    }()
    func setupView(){
        view.addSubview(searchBar)
        view.addSubview(searchResult)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":searchBar]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":searchBar]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v1]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":searchBar,"v1":searchResult]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0]-[v1]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":searchBar,"v1":searchResult]))
        let tableVC = UITableViewController.init(style: .plain)
        tableVC.tableView = self.searchResult
        self.addChildViewController(tableVC)
    }
}
