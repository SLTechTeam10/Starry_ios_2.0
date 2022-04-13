//
//  MobileViewController.swift
//  BSLChatBot
//
//  Created by Shailendra Barewar on 11/01/22.
//  Copyright © 2022 Santosh. All rights reserved.
//

import UIKit
import TransitionButton

class MobileViewController: UIViewController, UITextFieldDelegate ,URLSessionTaskDelegate, URLSessionDataDelegate {

    
    @IBOutlet var mobileNoView: UIView!
    @IBOutlet var msgLabel: UILabel!
    @IBOutlet var countryCodeText: UITextField!
    @IBOutlet var mobileText: UITextField!
    @IBOutlet var saprateView: UIView!
    @IBOutlet var nextButton: TransitionButton!
    @IBOutlet var infoView: UIView!
    //@IBOutlet var noteTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.styling()
        
    }
    
    func styling() {
        self.infoView.layer.cornerRadius = 7 //self.infoView.frame.width/6.0
        infoView.layer.borderWidth = 1.0
        infoView.layer.cornerRadius = 7 //self.infoView.frame.width/9.0
        infoView.layer.borderColor = UIColor.black.cgColor
        saprateView.backgroundColor = UIColor.black
        mobileNoView.layer.cornerRadius = 7
        msgLabel.font = UIFont.scriptFont(size: 14)
        countryCodeText.font = UIFont.scriptFont(size: 16)
        mobileText.font = UIFont.scriptFont(size: 16)
        //noteTextView.font = UIFont.scriptFont(size: 14)
        
        // text view delegate
        mobileText.delegate = self
        //extra config
        mobileText.becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 10
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    @IBAction func varifyMobileNumber(_ sender: TransitionButton) {

        
        guard NetReachability.isConnectedToNetwork() else {
            SwAlert.showNoActionAlert(Title, message: internetErrorMessage, buttonTitle: keyOK)
            return
        }

        guard !mobileText.text!.isEmpty else{
            SwAlert.showNoActionAlert(MsgConstants.titleAlert, message: MsgConstants.emptyMobNumber , buttonTitle: keyOK)
            return
        }
            
        //start button animation
        sender.startAnimation()
            
        let mobile = mobileText.text!
        print("user status about mobile number:: \(mobile)")
        self.checkUserStatus(mobileNumber: mobile) { userAuthenticateResponse in
            print("user status Response :: \(userAuthenticateResponse)")
            let response = userAuthenticateResponse  as [String:Any]
                if((response["status"] as AnyObject).boolValue == true) {
                    let userExist = response["result"] as! [String:Any]
                    let empStatus = userExist["employeeExist"] as! Bool
                    if (empStatus) {
                        
                        let actStatus = userExist["isActive"] as! Bool
                        if  !actStatus{
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.nextButton.stopAnimation()
                                SwAlert.showNoActionAlert("", message: "Your mobile number has not been registered with us. Kindly contact HR." as! String, buttonTitle: keyOK)
                            })
                            return
                        }
                        
                        print(" SUCCESS :: emp exist")
                        self.sendOtpForVerification(mobileNumber: mobile) {  authenticationResponse in
                            DispatchQueue.main.async(execute: { () -> Void in
                                let response = authenticationResponse  as! [String:Any]
                                if((response["status"] as AnyObject).boolValue == true) {
                                    let userDict = response["result"] as! [String:Any]
                                    let otp = userDict["otp"] as! String
                                    
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let vc: OTPViewController? = storyboard.instantiateViewController(withIdentifier: "otpVerification") as? OTPViewController
                                    if let mVC = vc {
                                        mVC.mobileNumber = mobile
                                        mVC.otp_varification = otp
                                        self.navigationController?.show(mVC, sender: nil)
                                    }
                                    
                                }else{
                                    print("Mobile number, OTP Request Error ::\(response)")
                                    DispatchQueue.main.async(execute: { () -> Void in
                                        //sender.stopAnimation()
                                        self.nextButton.stopAnimation()
                                        SwAlert.showNoActionAlert("Error", message:  "Request error, please check your network", buttonTitle: keyOK)
                                    })
                                }
                            })
                        }
                         
                    }else{
                        
                            print(" user/emp status Error ::")
                            DispatchQueue.main.async(execute: { () -> Void in
                                //self.sender.stopAnimation()
                                self.nextButton.stopAnimation()
                                SwAlert.showNoActionAlert("Error", message:  "Your mobile number has not been registered with us. Kindly contact HR.", buttonTitle: keyOK)
                            })
                    }
                }else{
                    print(" emp status Request Error ::\(response)")
                    DispatchQueue.main.async(execute: { () -> Void in
                        //sender.stopAnimation()
                        self.nextButton.stopAnimation()
                        SwAlert.showNoActionAlert("Error", message:  "Your mobile number has not been registered with us. Kindly contact HR.", buttonTitle: keyOK)
                    })
                }
            
            // stop animation below
            //sender.stopAnimation()
        }
    }
    
    func checkUserStatus(mobileNumber:String, completion: @escaping (_ result: Dictionary<String, AnyObject>) -> ()) {
        
        let params = ["phoneNumber" :mobileNumber] as! Dictionary<String, String>
        
        //var request = URLRequest(url: URL(string: verifyEmp)!)
        var request = URLRequest(url: URL(string: URLs.BaseUrl+URLs.DevEnv.checkEmpStatus)!)
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
                print(" user Error:: \(error!.localizedDescription)")
                DispatchQueue.main.async(execute: { () -> Void in
                    //self.button.stopAnimation()
                    SwAlert.showNoActionAlert("", message:  error!.localizedDescription, buttonTitle: keyOK)
                })
            }
        })
        
        task.resume()
        
    }
    
    
    func sendOtpForVerification(mobileNumber:String, completion: @escaping (_ result: Dictionary<String, AnyObject>) -> ()) {
        
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
    
    
  
}
