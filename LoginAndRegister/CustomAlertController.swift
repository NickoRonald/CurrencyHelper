import UIKit
class CustomAlertController: UIViewController {
    var email:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    func setUpView(){
        let factor = view.frame.width/375
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.addSubview(alertView)
        alertView.addSubview(logoImage)
        logoImage.addSubview(logo)
        alertView.addSubview(cancelButton)
        alertView.addSubview(sendEmailButton)
        alertView.addSubview(titleLabel)
        alertView.addSubview(descriptionLabel)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(30*factor)-[v0]-\(30*factor)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":alertView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(\(250*factor))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":alertView]))
        NSLayoutConstraint(item: alertView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: logoImage, attribute: .centerY, relatedBy: .equal, toItem: alertView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: logoImage, attribute: .centerX, relatedBy: .equal, toItem: alertView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: logo, attribute: .centerY, relatedBy: .equal, toItem: logoImage, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: logo, attribute: .centerX, relatedBy: .equal, toItem: logoImage, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        alertView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(\(60*factor))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":logo]))
        alertView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(\(60*factor))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":logo]))
        alertView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(\(80*factor))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":logoImage]))
        alertView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(\(80*factor))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":logoImage]))
        NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: logoImage, attribute: .bottom, multiplier: 1, constant: 5).isActive = true
        alertView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(10*factor)-[v0]-\(10*factor)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":titleLabel]))
        alertView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(10*factor)-[v0]-\(10*factor)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":descriptionLabel]))
        NSLayoutConstraint(item: descriptionLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 5).isActive = true
        alertView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(20*factor)-[v0]-\(20*factor)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":cancelButton]))
        alertView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(20*factor)-[v0]-\(20*factor)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":sendEmailButton]))
        NSLayoutConstraint(item: sendEmailButton, attribute: .top, relatedBy: .equal, toItem: alertView, attribute: .centerY, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: sendEmailButton, attribute: .bottom, relatedBy: .equal, toItem: alertView, attribute: .centerY, multiplier: 3/2, constant: -5).isActive = true
        NSLayoutConstraint(item: cancelButton, attribute: .top, relatedBy: .equal, toItem: sendEmailButton, attribute: .bottom, multiplier: 1, constant: 5).isActive = true
        NSLayoutConstraint(item: cancelButton, attribute: .bottom, relatedBy: .equal, toItem: alertView, attribute: .bottom, multiplier: 1, constant: -10).isActive = true
    }
    var alertView:UIView = {
        var view = UIView()
        view.layer.cornerRadius = 8*view.frame.width/375
        view.backgroundColor = ThemeColor().whiteColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var titleLabel:UILabel = {
        var label = UILabel()
        label.textColor = ThemeColor().darkBlackColor()
        label.text = textValue(name: "title_resend")
        label.font = UIFont.boldFont(18*view.frame.width/375)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var descriptionLabel:UILabel = {
        var label = UILabel()
        label.textColor = ThemeColor().textGreycolor()
        label.text = textValue(name: "description_resend")
        label.font = UIFont.regularFont(15*view.frame.width/375)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var sendEmailButton:UIButton = {
        var button = UIButton()
        button.layer.cornerRadius = 8*view.frame.width/375
        button.backgroundColor = ThemeColor().blueColor()
        button.setTitle(textValue(name: "sendButton_resend"), for: .normal)
        button.setTitleColor(ThemeColor().whiteColor(), for: .normal)
        button.titleLabel?.font = UIFont.semiBoldFont(13)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var cancelButton:UIButton = {
        var button = UIButton()
        button.layer.cornerRadius = 8*view.frame.width/375
        button.backgroundColor = ThemeColor().redColor()
        button.setTitle(textValue(name: "done_resend"), for: .normal)
        button.setTitleColor(ThemeColor().whiteColor(), for: .normal)
        button.titleLabel?.font = UIFont.semiBoldFont(13*view.frame.width/375)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var logoImage:UIImageView = {
        var imageView = UIImageView()
        imageView.backgroundColor = ThemeColor().blueColor()
        imageView.layer.cornerRadius = 40*view.frame.width/375
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.borderColor = ThemeColor().whiteColor().cgColor
        imageView.layer.borderWidth = 5*view.frame.width/375
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var logo:UIImageView = {
        var imageView = UIImageView()
        imageView.backgroundColor = ThemeColor().blueColor()
        imageView.layer.cornerRadius = 30*view.frame.width/375
        imageView.image = UIImage(named: "email")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
}
