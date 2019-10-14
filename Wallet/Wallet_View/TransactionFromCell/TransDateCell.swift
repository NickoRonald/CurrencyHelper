import UIKit
class TransDateCell:UITableViewCell,UITextFieldDelegate {
    var factor:CGFloat?{
        didSet{
            setupviews()
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been completed")
    }
    lazy var dateLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.semiBoldFont(15*factor!)
        label.textColor = ThemeColor().textGreycolor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var date: UITextField = {
        let textfield = UITextField()
        textfield.backgroundColor = ThemeColor().greyColor()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.textColor = UIColor.white
        textfield.font = textfield.font?.withSize(15)
        textfield.backgroundColor = ThemeColor().greyColor()
        textfield.tintColor = .clear
        textfield.autocorrectionType = .yes
        textfield.borderStyle = UITextBorderStyle.roundedRect
        textfield.textAlignment = .center
        textfield.adjustsFontSizeToFitWidth=true  
        textfield.minimumFontSize=14  
        textfield.layer.cornerRadius = 8*factor!
        return textfield
    }()
    var pickerButton:UIButton = {
        var button = UIButton()
        button.setTitle("sfsfsd", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    func setupviews(){
        selectionStyle = .none
        backgroundColor = ThemeColor().themeColor()
        addSubview(dateLabel)
        addSubview(date)
        NSLayoutConstraint(item: dateLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: date, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(16*factor!)-[v0]-10-[v1]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":dateLabel,"v1":date]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v1(\(30*factor!))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":dateLabel,"v1":date]))
    }
    func createdatepicker(){
    }
}
