import UIKit
class CustomPasswordAlertController: UIViewController,UITextFieldDelegate{
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
        alertView.addSubview(emailTextField)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(30*factor)-[v0]-\(30*factor)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":alertView]))
        NSLayoutConstraint(item: alertView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: logoImage, attribute: .centerY, relatedBy: .equal, toItem: alertView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: logoImage, attribute: .centerX, relatedBy: .equal, toItem: alertView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: logo, attribute: .centerY, relatedBy: .equal, toItem: logoImage, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: logo, attribute: .centerX, relatedBy: .equal, toItem: logoImage, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        alertView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(\(60*factor))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":logo]))
        alertView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(\(60*factor))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":logo]))
        alertView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(\(80*factor))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":logoImage]))
        alertView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(\(80*factor))]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":logoImage]))
        titleLabel.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 5*factor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: alertView.leftAnchor, constant: 10*factor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: alertView.rightAnchor, constant: -10*factor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10*factor).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: alertView.leftAnchor, constant: 10*factor).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: alertView.rightAnchor, constant: -10*factor).isActive = true
        descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10*factor).isActive = true
        emailTextField.leftAnchor.constraint(equalTo: alertView.leftAnchor, constant: 20*factor).isActive = true
        emailTextField.rightAnchor.constraint(equalTo: alertView.rightAnchor, constant: -20*factor).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40*factor).isActive = true
        sendEmailButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10*factor).isActive = true
        sendEmailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendEmailButton.leftAnchor.constraint(equalTo: alertView.leftAnchor, constant: 20*factor).isActive = true
        sendEmailButton.rightAnchor.constraint(equalTo: alertView.rightAnchor, constant: -20*factor).isActive = true
        sendEmailButton.heightAnchor.constraint(equalToConstant: 50*factor).isActive = true
        cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cancelButton.topAnchor.constraint(equalTo: sendEmailButton.bottomAnchor, constant: 10*factor).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: alertView.leftAnchor, constant: 20*factor).isActive = true
        cancelButton.rightAnchor.constraint(equalTo: alertView.rightAnchor, constant: -20*factor).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 50*factor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -10*factor).isActive = true
    }
    var alertView:UIView = {
        var view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = ThemeColor().whiteColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    @objc func keyboardWillShow(aNotification:NSNotification){
    }
    @objc func keyboardWillHidden(notification: NSNotification){
    }
    lazy var titleLabel:UILabel = {
        var label = UILabel()
        label.textColor = ThemeColor().darkBlackColor()
        label.text = textValue(name: "title_reset")
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
        label.text = textValue(name: "description_reset")
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
        button.setTitle(textValue(name: "sendButton_reset"), for: .normal)
        button.setTitleColor(ThemeColor().whiteColor(), for: .normal)
        button.titleLabel?.font = UIFont.semiBoldFont(13*view.frame.width/375)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var cancelButton:UIButton = {
        var button = UIButton()
        button.layer.cornerRadius = 8*view.frame.width/375
        button.backgroundColor = ThemeColor().redColor()
        button.setTitle(textValue(name: "done_reset"), for: .normal)
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
    lazy var emailTextField:LeftPaddedTextField = {
        var textField = LeftPaddedTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderWidth = 1*view.frame.width/375
        textField.layer.cornerRadius = 8*view.frame.width/375
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.addTarget(self, action: #selector(allEdit), for: .allEditingEvents)
        textField.attributedPlaceholder = NSAttributedString(string:textValue(name: "placeholder_reset"), attributes:[NSAttributedStringKey.font: UIFont.ItalicFont(13*view.frame.width/375), NSAttributedStringKey.foregroundColor: ThemeColor().grayPlaceHolder()])
        return textField
    }()
    @objc func cancel(){
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
    }
    @objc func allEdit(){
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        if emailPredicate.evaluate(with: emailTextField.text){
            sendEmailButton.backgroundColor = ThemeColor().themeWidgetColor()
            sendEmailButton.isEnabled = true
        }else{
            sendEmailButton.backgroundColor = UIColor.init(red:168/255.0, green:234/255.0, blue:214/255.0, alpha:1)
            sendEmailButton.isEnabled = false
        }
    }
}
