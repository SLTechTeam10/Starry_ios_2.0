//
//  SwAlert.swift
//  SwAlert


import UIKit



// MARK: - UIDevice Extension

public extension UIDevice {
    
    class func iosVersion() -> Float {
        let versionString =  UIDevice.current.systemVersion
        return NSString(string: versionString).floatValue
    }
    
    class func isiOS8orLater() ->Bool {
        
        let version = UIDevice.iosVersion()
        
        if version >= 8.0 {
            return true
        }
        
        return false
    }
}




enum AlertButtonType  {
    case Default
    case destructive
    case cancel
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


public typealias CompletionHandler = (_ resultObject: AnyObject?) -> Void

private class AlertManager {
    
    static var sharedInstance = AlertManager()
    
    var window : UIWindow = UIWindow(frame: UIScreen.main.bounds)
    lazy var parentController : UIViewController = {
        var parentController = UIViewController()
        parentController.view.backgroundColor = UIColor.clear
        
        if UIDevice.isiOS8orLater() {
            self.window.windowLevel = UIWindow.Level.alert
            self.window.rootViewController = parentController
        }
        
        return parentController
    }()
    
    var alertQueue : [SwAlert] = []
    var showingAlertView : SwAlert?
    var alertView = UIView()
}

class TextFieldObserver: NSObject, UITextFieldDelegate {
    
    let textFieldValueChanged: (UITextField) -> Void
   

    init(textField: UITextField, valueChanged: @escaping (UITextField) -> Void) {
        self.textFieldValueChanged = valueChanged
        super.init()
        textField.addTarget(self, action: #selector(TextFieldObserver.textFieldValueChanged(sender:)), for: .editingChanged)
    }

    @objc func textFieldValueChanged(sender: UITextField) {
        textFieldValueChanged(sender)
    }

}

private class AlertInfo {
    
    var title : String = ""
    var placeholder : String = ""
    var completion : CompletionHandler?
    var styleInfo : AlertButtonType?
    var alertTextFeld : UITextField?
    
    class func generate(_ title: String, placeholder: String?,style : AlertButtonType ,completion: CompletionHandler?) -> AlertInfo {
        
        let alertInfo = AlertInfo()
        alertInfo.title = title
        alertInfo.styleInfo = style
        if placeholder != nil {
            alertInfo.placeholder = placeholder!
        }
        
        alertInfo.completion = completion
        
        return alertInfo
    }
    
    
    class func generate(_ title: String, placeholder: String?,completion: CompletionHandler?) -> AlertInfo {
        
        let alertInfo = AlertInfo()
        alertInfo.title = title
        if placeholder != nil {
            alertInfo.placeholder = placeholder!
        }
        
        alertInfo.completion = completion
        
        return alertInfo
    }
    
    class func generateTextfield (_ title: String, placeholder: String? ) -> AlertInfo {
        let alertInfo = AlertInfo()
        alertInfo.alertTextFeld?.placeholder = placeholder
        alertInfo.alertTextFeld?.text = title
        return alertInfo
    }

}

open class SwAlert: NSObject, UIAlertViewDelegate , UITextFieldDelegate
{
    fileprivate var title : String = ""
    fileprivate var message : String = ""
    fileprivate var cancelInfo : AlertInfo?
    fileprivate var secondButtonInfo : AlertInfo?
    fileprivate var otherButtonHandlers : [AlertInfo] = []
    fileprivate var otherButtonAction : [UIAlertAction] = []
    fileprivate var textFieldInfo : [AlertInfo] = []
    fileprivate var alertSubView : Bool!
    fileprivate var xposition : CGFloat!
    var textFieldObserver: TextFieldObserver?
    
    // MARK: - Class Methods
    class func showNoActionAlert(_ title: String, message: String, buttonTitle: String) {
        let alert = SwAlert()
        alert.title = title
        alert.message = message
        alert.cancelInfo = AlertInfo.generate(buttonTitle, placeholder: nil, completion: nil)
        alert.show()
    }
    

    
    class func showTwoActionAlert(_ title: String, message: String , styleone: AlertButtonType,styletwo: AlertButtonType, onebuttonTitle: String , twobuttonTitle: String , placeholder : String , onecompletion: CompletionHandler? , twocompletion: CompletionHandler?)
    {
        let alert = SwAlert()
        alert.title = title
        alert.message = message
    
        alert.cancelInfo = AlertInfo.generate(onebuttonTitle, placeholder: nil, completion: onecompletion)
        let second =  AlertInfo.generate(twobuttonTitle, placeholder: nil, style: styletwo, completion: twocompletion)
        
        if placeholder != "" {
            alert.addTextField( "" , placeholder: placeholder)
        }
        
        alert.otherButtonHandlers = [second]
        
        alert.show()
    }
   
    
    
    class func showOneActionAlert(_ title: String, message: String, buttonTitle: String, completion: CompletionHandler?)
    {
        let alert = SwAlert()
        alert.title = title
        alert.message = message
        alert.cancelInfo = AlertInfo.generate(buttonTitle, placeholder: nil, completion: completion)
        alert.show()
    }
    
    
    
    class func generate(_ title: String, message: String) -> SwAlert
    {
        let alert = SwAlert()
        alert.title = title
        alert.message = message
        return alert
    }
    
    
    
    // MARK: - Instance Methods
    func setCancelAction(_ buttonTitle: String, completion: CompletionHandler?) {
        self.cancelInfo = AlertInfo.generate(buttonTitle, placeholder: nil, completion: completion)
    }
    
    func addAction(_ buttonTitle: String, completion: CompletionHandler?) {
        let alertInfo = AlertInfo.generate(buttonTitle, placeholder: nil, completion: completion)
        self.otherButtonHandlers.append(alertInfo)
    }
    
    func addTextField(_ title: String, placeholder: String?) {
        
        let alertInfo = AlertInfo.generateTextfield(title, placeholder: placeholder)
        
        if UIDevice.isiOS8orLater() {
            
            self.textFieldInfo.append(alertInfo)
            
        } else {
            
            if self.textFieldInfo.count >= 2 {
                assert(true, "iOS7 is 2 textField max")
            } else {
                self.textFieldInfo.append(alertInfo)
            }
            
        }
    }
    
    func show() {
        if UIDevice.isiOS8orLater() {
            self.showAlertController()
        } else {
            self.showAlertView()
        }
    }
    
    // MARK: - Private
    fileprivate class func dismiss() {
        if UIDevice.isiOS8orLater() {
            SwAlert.dismissAlertController()
        } else {
            SwAlert.dismissAlertView()
        }
    }
    
    
    // MARK: - UIAlertController (iOS 8 or later)
    fileprivate func showAlertController() {
        if AlertManager.sharedInstance.parentController.presentedViewController != nil {
           AlertManager.sharedInstance.alertQueue.append(self)
            return
        }
        
        if #available(iOS 8.0, *) {
            
            let alertController = UIAlertController(title: self.title, message: self.message, preferredStyle: .alert)
            
        
            
            for alertInfo in self.otherButtonHandlers {
                
                let handler = alertInfo.completion
                
                var styletype:UIAlertAction.Style?
                switch alertInfo.styleInfo {
                case .cancel?:
                    styletype = .cancel
                case .destructive?:
                    styletype = .destructive
                default:
                    styletype = .default
                }
                
                let action = UIAlertAction(title: alertInfo.title, style: styletype!  , handler: { (action) -> Void in
                    if let _handler = handler {
                        if alertController.textFields?.count > 0 {
                            _handler(alertController.textFields as AnyObject?)
                             
                        } else {
                            _handler(action)
                        }
                    }
                    SwAlert.dismiss()
                })
                
                if self.textFieldInfo.count > 0 {
                    action.isEnabled = false
                }
                
                self.otherButtonAction.append(action)
                alertController.addAction(action)
            }
            
            for _ in self.textFieldInfo {
                alertController.addTextField(configurationHandler: { (textField) -> Void in
                    self.textFieldObserver = TextFieldObserver.init(textField: textField , valueChanged: {
                        textField in
                        if self.otherButtonAction.count > 0 {
                            if textField.text?.count == 0 && textField.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
                                self.otherButtonAction[0].isEnabled = false
                            } else {
                                self.otherButtonAction[0].isEnabled = true
                            }
                        }
                    })
                })
            }
            
            if self.cancelInfo != nil {
                let handler = self.cancelInfo!.completion
                
                let action = UIAlertAction(title: self.cancelInfo!.title, style: .cancel, handler: { (action) -> Void in
                    if let _handler = handler {
                        _handler(action)
                    }
                    SwAlert.dismiss()
                })
                
                alertController.addAction(action)
                
            } else if self.otherButtonHandlers.count == 0 {
                
                if self.textFieldInfo.count > 0 {
                    let action = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                        SwAlert.dismiss()
                    })
                    alertController.addAction(action)
                } else {
                    let action = UIAlertAction(title: keyOK, style: .default, handler: { (action) -> Void in
                        SwAlert.dismiss()
                    })
                    alertController.addAction(action)
                }
            }
            
            if self.alertSubView == true {
                let imgTitle = UIButton.init(frame: CGRect(x: self.xposition, y: 15, width: 25, height: 25))
                imgTitle.setTitle("!", for: .normal)
                imgTitle.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 20)
                imgTitle.backgroundColor = UIColor.init(hexString: "#e80028")
                imgTitle.setTitleColor(UIColor.white, for: .normal)
                //imgTitle.cornerRadius = 12.5
                alertController.view.addSubview(imgTitle)
            }
            
            if AlertManager.sharedInstance.window.isKeyWindow == false {
                AlertManager.sharedInstance.window.alpha = 1.0
                AlertManager.sharedInstance.window.makeKeyAndVisible()
            }
            
            AlertManager.sharedInstance.alertView = alertController.view
            AlertManager.sharedInstance.parentController.present(alertController, animated: true, completion: nil)
            
        } else {
            
        }
    }
    
    
    fileprivate class func dismissAlertController() {
        if AlertManager.sharedInstance.alertQueue.count > 0 {
            let alert = AlertManager.sharedInstance.alertQueue[0]
            AlertManager.sharedInstance.alertQueue.remove(at: 0)
            alert.show()
        } else {
            AlertManager.sharedInstance.window.alpha = 0.0
            let mainWindow = UIApplication.shared.delegate?.window
            mainWindow!!.makeKeyAndVisible()
        }
    }
    
     // MARK: - UITextfieldDelegate
    
   @objc private func textFieldDidChange(sender: UITextField) {
    
        print("textFieldDidChange is called")
        
        if self.otherButtonAction.count > 0 {
            if sender.text?.count == 0 && sender.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
                self.otherButtonAction[0].isEnabled = false
            } else {
                self.otherButtonAction[0].isEnabled = true
            }
        }
        
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("textFieldDidChange is called")
        if self.otherButtonAction.count > 0 {
            if textField.text?.count == 0 && textField.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
                self.otherButtonAction[0].isEnabled = false
            } else {
                self.otherButtonAction[0].isEnabled = true
            }
        }
        
        return true
    }
    
    
    // MARK: - UIAlertView (iOS 7)
    
    fileprivate func showAlertView() {
        
        if AlertManager.sharedInstance.showingAlertView != nil {
            AlertManager.sharedInstance.alertQueue.append(self)
            return
        }
        
        if self.cancelInfo == nil && self.textFieldInfo.count > 0 {
            self.cancelInfo = AlertInfo.generate("Cancel", placeholder: nil, completion: nil)
        }
        
        var cancelButtonTitle: String?
        if self.cancelInfo != nil {
            cancelButtonTitle = self.cancelInfo!.title
        }
        
        let alertView = UIAlertView(title: self.title, message: self.message, delegate: self, cancelButtonTitle: cancelButtonTitle)
        
        for alertInfo in self.otherButtonHandlers {
            alertView.addButton(withTitle: alertInfo.title)
        }
        
        if self.textFieldInfo.count == 1 {
            alertView.alertViewStyle = .plainTextInput
        } else if self.textFieldInfo.count == 2 {
            alertView.alertViewStyle = .loginAndPasswordInput
        }
        
        AlertManager.sharedInstance.alertView = alertView
        AlertManager.sharedInstance.showingAlertView = self
        
        alertView.show()
    }
    
    fileprivate class func dismissAlertView() {
         AlertManager.sharedInstance.showingAlertView = nil
        
        if AlertManager.sharedInstance.alertQueue.count > 0 {
            let alert = AlertManager.sharedInstance.alertQueue[0]
            AlertManager.sharedInstance.alertQueue.remove(at: 0)
            alert.show()
        }
    }
    
    
    
    // MARK: - UIAlertViewDelegate
    // The field at index 0 will be the first text field (the single field or the login field), the field at index 1 will be the password field.
    
    open func alertViewShouldEnableFirstOtherButton(_ alertView: UIAlertView) -> Bool {
        if self.textFieldInfo.count > 0 {
            let textField = alertView.textField(at: 0)!
            let text = textField.text
            
            let length = text!.characters.count
            
            if text != nil && length > 0 {
                return true
            }
        }
        return false
    }
    
    open func willPresent(_ alertView: UIAlertView) {
        if self.textFieldInfo.count > 0 {
            for index in 0..<self.textFieldInfo.count {
                let textField = alertView.textField(at: index)
                if textField != nil {
                    let alertInfo = self.textFieldInfo[index]
                    textField!.placeholder = alertInfo.placeholder
                    textField!.text = alertInfo.title
                }
            }
        }
    }
    
    open func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        var result : AnyObject? = alertView
        
        if self.textFieldInfo.count > 0 {
            var textFields : [UITextField] = []
            for index in 0..<self.textFieldInfo.count {
                let textField = alertView.textField(at: index)
                if textField != nil {
                    textFields.append(textField!)
                }
            }
            result = textFields as AnyObject?
        }
        
        if self.cancelInfo != nil && buttonIndex == alertView.cancelButtonIndex {
            if let _handler = self.cancelInfo!.completion {
                _handler(result)
            }
        } else {
            var resultIndex = buttonIndex
            if self.textFieldInfo.count > 0 || self.cancelInfo != nil {
                resultIndex -= 1
            }
            
            if self.otherButtonHandlers.count > resultIndex {
                let alertInfo = self.otherButtonHandlers[resultIndex]
                if let _handler = alertInfo.completion {
                    _handler(result)
                }
            }
        }
        
        SwAlert.dismiss()
    }
}





