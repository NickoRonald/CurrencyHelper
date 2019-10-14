import UIKit
@IBDesignable
class TransCoinMarketCell:UITableViewCell{
    var factor:CGFloat?{
        didSet{
            setupview()
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been completed")
    }
    lazy var marketLabel:UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor().textGreycolor()
       label.font = UIFont.semiBoldFont(15*factor!)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var market: InsetLabel = {
        let label = InsetLabel()
        label.layer.cornerRadius = 8*factor!
        label.layer.backgroundColor = ThemeColor().greyColor().cgColor
        label.font = UIFont.semiBoldFont(13*factor!)
        label.textColor = ThemeColor().whiteColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    func setupview(){
        backgroundColor = ThemeColor().themeColor()
        addSubview(marketLabel)
        addSubview(market)
        accessoryType = .disclosureIndicator
        NSLayoutConstraint(item: marketLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: market, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(16*factor!)-[v0]-\(10*factor!)-[v1]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":marketLabel,"v1":market]))
        market.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -40*factor!).isActive = true
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v1(\(30*factor!))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":marketLabel,"v1":market]))
    }
}
