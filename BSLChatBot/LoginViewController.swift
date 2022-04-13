//
//  LoginViewController.swift
//  HyundaiPOC
//
//  Created by Ankit on 21/06/18.
//  Copyright © 2018 Infogain. All rights reserved.
//

import TransitionButton
import UIKit
let screenSize = UIScreen.main.bounds
let screenWidth = screenSize.width
let screenHeight = screenSize.height
import Firebase

class LoginViewController: UIViewController,UITextFieldDelegate ,URLSessionTaskDelegate, URLSessionDataDelegate {
  //Link each UITextField

    @IBOutlet weak var button: TransitionButton!
    @IBOutlet weak var passwordstrength: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var ContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var signInProspectiveBtn: UIButton!
    
    var iskeyboardOpen = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        Username.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        password.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        signInProspectiveBtn.titleLabel?.font = UIFont.scriptFont(size: 16)
        //signInProspectiveBtn.setTitle("Sign in as Prospective employee", for: .normal)
    
        
        if(appdelegate.isOpenedFromNotification){
            
            
            
            appdelegate.isOpenedFromNotification = false
            containerView.isHidden = true
            
          //  welcome_vector_final wave_sh
            let imgView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
            var img = appLaunchImage()
            if(img != nil)
            {            imgView.image =  img //"welcome_vector_final"
            }
            self.view.addSubview(imgView)
        }
        else{
               containerView.isHidden = false
        }
        
    }
    
    
    func appLaunchImage() -> UIImage? {
        
        let allPngImageNames = Bundle.main.paths(forResourcesOfType: "png", inDirectory: nil)
        
        for imageName in allPngImageNames
        {
            // make sure that the image name contains the string 'LaunchImage' and that we can actually create a UIImage from it.
            
            guard
                imageName.contains("LaunchImage"),
                let image = UIImage(named: imageName)
                else { continue }
            
            // if the image has the same scale AND dimensions as the current device's screen...
            
            if (image.scale == UIScreen.main.scale) && (image.size.equalTo(UIScreen.main.bounds.size))
            {
                return image
            }
        }
        
        return nil
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    //MARK: - Controlling the Keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       
        if textField == Username {
            textField.resignFirstResponder()
            password.becomeFirstResponder()
        } else if textField == password {
            textField.resignFirstResponder()
            if  iskeyboardOpen == true {
                
           
                self.scrollView.contentOffset = CGPoint(x: 0, y: self.scrollView.frame.size.height - (self.button?.frame.origin.y)! - (self.button?.frame.size.height)!)
                
                let contentInsets:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
                iskeyboardOpen = false
            }
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       
    }
    
    @objc func textFieldDidChange(sender: UITextField) {
       
        if !ValidationClass.Shared.isBlank(password) && ValidationClass.Shared.passwordLength(password) {
            let values = ValidationClass.Shared.passwordStrength(sender)
            self.passwordstrength.text = values.0
            self.passwordstrength.textColor = values.1
        }else{
            self.passwordstrength.text = ""
        }
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        let paddingOffset = screenHeight/6.67
        let buttonSize = self.button.bounds.size
        let strengthLabelSize = self.passwordstrength.bounds.size
        contentInset.bottom = keyboardFrame.size.height + buttonSize.height + strengthLabelSize.height + CGFloat(paddingOffset)
        self.scrollView.contentInset = contentInset
        
    }
    

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
    
    //MARK: login button action
    @IBAction func buttonAction(_ sender: TransitionButton) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc: BSWelcomeScreenViewController? = storyboard.instantiateViewController(withIdentifier: "WelcomeScreen1") as? BSWelcomeScreenViewController
//        if let aVc = vc {
//                self.navigationController?.show(aVc, sender: nil)
//        }
        
       
        
        guard NetReachability.isConnectedToNetwork() else {
            SwAlert.showNoActionAlert(Title, message: internetErrorMessage, buttonTitle: keyOK)
            return
        }


        let userName = Username.text!
        let pwd = password.text!

        if ValidationClass.Shared.LoginValidation(email: Username, password: password) {


            button.startAnimation()

                self.authenticate(username: userName,
                                  password: pwd,
                                  completion:{ authenticationResponse in

                                        DispatchQueue.main.async(execute: { () -> Void in
                                            if(authenticationResponse["status"]?.boolValue == true) {
                                            let userDict = authenticationResponse["user"] as! [String:Any]


                                                let center = UNUserNotificationCenter.current()
                                                center.getNotificationSettings { (settings) in
                                                    if(settings.authorizationStatus == .authorized)
                                                    {
                                                        print("Push authorized")
                                                        let empid = userDict["empID"]
                                                        let empid2 = userDict["empID"] as! String + "ios"


                                                         Crashlytics.crashlytics().setUserID(empid as! String)

                                                        Messaging.messaging().subscribe(toTopic: empid2) { error in
                                                            print("Subscribed to  topic allindia")
                                                        }
                                                        Messaging.messaging().subscribe(toTopic: suscribeTopic2) { error in
                                                            print("Subscribed to  topic allindia")
                                                        }

                                                        Messaging.messaging().subscribe(toTopic: empid as! String) { error in
                                                            print("Subscribed to  topic employee id")
                                                        }
                                                        Messaging.messaging().subscribe(toTopic: suscribeTopic) { error in
                                                            print("Subscribed to  topic allindia")
                                                        }
                                                    }
                                                    else
                                                    {

                                                         print("Push not authorized")
//                                                        DispatchQueue.main.async {
//                                                        SwAlert.showTwoActionAlert("Turn On Notifications", message: "To keep receiving notification,Please turn on Notifications", styleone: .cancel, styletwo: .Default, onebuttonTitle: "Not Now", twobuttonTitle: "Settings", placeholder: "" , onecompletion: nil , twocompletion: { _ in
//                                                            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
//
//                                                        })
//                                                        }




                                                    }
                                                }



                                            LoginModel.sharedInstance.setUser(user:userDict)
                                            self.button.stopAnimation(animationStyle: .expand, completion: {



                                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                                let vc: BSWelcomeScreenViewController? = storyboard.instantiateViewController(withIdentifier: "WelcomeScreen1") as? BSWelcomeScreenViewController

                                                if let aVc = vc {
                                                    self.navigationController?.show(aVc, sender: nil)
                                                }

                                            })
                                          } else {
                                                    self.ClearTextFields()
                                                    self.button.stopAnimation()
                                                    SwAlert.showNoActionAlert("", message: authenticationResponse["message"] as! String, buttonTitle: keyOK)
                                                }
                                        })


                });

       }

    }
    //MARK: Prospective button action
    @IBAction func prospectiveEmpAction(_ sender: Any) {
        
        guard NetReachability.isConnectedToNetwork() else {
            SwAlert.showNoActionAlert(Title, message: internetErrorMessage, buttonTitle: keyOK)
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let vc: MobileViewController? = storyboard.instantiateViewController(withIdentifier: "mobileVerification") as? MobileViewController
        if let mVC = vc {
            //self.navigationController?.pushViewController(mVC, animated: true)
            self.navigationController?.show(mVC, sender: nil)
        }
        
    }
    
    
    func ClearTextFields()  {
        //clear the text fields
        self.Username.text = ""
        self.password.text = ""
        self.passwordstrength.text = ""
    }
    
    
   
    
    func authenticate(username: String, password: String, completion: @escaping (_ result: Dictionary<String, AnyObject>) -> ()) {
        
        let params = ["username":username, "password":password,"platform":"iOS","appVersion":appdelegate.build_version] as! Dictionary<String, String>
        var request = URLRequest(url: URL(string: LoginUrl)!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //let session = URLSession.shared
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)

        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            if data != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    print(json)
                    completion(json);
                } catch {
                    //send empty dictionary
                    completion([:]);
                }
            } else {
                
                DispatchQueue.main.async(execute: { () -> Void in
                    self.button.stopAnimation()
                    SwAlert.showNoActionAlert("", message:  error!.localizedDescription, buttonTitle: keyOK)
                })
                
            }
            
        })
        
        task.resume()
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

            if challenge.previousFailureCount > 0 {
                  completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
            }
            if let serverTrust = challenge.protectionSpace.serverTrust {
              completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
     } else {
              print("unknown state. error: \(String(describing: challenge.error))")

           }
        }

   
}


extension UIFont {
    static func scriptFont(size: CGFloat) -> UIFont {
      guard let customFont = UIFont(name: "Montserrat-SemiBold", size: size) else {
        return UIFont.systemFont(ofSize: size)
      }
      return customFont
    }
}
