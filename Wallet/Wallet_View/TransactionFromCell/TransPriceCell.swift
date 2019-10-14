import UIKit
protocol TestField {
    func getField()->String
}
class TransPriceCell:UITableViewCell{
    var factor:CGFloat?{
        didSet{
            setupviews()
            createpricedonebutton()
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been completed")
    }
    lazy var priceLabel:UILabel = {
        let label = UILabel()
        label.text = "买入价格"
        label.font = UIFont.semiBoldFont(15*factor!)
        label.textColor = ThemeColor().textGreycolor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var price: LeftPaddedTextField = {
        let textfield = LeftPaddedTextField()
        textfield.keyboardType = UIKeyboardType.decimalPad
        textfield.textColor = ThemeColor().whiteColor()
        textfield.tintColor = ThemeColor().whiteColor()
        textfield.frame = CGRect(x:0, y: 0, width: 200*factor!, height: 30*factor!)
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.attributedPlaceholder = NSAttributedString(string:textValue(name: "pricePlaceholder"), attributes:[NSAttributedStringKey.font: UIFont.ItalicFont(13*factor!), NSAttributedStringKey.foregroundColor: ThemeColor().grayPlaceHolder()])
        textfield.backgroundColor = ThemeColor().greyColor()
        textfield.layer.cornerRadius = 8*factor!
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let donebutton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(pricedoneclick))
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        toolbar.setItems([flexible,flexible,donebutton], animated: false)
        textfield.inputAccessoryView = toolbar
        return textfield
    }()
    lazy var priceType: InsetLabel = {
        let label = InsetLabel()
        label.layer.backgroundColor = ThemeColor().greyColor().cgColor
        label.layer.cornerRadius = 8*factor!
        label.textColor = ThemeColor().whiteColor()
        label.font = UIFont.semiBoldFont(13*factor!)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    func setupviews(){
        selectionStyle = .none
        backgroundColor = ThemeColor().themeColor()
        addSubview(priceLabel)
        addSubview(price)
        addSubview(priceType)
        NSLayoutConstraint(item: priceLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: -5*factor!).isActive = true
        NSLayoutConstraint(item: price, attribute: .top, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 5*factor!).isActive = true
        NSLayoutConstraint(item: priceType, attribute: .centerY, relatedBy: .equal, toItem: priceLabel, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(16*factor!)-[v0]-\(5*factor!)-[v3]-\(10*factor!)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":priceLabel,"v1":price,"v3":priceType]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(16*factor!)-[v1]-\(16*factor!)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":priceLabel,"v1":price,"v3":priceType]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v1(\(30*factor!))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":priceLabel,"v1":price,"v3":priceType]))        
    }
    func createpricedonebutton() {
    }
    @objc func pricedoneclick(){
        self.endEditing(true)
    }
    var spinner:UIActivityIndicatorView = {
        var spinner = UIActivityIndicatorView()
        spinner.tintColor = UIColor.white
        return spinner
    }()
}
