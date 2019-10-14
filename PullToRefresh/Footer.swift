import Foundation
import UIKit
@objc public protocol RefreshableFooter:class{
    func heightForFooter()->CGFloat
    func didUpdateToNoMoreData()
    func didResetToDefault()
    func didEndRefreshing()
    func didBeginRefreshing()
    func shouldBeginRefreshingWhenScroll()->Bool
}
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}
public enum RefreshKitFooterText{
    case pullToRefresh
    case tapToRefresh
    case scrollAndTapToRefresh
    case refreshing
    case noMoreData
}
public enum RefreshMode{
    case scroll
    case tap
    case scrollAndTap
}
open class DefaultRefreshFooter:UIView, RefreshableFooter{
    public static func footer()-> DefaultRefreshFooter{
        return DefaultRefreshFooter()
    }
    public let spinner:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    public  let textLabel:UILabel = UILabel(frame: CGRect(x: 0,y: 0,width: 140,height: 40))
    open var refreshMode = RefreshMode.scrollAndTap{
        didSet{
            tap.isEnabled = (refreshMode != .scroll)
            udpateTextLabelWithMode(refreshMode)
        }
    }
    fileprivate func udpateTextLabelWithMode(_ refreshMode:RefreshMode){
        switch refreshMode {
        case .scroll:
            textLabel.text = textDic[.pullToRefresh]
        case .tap:
            textLabel.text = textDic[.tapToRefresh]
        case .scrollAndTap:
            textLabel.text = textDic[.scrollAndTapToRefresh]
        }
    }
    fileprivate var tap:UITapGestureRecognizer!
    fileprivate var textDic = [RefreshKitFooterText:String]()
    open  func setText(_ text:String,mode:RefreshKitFooterText){
        textDic[mode] = text
        textLabel.text = textDic[.pullToRefresh]
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(spinner)
        addSubview(textLabel)
        textDic[.pullToRefresh] = PullToRefreshKitFooterString().pullUpToRefresh
        textDic[.refreshing] = PullToRefreshKitFooterString().refreshing
        textDic[.noMoreData] = PullToRefreshKitFooterString().noMoreData
        textDic[.tapToRefresh] = PullToRefreshKitFooterString().tapToRefresh
        textDic[.scrollAndTapToRefresh] = PullToRefreshKitFooterString().scrollAndTapToRefresh
        udpateTextLabelWithMode(refreshMode)
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.textAlignment = .center
        tap = UITapGestureRecognizer(target: self, action: #selector(DefaultRefreshFooter.catchTap(_:)))
        self.addGestureRecognizer(tap)
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2);
        spinner.center = CGPoint(x: frame.width/2 - 70 - 20, y: frame.size.height/2)
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func catchTap(_ tap:UITapGestureRecognizer){
        let scrollView = self.superview?.superview as? UIScrollView
        scrollView?.switchRefreshFooter(to: .refreshing)
    }
    open func heightForFooter() -> CGFloat {
        return PullToRefreshKitConst.defaultFooterHeight
    }
    open func didBeginRefreshing() {
        self.isUserInteractionEnabled = true
        textLabel.text = textDic[.refreshing];
        spinner.startAnimating()
    }
    open func didEndRefreshing() {
        udpateTextLabelWithMode(refreshMode)
        spinner.stopAnimating()
    }
    open func didUpdateToNoMoreData(){
        self.isUserInteractionEnabled = false;
        textLabel.text = textDic[.noMoreData]
    }
    open func didResetToDefault() {
        self.isUserInteractionEnabled = true
        udpateTextLabelWithMode(refreshMode)
    }
    open func shouldBeginRefreshingWhenScroll()->Bool {
        return refreshMode != .tap
    }
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard refreshMode != .scroll else{
            return
        }
        self.backgroundColor = ThemeColor().themeColor()
    }
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard refreshMode != .scroll else{
            return
        }
        self.backgroundColor = ThemeColor().themeColor()
    }
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard refreshMode != .scroll else{
            return
        }
        self.backgroundColor = ThemeColor().themeColor()
    }
    override open var tintColor: UIColor!{
        didSet{
            textLabel.textColor = tintColor
            spinner.color = tintColor
        }
    }
}
class RefreshFooterContainer:UIView{
    enum RefreshFooterState {
        case idle
        case refreshing
        case willRefresh
        case noMoreData
    }
    var refreshAction:(()->())?
    var attachedScrollView:UIScrollView!
    weak var delegate:RefreshableFooter?
    fileprivate var _state:RefreshFooterState = .idle
    var state: RefreshFooterState{
        get{
            return _state
        }
        set{
            guard newValue != _state else{
                return
            }
            _state =  newValue
            if newValue == .refreshing{
                DispatchQueue.main.async(execute: {
                    self.delegate?.didBeginRefreshing()
                    self.refreshAction?()
                })
            }else if newValue == .noMoreData{
                self.delegate?.didUpdateToNoMoreData()
            }else if newValue == .idle{
                self.delegate?.didResetToDefault()
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    func commonInit(){
        self.backgroundColor = UIColor.clear
        self.autoresizingMask = .flexibleWidth
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if self.state == .willRefresh {
            self.state = .refreshing
        }
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard newSuperview != nil else{ 
            if !self.isHidden{
                var inset = attachedScrollView.contentInset
                inset.bottom = inset.bottom - self.frame.height
                attachedScrollView.contentInset = inset
            }
            return
        }
        guard newSuperview is UIScrollView else{
            return;
        }
        attachedScrollView = newSuperview as? UIScrollView
        attachedScrollView.alwaysBounceVertical = true
        if !self.isHidden {
            var contentInset = attachedScrollView.contentInset
            contentInset.bottom = contentInset.bottom + self.frame.height
            attachedScrollView.contentInset = contentInset
        }
        self.frame = CGRect(x: 0,y: attachedScrollView.contentSize.height,width: self.frame.width, height: self.frame.height)
        addObservers()
    }
    deinit{
        removeObservers()
    }
    fileprivate func addObservers(){
        attachedScrollView?.addObserver(self, forKeyPath:PullToRefreshKitConst.KPathOffSet, options: [.old,.new], context: nil)
        attachedScrollView?.addObserver(self, forKeyPath:PullToRefreshKitConst.KPathContentSize, options:[.old,.new] , context: nil)
        attachedScrollView?.panGestureRecognizer.addObserver(self, forKeyPath:PullToRefreshKitConst.KPathPanState, options:[.old,.new] , context: nil)
    }
    fileprivate func removeObservers(){
        attachedScrollView?.removeObserver(self, forKeyPath: PullToRefreshKitConst.KPathContentSize,context: nil)
        attachedScrollView?.removeObserver(self, forKeyPath: PullToRefreshKitConst.KPathOffSet,context: nil)
        attachedScrollView?.panGestureRecognizer.removeObserver(self, forKeyPath: PullToRefreshKitConst.KPathPanState,context: nil)
    }
    func handleScrollOffSetChange(_ change: [NSKeyValueChangeKey : Any]?){
        if state != .idle && self.frame.origin.y != 0{
            return
        }
        let insetTop = attachedScrollView.contentInset.top
        let contentHeight = attachedScrollView.contentSize.height
        let scrollViewHeight = attachedScrollView.frame.size.height
        if insetTop + contentHeight > scrollViewHeight{
            let offSetY = attachedScrollView.contentOffset.y
            if offSetY > self.frame.origin.y - scrollViewHeight + attachedScrollView.contentInset.bottom{
                let oldOffset = (change?[NSKeyValueChangeKey.oldKey] as AnyObject).cgPointValue
                let newOffset = (change?[NSKeyValueChangeKey.newKey] as AnyObject).cgPointValue
                guard newOffset?.y > oldOffset?.y else{
                    return
                }
                let shouldStart = self.delegate?.shouldBeginRefreshingWhenScroll() ?? false
                guard shouldStart else{
                    return
                }
                beginRefreshing()
            }
        }
    }
    func handlePanStateChange(_ change: [NSKeyValueChangeKey : Any]?){
        guard state == .idle else{
            return
        }
        if attachedScrollView.panGestureRecognizer.state == .ended {
            let scrollInset = attachedScrollView.contentInset
            let scrollOffset = attachedScrollView.contentOffset
            let contentSize = attachedScrollView.contentSize
            if scrollInset.top + contentSize.height <= attachedScrollView.frame.height{
                if scrollOffset.y >= -1 * scrollInset.top {
                    let shouldStart = self.delegate?.shouldBeginRefreshingWhenScroll() ?? false
                    guard shouldStart else{
                        return
                    }
                    beginRefreshing()
                }
            }else{
                if scrollOffset.y > contentSize.height + scrollInset.bottom - attachedScrollView.frame.height {
                    let shouldStart = self.delegate?.shouldBeginRefreshingWhenScroll() ?? false
                    guard shouldStart else{
                        return
                    }
                    beginRefreshing()
                }
            }
        }
    }
    func handleContentSizeChange(_ change: [NSKeyValueChangeKey : Any]?){
        self.frame = CGRect(x: 0,y: self.attachedScrollView.contentSize.height,width: self.frame.size.width,height: self.frame.size.height)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == PullToRefreshKitConst.KPathOffSet && self.isUserInteractionEnabled{
            handleScrollOffSetChange(change)
        }
        guard !self.isHidden else{
            return;
        }
        if keyPath == PullToRefreshKitConst.KPathPanState && self.isUserInteractionEnabled{
            handlePanStateChange(change)
        }
        if keyPath == PullToRefreshKitConst.KPathContentSize {
            handleContentSizeChange(change)
        }
    }
    func beginRefreshing(){
        if self.window != nil {
            self.state = .refreshing
        }else{
            if state != .refreshing{
                self.state = .willRefresh
            }
        }
    }
    func endRefreshing(){
        self.state = .idle
        self.delegate?.didEndRefreshing()
    }
    func resetToDefault(){
        self.state = .idle
    }
    func updateToNoMoreData(){
        self.state = .noMoreData
    }
}
