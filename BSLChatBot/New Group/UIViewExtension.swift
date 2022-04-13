//
//  UIViewExtension.swift
//  Pods
//
//  Created by Shohei Yokoyama on 2016/10/22.
//
//

import UIKit

var activityIndicator:UIActivityIndicatorView!
var activityIndicatorContainer: UIView!

extension UIView {
    
    enum EdgeDirection { case left, right, none }
    
    func mask(with style: EdgeDirection) {
        let center = style.center(of: bounds)
        let path: UIBezierPath = .init()
        path.move(to: center)
        path.addArc(withCenter: center, radius: bounds.height , startAngle: style.angle.start, endAngle: style.angle.end, clockwise: style.isClockwise)
        
        let maskLayer: CAShapeLayer = .init()
        maskLayer.frame = bounds
        maskLayer.path  = path.cgPath
        layer.mask = style == .none ? nil : maskLayer
    }
    
    
    func createGradientLayer(firstColor : String, secColor : String)
    {
        
        let gradientLayer = CAGradientLayer()
        let gradientOffset = self.bounds.size.height / self.bounds.size.width / 2
        
        gradientLayer.startPoint = CGPoint(x : 0.5, y : 0.5 + gradientOffset)
        gradientLayer.endPoint = CGPoint(x :  1, y :  0.5 - gradientOffset)

        gradientLayer.frame = self.bounds
        gradientLayer.colors = [UIColor.init(hexString: firstColor).cgColor, UIColor.init(hexString: secColor).cgColor]

        self.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    
        func createGradientLayer() {
            let rect = self.bounds
            let topRect = CGRect(x: 0, y: 0, width: rect.size.width/2, height: rect.size.height)
            UIColor.red.set()
            guard let topContext = UIGraphicsGetCurrentContext() else { return }
            topContext.fill(topRect)
            
            let bottomRect = CGRect(x: rect.size.width/2, y: 0, width: rect.size.width/2, height: rect.size.height)
            UIColor.green.set()
            guard let bottomContext = UIGraphicsGetCurrentContext() else { return }
            bottomContext.fill(bottomRect)
        }
}


extension String {
        // Returns a date from a string in yyyy-MM-dd. Will return today's date if input is invalid.
        var asDate: Date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.date(from: self) ?? Date()
        }
    
    var firstLowercased: String {
        return prefix(1).lowercased()  + dropFirst()
    }
    
    var trimSpaceandNewline: String {
       return (replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)).trimmingCharacters(in: CharacterSet.newlines)
    }
    
}

//MARK: - UITextView
extension UITextView{
    
    func numberOfLines() -> CGFloat {
        
        if let fontUnwrapped =  UIFont.init(name: "Montserrat", size: 13.0) {
            return CGFloat(self.contentSize.height / fontUnwrapped.lineHeight)
        }
        
        return 0
    }
    
}


extension UIView.EdgeDirection {
    var angle: (start: CGFloat, end: CGFloat) {
        switch self {
        case .left, .right: return (start: .pi + (.pi / 2), end: .pi / 2)
        case .none: return (start: 0, end: 0)
        }
    }
    
    var isClockwise: Bool {
        switch self {
        case .left: return false
        default:    return true
        }
    }
    
    func center(of bounds: CGRect) -> CGPoint {
        switch self {
        case .left: return CGPoint(x: bounds.width, y: bounds.height / 2)
        default:    return CGPoint(x: 0, y: bounds.height / 2)
        }
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension Bundle {
    
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
func setActivityIndicatorOnWindow(vc:UIWindow) {
    // Configure the background containerView for the indicator
    
    activityIndicatorContainer = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
    activityIndicatorContainer.center.x = vc.center.x
    // Need to subtract 44 because WebKitView is pinned to SafeArea
    //   and we add the toolbar of height 44 programatically
    activityIndicatorContainer.center.y = vc.center.y - 44
    activityIndicatorContainer.backgroundColor = UIColor.black
    activityIndicatorContainer.alpha = 0.8
    activityIndicatorContainer.layer.cornerRadius = 10
    
    // Configure the activity indicator
    activityIndicator = UIActivityIndicatorView()
    activityIndicator.hidesWhenStopped = true
    activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicatorContainer.addSubview(activityIndicator)
    vc.addSubview(activityIndicatorContainer)
    
    // Constraints
    activityIndicator.centerXAnchor.constraint(equalTo: activityIndicatorContainer.centerXAnchor).isActive = true
    activityIndicator.centerYAnchor.constraint(equalTo: activityIndicatorContainer.centerYAnchor).isActive = true
}
func setActivityIndicator(vc:UIViewController) {
    // Configure the background containerView for the indicator

    activityIndicatorContainer = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
    activityIndicatorContainer.center.x = vc.view.center.x
    // Need to subtract 44 because WebKitView is pinned to SafeArea
    //   and we add the toolbar of height 44 programatically
    activityIndicatorContainer.center.y = vc.view.center.y - 44
    activityIndicatorContainer.backgroundColor = UIColor.black
    activityIndicatorContainer.alpha = 0.8
    activityIndicatorContainer.layer.cornerRadius = 10
    
    // Configure the activity indicator
    activityIndicator = UIActivityIndicatorView()
    activityIndicator.hidesWhenStopped = true
    activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicatorContainer.addSubview(activityIndicator)
    vc.view.addSubview(activityIndicatorContainer)
    
    // Constraints
    activityIndicator.centerXAnchor.constraint(equalTo: activityIndicatorContainer.centerXAnchor).isActive = true
    activityIndicator.centerYAnchor.constraint(equalTo: activityIndicatorContainer.centerYAnchor).isActive = true
}
func showActivityIndicator(show: Bool) {
    if show {
        activityIndicator.startAnimating()
    } else {
        activityIndicator.stopAnimating()
        activityIndicatorContainer.removeFromSuperview()
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}

extension UIColor {
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        
      //  let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
   
}


extension UIView {
    
    func RoundUpparTwoCorners(_ corner : CGFloat )  {
        self.layer.cornerRadius = CGFloat(corner)
        self.clipsToBounds = true
        self.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
    }
    
    func RoundBottomTwoCorners(_ corner : CGFloat )  {
        self.layer.cornerRadius = CGFloat(corner)
        self.clipsToBounds = true
        self.layer.maskedCorners = [
            .layerMaxXMaxYCorner,
            .layerMaxXMinYCorner
        ]
    }
    
    
    func MakeShadow(_ corner : CGFloat )  {
        
        
    }
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            
            animation.toValue = toValue
            animation.duration = duration
            animation.isRemovedOnCompletion = false
            animation.fillMode = CAMediaTimingFillMode.forwards
            
            self.layer.add(animation, forKey: nil)
        }
}



extension UITableViewCell {
    
    var viewControllerForTableView : UIViewController?{
        return ((self.superview as? UITableView)?.delegate as? UIViewController)
    }
    
}

extension UICollectionViewCell {
    
    var viewControllerForCollectionView : UIViewController?{
       return ((((self.superview as? UICollectionView)?.delegate as? UITableViewCell)?.superview as? UITableView)?.delegate as? UIViewController)
    }
}

extension UIViewController {
    
    // hardcoupling HJRevealViewController
    func menuscreen() {
        let view = appdelegate.window?.rootViewController as! UINavigationController
        let firstview = view.viewControllers[0] as! HJRevealViewController
        firstview.openDrawer()
    }
    // hardcoupling HJRevealViewController
    func closemenuscreen()  {
        let view = appdelegate.window?.rootViewController as! UINavigationController
        let firstview = view.viewControllers[0] as! HJRevealViewController
        firstview.closeDrawer()
    }
    
    func SetNavigationBar()  {

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.setToolbarHidden(true, animated: false)
        if #available(iOS 15, *)
        {
               // do nothing auto 
        }else{
            self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "header"), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
        

        let titleView = UIImageView(image: #imageLiteral(resourceName: "bluestar_logo"))
        self.navigationItem.titleView = titleView
    }
    
}

class HorizontalView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let topRect = CGRect(x: 0, y: 10, width: rect.size.width/2, height: rect.size.height+10)
        UIColor.red.set()
        guard let topContext = UIGraphicsGetCurrentContext() else { return }
        topContext.fill(topRect)
        
        let bottomRect = CGRect(x: rect.size.width/2, y: 10, width: rect.size.width/2, height: rect.size.height+10)
        UIColor.green.set()
        guard let bottomContext = UIGraphicsGetCurrentContext() else { return }
        bottomContext.fill(bottomRect)
    }
}



@IBDesignable open class CustomView: UIView {
    
    // MARK: - Properties
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            
        }
    }
    
    @IBInspectable var topColor: UIColor = UIColor.clear {
        didSet {
            setGradient()
        }
    }
    @IBInspectable var bottomColor: UIColor = UIColor.clear {
        didSet {
            setGradient()
        }
    }
    
    override open class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    
    
    private func setGradient() {
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
        (layer as! CAGradientLayer).startPoint = CGPoint(x: 1.0, y: 0.0)
        (layer as! CAGradientLayer).endPoint = CGPoint(x: 0.0, y: 1.0)
        (layer as! CAGradientLayer).locations = [0.5,0.35]
        (layer as! CAGradientLayer).locations = [0.5,0.5]

    }
    
    @IBInspectable open var borderWidth: Double {
        get {
            return Double(self.layer.borderWidth)
        }
        set {
            self.layer.borderWidth = CGFloat(newValue)
        }
    }
    
    @IBInspectable open var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable open var shadowColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.shadowColor!)
        }
        set {
            self.layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable open var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable open var shadowOffset: CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
           
        }
    }
    
    @IBInspectable open var shadowRadius: CGFloat {
        get {
            return self.layer.shadowRadius
        }
        set {
            self.layer.shadowRadius = newValue
        }
    }
    
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = false
        setGradient()
    }
}


@IBDesignable class TriangleGradientView: UIView {
    
    
}



@IBDesignable open class CustomButton: UIButton {
    
    //MARK: - Properties
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable open var borderWidth: Double {
        get {
            return Double(self.layer.borderWidth)
        }
        set {
            self.layer.borderWidth = CGFloat(newValue)
        }
    }
    
    @IBInspectable open var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable open var shadowColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.shadowColor!)
        }
        set {
            self.layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable open var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable open var shadowOffset: CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable open var shadowRadius: CGFloat {
        get {
            return self.layer.shadowRadius
        }
        set {
            self.layer.shadowRadius = newValue
        }
    }
    
    
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = true
    }
}


@IBDesignable open class CurvedUIImageView: UIImageView {
    
    private func pathCurvedForView(givenView: UIView, curvedPercent:CGFloat) ->UIBezierPath
    {
        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x:0, y:0))
        arrowPath.addLine(to: CGPoint(x:givenView.bounds.size.width, y:0))
        arrowPath.addLine(to: CGPoint(x:givenView.bounds.size.width, y:givenView.bounds.size.height))
        arrowPath.addCurve(to: CGPoint(x:0, y:givenView.bounds.size.height), controlPoint1: CGPoint(x:givenView.bounds.size.width/2, y:givenView.bounds.size.height+givenView.bounds.size.height*curvedPercent), controlPoint2: CGPoint(x:givenView.bounds.size.width, y:givenView.bounds.size.height-givenView.bounds.size.height*curvedPercent))
        arrowPath.addLine(to: CGPoint(x:0, y:0))
        arrowPath.close()
        
        return arrowPath
    }
    
    @IBInspectable open var curvedPercent : CGFloat = 0 {
        didSet{
            guard curvedPercent <= 1 && curvedPercent >= 0 else {
                return
            }
            
            let shapeLayer = CAShapeLayer(layer: self.layer)
            shapeLayer.path = self.pathCurvedForView(givenView: self,curvedPercent: curvedPercent).cgPath
            shapeLayer.frame = self.bounds
            shapeLayer.masksToBounds = true
            self.layer.mask = shapeLayer
        }
    }
    
}
