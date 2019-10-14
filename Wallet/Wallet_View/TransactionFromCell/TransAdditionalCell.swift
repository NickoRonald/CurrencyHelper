import UIKit
class TransAdditionalCell:UITableViewCell{
    var factor:CGFloat?{
        didSet{
            setupviews()
            createKeyboarddonebutton()
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been completed")
    }
    lazy var additionalLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.semiBoldFont(15*factor!)
        label.textColor = UIColor.init(red:187/255.0, green:187/255.0, blue:187/255.0, alpha:1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var additional: UITextField = {
        let textfield = UITextField()
        textfield.textColor = ThemeColor().whiteColor()
        textfield.tintColor = ThemeColor().whiteColor()
        textfield.attributedPlaceholder = NSAttributedString(string:textValue(name: "additional_Placeholder"), attributes:[NSAttributedStringKey.font: UIFont(name:"Montserrat-Light",size:13*factor!) ?? "", NSAttributedStringKey.foregroundColor: ThemeColor().grayPlaceHolder()])
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.keyboardType = UIKeyboardType.default
        return textfield
    }()
    func setupviews(){
        selectionStyle = .none
        backgroundColor = ThemeColor().themeColor()
        addSubview(additionalLabel)
        addSubview(additional)
        NSLayoutConstraint(item: additionalLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: -5*factor!).isActive = true
        NSLayoutConstraint(item: additional, attribute: .top, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 5*factor!).isActive = true
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(16*factor!)-[v0]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":additionalLabel,"v1":additional]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(16*factor!)-[v1]-\(16*factor!)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":additionalLabel,"v1":additional]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v1(\(30*factor!))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":additionalLabel,"v1":additional]))
    }
    func createKeyboarddonebutton(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let donebutton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(doneclick))
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        toolbar.setItems([flexible,flexible,donebutton], animated: false)
        additional.inputAccessoryView = toolbar
    }
    @objc func doneclick(){
        self.endEditing(true)
    }
}
