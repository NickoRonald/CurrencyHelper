import UIKit
import RealmSwift
import SwiftKeychainWrapper
class WalletController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    var image = AppImage()
    let cryptoCompareClient = CryptoCompareClient()
    var coinDetail = SelectCoin()
    var totalProfit:Double = 0
    var totalAssets:Double = 0
    var changeLaugageStatus:Bool = false
    var changeCurrencyStatus:Bool = false
    var countField:String = ""
    let realizedHint = HintAlertController()
    let unrealizedHint = HintAlertController()
    var assetss: Results<Transactions>{
        get{
            return try! Realm().objects(Transactions.self).sorted(byKeyPath: "publishDate")
        }
    }
    var loginStatus:Bool{
        get{
            return UserDefaults.standard.bool(forKey: "isLoggedIn")
        }
    }
    var email:String{
        get{
            return KeychainWrapper.standard.string(forKey: "Email") ?? "null"
        }
    }
    var certificateToken:String{
        get{
            return UserDefaults.standard.string(forKey: "CertificateToken") ?? "null"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBasicView()
        checkTransaction()
        DispatchQueue.main.async(execute: {
            self.walletList.switchRefreshHeader(to: .refreshing)
        })
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: "reloadWallet"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeCurrency), name: NSNotification.Name(rawValue: "changeCurrency"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeLanguage), name: NSNotification.Name(rawValue: "changeLanguage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNewAssetsData), name: NSNotification.Name(rawValue: "reloadNewMarketData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadNewMarketData), name: NSNotification.Name(rawValue: "reloadAssetsTableView"), object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadWallet"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "changeCurrency"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "changeLanguage"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadNewMarketData"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadAssetsTableView"), object: nil)
    }
    @objc func reloadNewMarketData(){
        walletList.reloadData()
        caculateTotal()
    }
    @objc func refreshNewAssetsData(){
        self.checkTransaction()
        loadData(){success in
            if success{
                self.caculateTotal()
                self.walletList.reloadData()
            }
        }
    }
    func checkTransaction(){
        if assetss.count == 0{
            setUpInitialView()
        } else {
            setupView()
        }
    }
    @objc func changeLanguage(){
        Extension.method.reloadNavigationBarBackButton(navigationBarItem: self.navigationItem)
        checkTransaction()
        walletList.switchRefreshHeader(to: .removed)
        walletList.configRefreshHeader(with:addRefreshHeaser(), container: self, action: {
            self.handleRefresh(self.walletList)
        })
        DispatchQueue.main.async(execute: {
            self.walletList.switchRefreshHeader(to: .refreshing)
        })
    }
    @objc func changeCurrency(){
        DispatchQueue.main.async(execute: {
            self.walletList.switchRefreshHeader(to: .refreshing)
        })
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assetss.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let factor = view.frame.width/375
        let cell = WalletsCell(style: UITableViewCellStyle.default, reuseIdentifier: "WalletCell")
        cell.factor = factor
        let assets = assetss[indexPath.row]
        cell.coinName.text = assets.coinName
        cell.coinAmount.text = Extension.method.scientificMethod(number: assets.totalAmount) + " " + assets.coinAbbName
        checkDataRiseFallColor(risefallnumber: assets.defaultCurrencyPrice, label: cell.coinSinglePrice,currency:priceType, type: "Default")
        checkDataRiseFallColor(risefallnumber: assets.defaultTotalPrice, label: cell.coinTotalPrice,currency:priceType, type: "Default")
        cell.coinTotalPrice.text = "(" + cell.coinTotalPrice.text! + ")"
        cell.coinTotalPrice.textColor = ThemeColor().textGreycolor()
        checkDataRiseFallColor(risefallnumber: assets.floatingPercent, label: cell.profitChange,currency:priceType, type: "Percent")
        cell.profitChange.text = "(" + cell.profitChange.text! + ")"
        checkDataRiseFallColor(risefallnumber: assets.totalRiseFallNumber, label: cell.profitChangeNumber,currency:priceType, type: "Number")
        cell.selectCoin.selectCoinAbbName = assets.coinAbbName
        cell.selectCoin.selectCoinName = assets.coinName
        cell.coinImage.coinImageSetter(coinName: assets.coinAbbName, width: 30, height: 30, fontSize: 5)
        checkDataRiseFallColor(risefallnumber: assets.floatingPrice, label: cell.profitChangeNumber,currency:priceType, type: "Number")
        if assets.unrealizedPrice != 0{
            cell.unrealisedPrice.text = String(Extension.method.scientificMethod(number: assets.unrealizedPrice))
            if String(assets.unrealizedPrice).prefix(1) != "-" {
                cell.unrealisedLabel.text = "Realized Profit:"
            } else{
                cell.unrealisedLabel.text = "Realized Loss:"
            }
        }
        return cell
    }
    func loadData(completion:@escaping (Bool)->Void){
        let dispatchGroup = DispatchGroup()
        self.totalAssets = 0
        self.totalProfit = 0
        for result in assetss{
            dispatchGroup.enter()
            if result.exchangeName == "Global Average"{
                caculateGlobalAverage(result: result){success in
                    dispatchGroup.leave()
                }
            }else if result.exchangeName == "Huobi Australia"{
                caculateHuobiAverage(result: result){success in
                    dispatchGroup.leave()
                }
            } else{
                caculatCryptoCompare(result: result){success in
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue:.main){
            completion(true)
        }
    }
    func caculateGlobalAverage(result:Transactions,completion:@escaping (Bool)->Void){
        var singlePrice:Double = 0
        var currency:Double = 0
        URLServices.fetchInstance.passServerData(urlParameters: ["coin","getCoin?coin=" + result.coinAbbName], httpMethod: "GET", parameters: [String : Any]()) { (response, success) in
            if success{
                if let responseResult = response["quotes"].array{
                    for results in responseResult{
                        if results["currency"].string ?? "" == priceType{
                            singlePrice = results["data"]["price"].double ?? 0
                            APIServices.fetchInstance.getCryptoCurrencyApis(from: result.tradingPairsName, to: [priceType]) { (success, response) in
                                if success{
                                    for result in response{
                                        currency = (result.1.double) ?? 0
                                    }
                                    self.storeToRealm(result: result, singlePrice: singlePrice, currency: currency){ success in
                                        completion(true)
                                    }
                                } else{
                                    completion(true)
                                }
                            }
                        }
                    }
                } else{
                    completion(true)
                }
            } else{
                completion(true)
            }
        }
    }
    func caculateHuobiAverage(result:Transactions,completion:@escaping (Bool)->Void){
        var singlePrice:Double = 0
        var currency:Double = 0
        APIServices.fetchInstance.getHuobiAuCoinPrice(coinAbbName: result.coinAbbName, tradingPairName: result.tradingPairsName, exchangeName: result.exchangeName) { (response, success) in
            if success{
                singlePrice = Double(response["tick"]["close"].string ?? "0") ?? 0
                APIServices.fetchInstance.getCryptoCurrencyApis(from: result.tradingPairsName, to: [priceType]) { (success, response) in
                    if success{
                        for result in response{
                            currency = (result.1.double) ?? 0
                        }
                        self.storeToRealm(result: result, singlePrice: singlePrice, currency: currency){ success in
                            completion(true)
                        }
                    } else{
                        completion(true)
                    }
                }
            } else{
                completion(true)
            }
        }
    }
    func caculatCryptoCompare(result:Transactions,completion:@escaping (Bool)->Void){
        var singlePrice:Double = 0
        var currency:Double = 0
        APIServices.fetchInstance.getExchangePriceData(from: result.coinAbbName, to: result.tradingPairsName, market: result.exchangeName) { (success, response) in
            if success{
                singlePrice = response["RAW"]["PRICE"].double ?? 0
                APIServices.fetchInstance.getCryptoCurrencyApis(from: result.tradingPairsName, to: [priceType]) { (success, response) in
                    if success{
                        for result in response{
                            currency = (result.1.double) ?? 0
                        }
                        self.storeToRealm(result: result, singlePrice: singlePrice, currency: currency){ success in
                            completion(true)
                        }
                    } else{
                        completion(true)
                    }
                }
            } else{
                completion(true)
            }
        }
    }
    @objc func storeToRealm(result:Transactions,singlePrice:Double,currency:Double,completion:@escaping (Bool)->Void){
        var amount:Double = 0
        var transactionPrice:Double = 0
        var singleAverageBuyPrice:Double = 0
        var buyTotalPrice:Double = 0
        var buyAmount:Double = 0
        var sellTotalPrice:Double = 0
        var totalAmount:Double = 0
        var floatingPrice:Double = 0
        var unrealizedPrice:Double = 0
        for each in result.everyTransactions{
            let currencyResult = each.currency.filter{name in return name.name.contains(priceType)}
            if each.status == "Buy"{
                buyAmount += each.amount
                totalAmount += each.amount
                buyTotalPrice += ((each.amount) * (currencyResult.first?.price ?? 0))
            }
            else if each.status == "Sell"{
                totalAmount -= each.amount
            }
        }
        singleAverageBuyPrice = buyTotalPrice / buyAmount
        for each in result.everyTransactions{
            let currencyResult = each.currency.filter{name in return name.name.contains(priceType)}
            if each.status == "Sell"{
                sellTotalPrice += (((currencyResult.first?.price)!) - singleAverageBuyPrice) * each.amount
            }
        }
        unrealizedPrice = sellTotalPrice
        for each in result.everyTransactions{
            let currencyResult = each.currency.filter{name in return name.name.contains(priceType)}
            if each.status == "Buy"{
                amount += each.amount
                transactionPrice += ((each.amount) * (currencyResult.first?.price ?? 0))
            } else if each.status == "Sell"{
                amount -= each.amount
                transactionPrice -= ((each.amount) * (currencyResult.first?.price ?? 0))
            }
        }
        let tran = Transactions()
        tran.coinAbbName = result.coinAbbName
        tran.transactionPrice = transactionPrice
        tran.defaultCurrencyPrice = singlePrice * currency
        tran.defaultTotalPrice = tran.defaultCurrencyPrice * amount
        tran.totalAmount = amount
        tran.totalRiseFallNumber = tran.defaultTotalPrice - tran.transactionPrice
        tran.totalRiseFallPercent = (tran.totalRiseFallNumber / tran.transactionPrice) * 100
        self.totalAssets += tran.defaultTotalPrice
        self.totalProfit += tran.totalRiseFallNumber
        floatingPrice =  ((singlePrice * currency) -  singleAverageBuyPrice) * totalAmount
        let object = try! Realm().objects(Transactions.self).filter("coinAbbName == %@",result.coinAbbName)
        try! Realm().write {
            if object.count != 0{
                object[0].currentSinglePrice = singlePrice
                object[0].currentTotalPrice = singlePrice * amount
                object[0].currentNetValue = transactionPrice * (1/currency)
                object[0].currentRiseFall = (singlePrice * amount) - (transactionPrice * (1/currency))
                object[0].transactionPrice = transactionPrice
                object[0].defaultCurrencyPrice = singlePrice * currency
                object[0].defaultTotalPrice = (singlePrice * currency) * amount
                object[0].totalAmount = amount
                object[0].totalRiseFallNumber = tran.defaultTotalPrice - tran.transactionPrice
                object[0].totalRiseFallPercent =  tran.totalRiseFallPercent
                object[0].floatingPrice = floatingPrice
                object[0].unrealizedPrice = unrealizedPrice
                object[0].floatingPercent = (floatingPrice / (singleAverageBuyPrice * totalAmount)) * 100
            }
        }
        completion(true)
    }
    @objc func updateTransaction(){
        if loginStatus{
            URLServices.fetchInstance.getAssets(){success in
                self.checkTransaction()
                self.loadData(){success in
                    if success{
                        self.caculateTotal()
                        self.walletList.reloadData()
                        self.walletList.switchRefreshHeader(to: .normal(.success, 0.5))
                    } else{
                        self.walletList.switchRefreshHeader(to: .normal(.failure, 0.5))
                    }
                }
            }
        } else{
            self.checkTransaction()
            loadData(){success in
                if success{
                    self.caculateTotal()
                    self.walletList.reloadData()
                    self.walletList.switchRefreshHeader(to: .normal(.success, 0.5))
                } else{
                    self.walletList.switchRefreshHeader(to: .normal(.failure, 0.5))
                }
            }
        }
    }
    @objc func refreshData(){
        checkTransaction()
        self.walletList.beginHeaderRefreshing()
    }
    @objc func refreshPage(){
        self.walletList.beginHeaderRefreshing()
    }
    func caculateTotal(){
        var totalNumbers:Double = 0
        var totalChanges:Double = 0
        var totalUnrealized:Double = 0
        var totalRealized:Double = 0
        for result in assetss{
            totalNumbers += result.defaultTotalPrice
            totalChanges += result.floatingPrice
            totalUnrealized += result.floatingPrice
            totalRealized += result.unrealizedPrice
        }
        checkDataRiseFallColor(risefallnumber: totalUnrealized, label: unrealizedResult,currency:priceType, type: "Number")
        checkDataRiseFallColor(risefallnumber: totalRealized, label: realizedResult,currency:priceType, type: "Number")
        checkDataRiseFallColor(risefallnumber: totalNumbers, label: totalNumber,currency:priceType, type: "Default")
        checkDataRiseFallColor(risefallnumber: totalChanges, label: totalChange,currency:priceType, type: "Number")
    }
    @objc func changetotransaction(){
        let transaction = TransactionsController()
        transaction.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(transaction, animated: true)
    }
    @objc func handleRefresh(_ tableView:UITableView) {
        if loginStatus{
            URLServices.fetchInstance.getAssets(){success in
                self.checkTransaction()
                self.loadData(){success in
                    if success{
                        self.caculateTotal()
                        self.walletList.reloadData()
                        self.walletList.switchRefreshHeader(to: .normal(.success, 0.5))
                    } else{
                        self.walletList.switchRefreshHeader(to: .normal(.failure, 0.5))
                    }
                    if UserDefaults.standard.bool(forKey: "assetsLoad"){
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "successLogin"), object: nil)
                        UserDefaults.standard.set(false,forKey: "assetsLoad")
                    }
                }
            }
        } else{
            self.checkTransaction()
            loadData(){success in
                if success{
                    self.caculateTotal()
                    self.walletList.reloadData()
                    self.walletList.switchRefreshHeader(to: .normal(.success, 0.5))
                } else{
                    self.walletList.switchRefreshHeader(to: .normal(.failure, 0.5))
                }
                if UserDefaults.standard.bool(forKey: "assetsLoad"){
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "successLogin"), object: nil)
                    UserDefaults.standard.set(false,forKey: "assetsLoad")
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            let item = assetss[indexPath.row]
            let eachTransaction = item.everyTransactions
            var deleteID = [Int]()
            for result in eachTransaction{
                deleteID.append(result.id)
            }
            if loginStatus{
                let body:[String:Any] = ["email":email,"token":certificateToken,"transactionID":deleteID]
                URLServices.fetchInstance.passServerData(urlParameters: ["userLogin","deleteTransaction"], httpMethod: "POST", parameters: body) { (response, success) in
                    if success{
                        print("success")
                    }else{
                        print("error")
                    }
                }
            }
            try! Realm().write {
                try! Realm().delete(eachTransaction)
                try! Realm().delete(item)
            }
            checkTransaction()
            caculateTotal()
            self.walletList.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailPage = DetailController()
        detailPage.hidesBottomBarWhenPushed = true
        let cell = self.walletList.cellForRow(at: indexPath) as! WalletsCell
        coinDetail = cell.selectCoin
        detailPage.coinDetails = coinDetail
        detailPage.coinDetailController.alertControllers.status = "detailPage"
        navigationController?.pushViewController(detailPage, animated: true)
    }
    func setUpBasicView(){
        view.backgroundColor = ThemeColor().navigationBarColor()
        let titilebarlogo = UIImageView()
        titilebarlogo.image = UIImage(named: "currencyhelper_icon_")
        titilebarlogo.contentMode = .scaleAspectFit
        titilebarlogo.frame = CGRect(x: 0, y: 0, width: 25, height: 20)
        titilebarlogo.clipsToBounds = true
        navigationItem.titleView = titilebarlogo
    }
    func setUpInitialView(){
        let factor = view.frame.width/375
        existTransactionView.removeFromSuperview()
        view.addSubview(invisibleView)
        invisibleView.addSubview(buttonView)
        invisibleView.addSubview(hintMainView)
        invisibleView.addSubview(hintView)
        buttonView.addSubview(addTransactionButton)
        hintView.addSubview(hintLabel)
        hintMainView.addSubview(hintMainLabel)
        hintMainLabel.text = textValue(name: "mainHint")
        hintMainLabel.font = UIFont.regularFont(23*factor)
        hintLabel.text = textValue(name: "hintLabel")
        hintLabel.font = UIFont.regularFont(13*factor)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":invisibleView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":invisibleView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":hintMainView,"v1":buttonView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(\(80*factor))]-[v1]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":hintMainView,"v1":buttonView]))
        NSLayoutConstraint(item: hintMainLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: hintMainView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: hintMainLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: hintMainView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
        hintMainView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(10*factor)-[v0]-\(10*factor)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":hintMainLabel]))
        hintMainView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":hintMainLabel]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":buttonView,"v1":hintView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(\(60*factor))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":buttonView,"v1":hintView]))
        NSLayoutConstraint(item: buttonView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: invisibleView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: -80*factor).isActive = true
        NSLayoutConstraint(item: buttonView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: invisibleView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: addTransactionButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: buttonView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: addTransactionButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: buttonView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
        buttonView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v5(\(50*factor))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v5":addTransactionButton]))
        buttonView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v5(\(50*factor))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v5":addTransactionButton]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":hintView,"v1":buttonView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v1]-\(5*factor)-[v0(\(80*factor))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":hintView,"v1":buttonView]))
        NSLayoutConstraint(item: hintLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: hintView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: hintLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: hintView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
        hintView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(10*factor)-[v0]-\(10*factor)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":hintLabel]))
        hintView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":hintLabel]))
    }
    func setupView(){
        Extension.method.reloadNavigationBarBackButton(navigationBarItem: self.navigationItem)
        let factor = view.frame.width/375
        totalLabel.text = textValue(name:"mainBalance")
        unrealizedLabel.setTitle(textValue(name: "hintUnrealizedTitle"), for: .normal)
        realizedLabel.setTitle(textValue(name: "hintRealizedTitle"), for: .normal)
        totalLabel.font = UIFont.regularFont(20*factor)
        totalNumber.font = UIFont.boldFont(30*factor)
        totalChange.font = UIFont.regularFont(20*factor)
        addTransactionButton.layer.cornerRadius = 25*factor
        invisibleView.removeFromSuperview()
        view.addSubview(existTransactionView)
        existTransactionView.addSubview(totalProfitView)
        existTransactionView.addSubview(buttonView)
        existTransactionView.addSubview(walletList)
        totalProfitView.addSubview(totalLabel)
        totalProfitView.addSubview(totalNumber)
        realizedView.addSubview(addTransactionButton)
        existTransactionView.addSubview(realizedView)
        realizedView.addSubview(unrealizedLabel)
        realizedView.addSubview(realizedLabel)
        realizedView.addSubview(unrealizedResult)
        realizedView.addSubview(realizedResult)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":existTransactionView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":existTransactionView]))
        existTransactionView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":totalProfitView]))
        existTransactionView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[v0]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":totalProfitView]))
        NSLayoutConstraint(item: totalLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: totalProfitView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: totalNumber, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: totalProfitView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
        totalNumber.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10).isActive = true
        totalNumber.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 10).isActive = true
        totalProfitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[v1]-\(10*factor)-[v2]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v1":totalLabel,"v2":totalNumber,"v3":totalChange]))
        totalProfitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v2]-\(10*factor)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v1":totalLabel,"v2":totalNumber,"v3":totalChange]))
        existTransactionView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v4]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":totalProfitView,"v4":realizedView]))
        existTransactionView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0]-0-[v4(\(60*factor))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":totalProfitView,"v4":realizedView]))
        addTransactionButton.centerXAnchor.constraint(equalTo: realizedView.centerXAnchor, constant: 0).isActive = true
        addTransactionButton.centerYAnchor.constraint(equalTo: realizedView.bottomAnchor, constant: 0).isActive = true
        addTransactionButton.heightAnchor.constraint(equalToConstant: 50*factor).isActive = true
        addTransactionButton.widthAnchor.constraint(equalToConstant: 50*factor).isActive = true
        unrealizedLabel.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        unrealizedLabel.leftAnchor.constraint(equalTo: realizedView.leftAnchor, constant: 0).isActive = true
        unrealizedLabel.bottomAnchor.constraint(equalTo: realizedView.centerYAnchor, constant: 0).isActive = true
        realizedLabel.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        realizedLabel.rightAnchor.constraint(equalTo: realizedView.rightAnchor, constant: 0).isActive = true
        realizedLabel.bottomAnchor.constraint(equalTo: realizedView.centerYAnchor, constant: 0).isActive = true
        unrealizedResult.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        unrealizedResult.leftAnchor.constraint(equalTo: realizedView.leftAnchor, constant: 0).isActive = true
        unrealizedResult.topAnchor.constraint(equalTo: realizedView.centerYAnchor, constant: 0).isActive = true
        realizedResult.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        realizedResult.rightAnchor.constraint(equalTo: realizedView.rightAnchor, constant: 0).isActive = true
        realizedResult.topAnchor.constraint(equalTo: realizedView.centerYAnchor, constant: 0).isActive = true
        existTransactionView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v4]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":realizedView,"v4":buttonView]))
        existTransactionView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0]-0-[v4(\(30*factor))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":realizedView,"v4":buttonView]))
        existTransactionView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v6]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v7":buttonView,"v6":walletList]))
        existTransactionView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v7]-\(10*factor)-[v6]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v7":buttonView,"v6":walletList]))
    }
    @objc func realizedHintshow(){
        realizedHint.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        realizedHint.cancelButton.addTarget(self, action: #selector(cancelRealizeHint), for: .touchUpInside)
        realizedHint.titleLabel.text = textValue(name: "hintRealizedTitle")
        realizedHint.descriptionLabel.text = textValue(name: "hintRealizedDescription")
        realizedHint.cancelButton.setTitle(textValue(name: "done_resend"), for: .normal)
        self.parent?.addChildViewController(realizedHint)
        self.parent?.view.addSubview(realizedHint.view)
    }
    @objc func unrealizedHintshow(){
        unrealizedHint.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        unrealizedHint.cancelButton.addTarget(self, action: #selector(cancelUnrealizeHint), for: .touchUpInside)
        unrealizedHint.titleLabel.text = textValue(name: "hintUnrealizedTitle")
        unrealizedHint.descriptionLabel.text = textValue(name: "hintUnrealizedDescription")
        unrealizedHint.cancelButton.setTitle(textValue(name: "done_resend"), for: .normal)
        self.parent?.addChildViewController(unrealizedHint)
        self.parent?.view.addSubview(unrealizedHint.view)
    }
    @objc func cancelRealizeHint(){
        realizedHint.removeFromParentViewController()
        realizedHint.view.removeFromSuperview()
    }
    @objc func cancelUnrealizeHint(){
        unrealizedHint.removeFromParentViewController()
        unrealizedHint.view.removeFromSuperview()
    }
    var realizedView:UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeColor().greyColor()
        return view
    }()
    var unrealizedLabel:UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle(textValue(name: "hintUnrealizedTitle"), for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.font = UIFont.regularFont(15)
        button.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2)
        let hintImage = UIImage(named: "help")?.reSizeImage(reSize: CGSize(width: 10, height: 10))
        button.setImage(hintImage, for: .normal)
        button.addTarget(self, action: #selector(unrealizedHintshow), for: .touchUpInside)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        return button
    }()
    var realizedLabel:UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle(textValue(name: "hintRealizedTitle"), for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2)
        let hintImage = UIImage(named: "help")?.reSizeImage(reSize: CGSize(width: 10, height: 10))
        button.setImage(hintImage, for: .normal)
        button.titleLabel?.font = UIFont.regularFont(15)
        button.addTarget(self, action: #selector(realizedHintshow), for: .touchUpInside)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        return button
    }()
    var unrealizedResult:UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.font = label.font.withSize(13)
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        return label
    }()
    var realizedResult:UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.font = label.font.withSize(13)
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        return label
    }()
    var hintMainLabel:UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.font = label.font.withSize(23)
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        return label
    }()
    var hintMainView:UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeColor().themeColor()
        return view
    }()
    var hintLabel:UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.font = label.font.withSize(13)
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        return label
    }()
    var hintView:UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeColor().themeColor()
        return view
    }()
    var existTransactionView:UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeColor().themeColor()
        return view
    }()
    var invisibleView:UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeColor().themeColor()
        return view
    }()
    lazy var totalProfitView:UIView = {
        var view = UIView()
        view.backgroundColor = ThemeColor().greyColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var totalLabel:UILabel = {
        var label = UILabel()
        label.font = label.font.withSize(20)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var totalNumber:UILabel = {
        var label = UILabel()
        label.text = "--"
        label.font = label.font.withSize(30)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var totalChange:UILabel = {
        var label = UILabel()
        label.font = label.font.withSize(20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var buttonView:UIView = {
        var view = UIView()
        view.backgroundColor = ThemeColor().themeColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var spinner:UIActivityIndicatorView = {
        var spinner = UIActivityIndicatorView()
        spinner.tintColor = UIColor.white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    var addTransactionButton:UIButton = {
        var button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "AddButton.png"), for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(changetotransaction), for: .touchUpInside)
        return button
    }()
    lazy var walletList:UITableView = {
        let factor = view.frame.width/375
        var tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = ThemeColor().themeColor()
        tableView.register(WalletsCell.self, forCellReuseIdentifier: "WalletCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let header = DefaultRefreshHeader.header()
        header.textLabel.textColor = ThemeColor().whiteColor()
        header.textLabel.font = UIFont.regularFont(12*factor)
        header.tintColor = ThemeColor().whiteColor()
        header.imageRenderingWithTintColor = true
        tableView.configRefreshHeader(with:header, container: self, action: {
            self.handleRefresh(tableView)
        })
        tableView.estimatedRowHeight = 70*factor
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
}
