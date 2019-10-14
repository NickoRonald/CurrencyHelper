import UIKit
class TransTimeCell:UITableViewCell, UITextFieldDelegate{
    var factor:CGFloat?{
        didSet{
            setupviews()
        }
    }
    let datepicker = UIDatePicker()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been completed")
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    lazy var timeLabel:UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor().textGreycolor()
        label.font = UIFont.semiBoldFont(15*factor!)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var time: UITextField = {
        let textfield:UITextField = UITextField()
        textfield.textColor = UIColor.white
        textfield.keyboardType = UIKeyboardType.default
        textfield.backgroundColor = ThemeColor().greyColor()
        textfield.frame = CGRect(x:50*factor!, y: 70*factor!, width: 200*factor!, height: 30*factor!)
        textfield.tintColor = .clear
        textfield.borderStyle = UITextBorderStyle.roundedRect
        textfield.textAlignment = .center
        textfield.clipsToBounds = false
        textfield.adjustsFontSizeToFitWidth=true  
        textfield.minimumFontSize=14  
        textfield.layer.cornerRadius = 8*factor!
        textfield.translatesAutoresizingMaskIntoConstraints = false
        return textfield
    }()
    func setupviews(){
        selectionStyle = .none
        backgroundColor = ThemeColor().themeColor()
        addSubview(timeLabel)
        addSubview(time)
        NSLayoutConstraint(item: timeLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: time, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(16*factor!)-[v0]-\(10*factor!)-[v1]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":timeLabel,"v1":time]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v1(\(30*factor!))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":timeLabel,"v1":time]))
    }
}
