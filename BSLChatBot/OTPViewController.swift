//
//  OTPViewController.swift
//  BSLChatBot
//  Improvised by Shweta Singh
//  Created by Shailendra Barewar on 14/01/22.
//  Copyright © 2022 Santosh. All rights reserved.
//

import UIKit
import Firebase
import TransitionButton

class OTPViewController: UIViewController , UITextFieldDelegate ,URLSessionTaskDelegate, URLSessionDataDelegate{

    @IBOutlet var mainOtpView: UIView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var textViewOne: UITextField!
    @IBOutlet var textViewTwo: UITextField!
    @IBOutlet var textViewThree: UITextField!
    @IBOutlet var textViewFour: UITextField!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var loginButton: TransitionButton!
    var otp_varification : String = ""
    var mobileNumber : String = ""
    var otpTimerGlobal : Timer = Timer()
    //@IBOutlet weak var otpFullVeriable: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = "OTP sent to \(mobileNumber)"
        self.styling()

        setupOtpExperiance()
        // otp timer
        otpTimerGlobal = initiateTimerForOtp()
        //auto otp handler
        initOtpAutoParsing()
        // simulate OTP
        //setOtp()
        // config resend button
        let tap = UITapGestureRecognizer(target: self, action: #selector(resendOtp))
        timerLabel.isUserInteractionEnabled = true
        timerLabel.addGestureRecognizer(tap)
    }
    
   @objc func resendOtp(){
    
       if timerLabel.text != "Resend OTP"{
           /*
            // no action required
            DispatchQueue.main.async(execute: { () -> Void in
               SwAlert.showNoActionAlert("Info", message:  "Please wait till time complete", buttonTitle: keyOK)
           })*/
           return
       }
       // clear existing otp data if any
       clearOtpFields()
       // Request driven otp timer
       if otpTimerGlobal.isValid {
           print("Resending OTP request, invalidating Timer...")
           otpTimerGlobal.invalidate()
       }
       otpTimerGlobal =  self.initiateTimerForOtp()
        resendOtpForVerification(mobileNumber: mobileNumber) {  authenticationResponse in
            DispatchQueue.main.async(execute: { () -> Void in
                let response = authenticationResponse  as! [String:Any]
                if((response["status"] as AnyObject).boolValue == true) {
                    let userDict = response["result"] as! [String:Any]
                    let otp = userDict["otp"] as! String
                    print("success resend otp received \(otp)")
                    // response driven otp timer
                    //self.initiateTimerForOtp()
                }else{
                    print("Mobile number, OTP Request Error ::\(response)")
                    DispatchQueue.main.async(execute: { () -> Void in
                        SwAlert.showNoActionAlert("Error", message:  "Request error, please check your network", buttonTitle: keyOK)
                    })
                }
            })
        }
    }
    
    func styling() {
        mainOtpView.layer.cornerRadius = 7
        textViewOne.layer.cornerRadius = 4
        textViewTwo.layer.cornerRadius = 4
        textViewThree.layer.cornerRadius = 4
        textViewFour.layer.cornerRadius = 4
        loginButton.layer.cornerRadius = 4
        messageLabel.font = UIFont.scriptFont(size: 14)
        textViewOne.font = UIFont.scriptFont(size: 16)
        textViewTwo.font = UIFont.scriptFont(size: 16)
        textViewThree.font = UIFont.scriptFont(size: 16)
        textViewFour.font = UIFont.scriptFont(size: 16)
        timerLabel.font =  UIFont.scriptFont(size: 14)
    }
    
    func clearOtpFields(){
        textViewOne.text = ""
        textViewTwo.text = ""
        textViewThree.text = ""
        textViewFour.text = ""
    }
    
    func setOtp() {
        if(otp_varification != "") {
            let digit  = otp_varification.digits
            /*
            textViewOne.text = digit[0].string
            textViewTwo.text = digit[1].string
            textViewThree.text = digit[2].string
            textViewFour.text = digit[3].string
             */
            //self.otpFullVeriable.text = digit[0].string + digit[1].string + digit[2].string + digit[3].string
            //textViewOne.text = otpFullVeriable.text
        }
    }
    
    func setupOtpExperiance(){
        textViewOne.delegate = self
        textViewTwo.delegate = self
        textViewThree.delegate = self
        textViewFour.delegate = self
        
        textViewOne.tag = 1
        
        textViewOne.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textViewTwo.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textViewThree.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textViewFour.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    
    func initOtpAutoParsing(){
        print("Print OTP auto parsing.")
        
        self.textViewOne.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        self.textViewOne.becomeFirstResponder()
    }
    
    

    @objc func textFieldDidChange(textField: UITextField){4
            let text = textField.text
        if textField.textContentType == UITextContentType.oneTimeCode{
                    //here split the text to your four text fields
                    if let otpCode = textField.text, otpCode.count > 3{
                        //textViewOne.text = String(otpCode[otpCode.startIndex])
                        textViewOne.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 0)])
                        textViewTwo.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 1)])
                        textViewThree.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 2)])
                        textViewFour.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 3)])
                }
            }
            /*if  text?.count == 1 {
                switch textField{
                case textViewOne:
                    //textViewOne.becomeFirstResponder()
                    textViewTwo.becomeFirstResponder()
                case textViewTwo:
                    //textViewTwo.becomeFirstResponder()
                    textViewThree.becomeFirstResponder()
                case textViewThree:
                    //textViewThree.becomeFirstResponder()
                    textViewFour.becomeFirstResponder()
                case textViewFour:
                    textViewFour.resignFirstResponder()
                default:
                    break
                }
            }
            if  text?.count == 0 {
                switch textField{
                case textViewOne:
                    textViewOne.becomeFirstResponder()
                case textViewTwo:
                    textViewOne.becomeFirstResponder()
                case textViewThree:
                    textViewTwo.becomeFirstResponder()
                case textViewFour:
                    textViewThree.becomeFirstResponder()
                default:
                    break
                }
            }
            else{

            }*/
        }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var rv :Bool = true
    
        if (string.count == 1){
                   if textField == textViewOne {
                       textViewTwo?.becomeFirstResponder()
                   }
                   if textField == textViewTwo {
                       textViewThree?.becomeFirstResponder()
                   }
                   if textField == textViewThree {
                       textViewFour?.becomeFirstResponder()
                   }
                   if textField == textViewFour {
                       textViewFour?.resignFirstResponder()
                       textField.text? = string
                        //APICall Verify OTP
                       //Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.VerifyOTPAPI), userInfo: nil, repeats: false)
                   }
                   textField.text? = string
                   return false
        }else{
            if string.count == 0 {
                       if textField == textViewOne {
                           textViewOne?.becomeFirstResponder()
                       }
                       if textField == textViewTwo {
                           textViewOne?.becomeFirstResponder()
                       }
                       if textField == textViewThree {
                           textViewTwo?.becomeFirstResponder()
                       }
                       if textField == textViewFour {
                           textViewThree?.becomeFirstResponder()
                       }
                       textField.text? = string
                       return false
                   }
        }
        
       
        
        return rv
    }
    
    @IBAction func loginAction(_ sender: TransitionButton) {
        print("Initiating login process...")
        
        
        
        
        guard NetReachability.isConnectedToNetwork() else {
            SwAlert.showNoActionAlert(Title, message: internetErrorMessage, buttonTitle: keyOK)
            return
        }
        
        
        guard !textViewOne.text!.isEmpty else{
            SwAlert.showNoActionAlert(MsgConstants.titleAlert, message: MsgConstants.optMandatoryMsg, buttonTitle: keyOK)
            return
        }
        
        guard !textViewTwo.text!.isEmpty else{
            SwAlert.showNoActionAlert(MsgConstants.titleAlert, message: MsgConstants.optMandatoryMsg, buttonTitle: keyOK)
            return
        }
        guard !textViewThree.text!.isEmpty else{
            SwAlert.showNoActionAlert(MsgConstants.titleAlert, message: MsgConstants.optMandatoryMsg, buttonTitle: keyOK)
            return
        }
        
        guard !textViewFour.text!.isEmpty else{
            SwAlert.showNoActionAlert(MsgConstants.titleAlert, message: MsgConstants.optMandatoryMsg, buttonTitle: keyOK)
            return
        }
        
        // progress animation
        sender.startAnimation()
        
        let final_otp = textViewOne.text! + textViewTwo.text! + textViewThree.text! + textViewFour.text!
        //let fullOtp = otp_varification
        self.authenticate(mobileNumber: mobileNumber, otp: final_otp) { authenticationResponse in
            DispatchQueue.main.async(execute: { () -> Void in
                let response = authenticationResponse  as [String:Any]
                if((response["status"] as AnyObject).boolValue == true) {
                    print("Authentication Success, Result : \(String(describing: response["result"]))")
                    let reslutDict = response["result"] as! [String:Any]
                    let authResult = reslutDict["auth"] as! Bool
                    if  !authResult{
                        DispatchQueue.main.async(execute: { () -> Void in
                            sender.stopAnimation()
                            SwAlert.showNoActionAlert("", message: authenticationResponse["message"] as! String, buttonTitle: keyOK)
                        })
                        return
                    }
                    let userDict = reslutDict["user"] as! [String:Any]
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
                            }
                        }
                    
                    LoginModel.sharedInstance.setUser(user:userDict)
                    
                    // light user data stoage
                    let lightUsr = LightUserData(mobile: userDict["mobileNumber"] as! String,
                                                 empId: userDict["empID"] as! String,
                                                 type: LightUserData.UserType.prospective)
                    LightUtility.setLightUser(lUser: lightUsr)
                    // light user storage done
                    self.loginButton.stopAnimation(animationStyle: .normal  , completion: {
                        let storyboard = UIStoryboard(name: "starrylight", bundle: nil)
                        let vc: BSSLWelcomeScreenViewController? = storyboard.instantiateViewController(withIdentifier: "WelcomeScreenSL1") as? BSSLWelcomeScreenViewController
                        if let aVc = vc {
                            self.navigationController?.show(aVc, sender: nil)
                        }
                    })
                    
                }else{
                    DispatchQueue.main.async(execute: { () -> Void in
                        //self.ClearTextFields()
                        sender.stopAnimation()
                        SwAlert.showNoActionAlert("", message: authenticationResponse["message"] as! String, buttonTitle: keyOK)
                    })
                }
            })
        }
    }
    
    func authenticate(mobileNumber:String,otp: String, completion: @escaping (_ result: Dictionary<String, AnyObject>) -> ()) {
        //
        print("Mobile Number \(mobileNumber) &  OTP \(otp)")
        //let params2 = ["send_to" :mobileNumber, "password": otp, "platform":platform,"appVersion":appVersion]
        let params = ["username" :mobileNumber, "password": otp, "platform":platform,"appVersion":appVersion]
        let url = URL(string: URLs.BaseUrl+URLs.DevEnv.verifyEmployee)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //let session = URLSession.shared
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            //9406555841
            if data != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    print("Auth RESPONSE ::::::::::")
                    print(json)
                    completion(json);
                } catch {
                    //send empty dictionary
                    completion([:]);
                }
            } else {
                DispatchQueue.main.async(execute: { () -> Void in
                    //self.button.stopAnimation()
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

    
    
    func initiateTimerForOtp() -> Timer{
        // reset time to 0
        //var timeCounter = 30.0
        var timeCounter = 45.0
        // Create a few  Attributed String
        let emptyAttribStr = NSMutableAttributedString.init(string: "")
        emptyAttribStr.setAttributes([:], range: NSMakeRange(0, emptyAttribStr.length))
        // initial timestamp on counter
        //self.timerLabel.text = "I didn't receive a code (\(Int(timeCounter)))"
        self.timerLabel.attributedText  = NSMutableAttributedString.init(string:"I didn't receive a code (\(Int(timeCounter)))")
        // set timer
       let otpTimer =  Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            timeCounter -= timer.timeInterval
            print("time counter = \(Int(timeCounter))")
           if timeCounter == 0{
                let wihtAttribStr = NSMutableAttributedString.init(string: "Resend OTP")
                // Add Underline Style Attribute.
                wihtAttribStr.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range:
                    NSRange.init(location: 0, length: wihtAttribStr.length));
                // invalidate/off the timer and update UI label with click function
                timer.invalidate()
                self.timerLabel.attributedText  = wihtAttribStr
            }else{
                
                let timerAttribStr = NSMutableAttributedString.init(string:"I didn't receive a code (\(Int(timeCounter)))")
                timerAttribStr.setAttributes([:], range: NSMakeRange(0, emptyAttribStr.length))
                self.timerLabel.attributedText  = timerAttribStr
            }
            
        }
        return otpTimer
    }
    
    //MARK: resend OTP process
    func resendOtpForVerification(mobileNumber:String, completion: @escaping (_ result: Dictionary<String, AnyObject>) -> ()) {
        
        let params = ["send_to" :mobileNumber] as! Dictionary<String, String>
        
        var request = URLRequest(url: URL(string: URLs.BaseUrl+URLs.DevEnv.sendOtp)!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        
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
                    //self.button.stopAnimation()
                    SwAlert.showNoActionAlert("", message:  error!.localizedDescription, buttonTitle: keyOK)
                })
                
            }
            
        })
        
        task.resume()
    }
    

}
extension StringProtocol  {
    var digits: [Int] { compactMap(\.wholeNumberValue) }
}

extension LosslessStringConvertible {
    var string: String { .init(self) }
}
extension Numeric where Self: LosslessStringConvertible {
    var digits: [Int] { string.digits }
}
