import UIKit
import RevealingSplashView
class LaunchScreenViewController: UIViewController {
    let revealingSplashView = RevealingSplashView(iconImage:UIImage(named: "CurrencyHelperLogo")!, iconInitialSize: CGSize(width: 200, height: 200), backgroundColor: UIColor.init(patternImage: UIImage.init(imageLiteralResourceName: "LaunchBackColor")))
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(patternImage: UIImage.init(imageLiteralResourceName: "LaunchBackColor"))
        view.addSubview(revealingSplashView)
        revealingSplashView.animationType = .heartBeat
        getData()
    }
    func getData(){
        revealingSplashView.startAnimation()
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            APIServices.fetchInstance.writeJsonExchange(){ success in
                if success{
                    print("success")
                     dispatchGroup.leave()
                } else{
                     dispatchGroup.leave()
                }
            }
            dispatchGroup.enter()
            URLServices.fetchInstance.getCoinList(){ success in
                if success{
                    print("success")
                    dispatchGroup.leave()
                } else{
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.enter()
            URLServices.fetchInstance.getGlobalAverageCoinList(){ success in
            if success{
                dispatchGroup.leave()
            } else{
                dispatchGroup.leave()
            }
            }
            dispatchGroup.notify(queue:.main){
                UserDefaults.standard.set(true, forKey: "launchedBefore")
                    let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomePage") as UIViewController
                    self.revealingSplashView.heartAttack = true
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
            }
    }
}
class LaunchScreen: UIView {
    let revealingSplashView = RevealingSplashView(iconImage: #imageLiteral(resourceName: "bcg_logo"), iconInitialSize: CGSize(width: 200, height: 200), backgroundColor:UIColor.white)
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(revealingSplashView)
        revealingSplashView.animationType = .heartBeat
        revealingSplashView.startAnimation(nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
