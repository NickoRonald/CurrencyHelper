import UIKit
@IBDesignable
class TransCoinTypeCell:UITableViewCell{
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
    lazy var coinLabel:UILabel = {
        let label = UILabel()
        label.text = "币种"
        label.font = UIFont.semiBoldFont(15*factor!)
        label.textAlignment = .left
        label.textColor = ThemeColor().textGreycolor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var coin:InsetLabel = {
        let label = InsetLabel()
        label.textColor = UIColor.white
        label.layer.cornerRadius = 8*factor!
        label.layer.backgroundColor = ThemeColor().greyColor().cgColor
        label.font = UIFont.semiBoldFont(13*factor!)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var coinarrow: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "navigation_arrow.png"))
        imageView.clipsToBounds = true
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    func setupviews(){
        backgroundColor = ThemeColor().themeColor()
        addSubview(coinLabel)
        addSubview(coin)
        accessoryType = .disclosureIndicator
        NSLayoutConstraint(item: coinLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: coin, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(16*factor!)-[v0]-\(10*factor!)-[v1]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":coinLabel,"v1":coin,"v3":coinarrow]))
        coin.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -40*factor!).isActive = true
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v1(\(30*factor!))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":coinLabel,"v1":coin,"v3":coinarrow]))
    }
}
