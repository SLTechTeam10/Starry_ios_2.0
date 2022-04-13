//
//  TestYourselfWebViewViewController.swift
//  BSLChatBot
//
//  Created by Satinder on 25/03/20.
//  Copyright © 2020 Santosh. All rights reserved.
//

import UIKit
import WebKit


class TestYourselfWebViewViewController: UIViewController , WKNavigationDelegate {
    
    var webView: WKWebView!
    var flag:String = ""
    var viewWeb = UIView()
    var longMessage:String?
    var imageUrl:String?
    var url:String?
    var nextScreenHTML:String?
    var notificationTile:String?
    var newLinkClicked = Bool()


    var activityIndicatorContainer: UIView!
    var activityIndicator: UIActivityIndicatorView!


    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        //self.view.addSubview(viewWeb)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white , NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 20.0)!]
        if #available(iOS 15, *)
        {
               // do nothing auto
        }else{
            //self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "header"), for: .default)
            //self.navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.titleTextAttributes = textAttributes
        }
        //navigationController?.navigationBar.titleTextAttributes = textAttributes
        if(flag == "Notification" ){
            navigationItem.title = "Notification Details"
            let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
            if #available(iOS 15, *)
            {
                   // do nothing auto
            }else{
                //self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "header"), for: .default)
                //self.navigationController?.navigationBar.shadowImage = UIImage()
                navigationController?.navigationBar.titleTextAttributes = textAttributes
            }
            //navigationController?.navigationBar.titleTextAttributes = textAttributes
            
        }
        else{
        let titleView = UIImageView(image: #imageLiteral(resourceName: "bluestar_logo"))
        self.navigationItem.titleView = titleView
        }
        
        let backImage = UIImage(named: "back_arrow")?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(goBack))
        
       loadFaqWebView()

        // Do any additional setup after loading the view.
       // https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf
        
//        var htmlFile = Bundle.main.path(forResource: "Bluestar", ofType: "html")
//        var htmlString = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
//       // webView.loadHTMLString(htmlString!, baseURL: nil)
//
//        let url1 = URL(string: "https://www.google.com")!
//        webView.load(URLRequest(url: url1))
        if(nextScreenHTML != nil){
             webView.loadHTMLString(nextScreenHTML!, baseURL: nil)
            
        }
        
       else if(flag == "Warehouse" ){

            if(!(url ?? "").isEmpty){
                let url1 = URL(string: url!)!
                webView.load(URLRequest(url: url1))
            }



        }

       else if(flag == "Notification" ){

            if( !(longMessage ?? "").isEmpty){
            webView.loadHTMLString(longMessage!, baseURL: nil)
            }
            else if(!(imageUrl ?? "").isEmpty){
                let url = URL(string: imageUrl!)!
                webView.load(URLRequest(url: url))
            }



        }
       else if(flag == "Assess Yourself"){
        let url = URL(string: "https://covid.apollo247.com")!
        webView.load(URLRequest(url: url))
                    // 2
          webView.frame=CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height-180)
            let label = UILabel(frame: CGRect(x: 0, y: screenSize.height-200, width: screenSize.width, height: 130))
            label.text = "Disclaimer: You have been directed to Apollo Hospitals website for this self-assessment test."

            label.lineBreakMode = NSLineBreakMode.byWordWrapping

             label.numberOfLines = 2
          //  label.center = CGPoint(x: view.frame.midX, y: view.frame.height)
            label.textAlignment = NSTextAlignment.center
            let toolbarTitle = UIBarButtonItem(customView: label)


//            toolbarItems = [toolbarTitle]

            viewWeb.addSubview(label)


//                    let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
//                    toolbarItems = [refresh]
                    navigationController?.isToolbarHidden = true

        }
        else if(flag == "Cashless Hosp"){

//            let url = URL(string: cashHospitalURL)!
//            webView.load(URLRequest(url: url))

            let url = URL(string: cashHospitalURL)!
            webView.load(URLRequest(url: url))
            // 2
            webView.frame=CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height-180)
            let label = UILabel(frame: CGRect(x: 0, y: screenSize.height-200, width: screenSize.width, height: 130))
            label.text = "Disclaimer: You have been directed to \nhttps://www.paramounttpa.com/"
            label.font = UIFont(name: "Montserrat-Regular", size: 14)
            label.lineBreakMode = NSLineBreakMode.byWordWrapping
            //label.backgroundColor=UIColor.green
            label.numberOfLines = 2
            //  label.center = CGPoint(x: view.frame.midX, y: view.frame.height)
            label.textAlignment = NSTextAlignment.center
            let toolbarTitle = UIBarButtonItem(customView: label)


            //            toolbarItems = [toolbarTitle]

            viewWeb.addSubview(label)


            //                    let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
            //                    toolbarItems = [refresh]
            navigationController?.isToolbarHidden = true





        }
        else {
            var url = URL(string: "https://bslapps.s3-ap-southeast-1.amazonaws.com/starry/covid/faq/covidfaq.htm")!
            
            if LightUtility.getLightUser() != nil{
               // url = URL(string: "https://newjoineedev.bluestarindia.com:3500/faq/")!
                url = URL(string: URLs.BaseUrl+URLs.DevEnv.faqUrl)!
            }else{
                url = URL(string: "https://bslapps.s3-ap-southeast-1.amazonaws.com/starry/covid/faq/covidfaq.htm")!
            }
            webView.load(URLRequest(url: url))
        }
        

        
        
    }
    fileprivate func loadFaqWebView(){
        //Script for scale page to fit. Set this scrpit in configuration
        let jScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let wkUScript = WKUserScript(source: jScript, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(wkUScript)
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.dataDetectorTypes = [.link]

        webConfiguration.userContentController = wkUController
        webView = WKWebView(frame:.zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
       //
        if(flag == "Assess Yourself" || flag == "Cashless Hosp"){
        viewWeb.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        //viewWeb.backgroundColor=UIColor.red
        self.view.addSubview(viewWeb)
        viewWeb.addSubview(webView)
        }
        else{
            view = webView
        }
        
        
    }
    @objc func goBack() {
                navigationController?.isToolbarHidden = true
        
//        if self.webView.canGoBack {
//            print("Can go back")
//            self.webView.goBack()
//            self.webView.reload()
//        } else {
//            print("Can't go back")
//        }
        
        if(newLinkClicked){
            if(nextScreenHTML != nil){
                webView.loadHTMLString(nextScreenHTML!, baseURL: nil)
                newLinkClicked = false
                return
                
            }
        }
        
        if(notificationTile != nil ){
            
            
                        let storyBoard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
                        let notiFicationController = storyBoard.instantiateViewController(withIdentifier: "NotificationListController") as! NotificationListController
            
//                        notiFicationController.notifTitle = appdelegate.notificationTitle as String?
//                        appdelegate.notificationTitle=nil
                        //        webViewController.flag = "Cashless Hosp"
            
                        self.navigationController?.pushViewController(notiFicationController, animated: true)
            
        }
        else{
            appdelegate.isFromGuidline = false
               navigationController?.popViewController(animated: true)
        }
           }
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
    }
    func setActivityIndicator() {
        // Configure the background containerView for the indicator
        activityIndicatorContainer = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        activityIndicatorContainer.center.x = webView.center.x
        // Need to subtract 44 because WebKitView is pinned to SafeArea
        //   and we add the toolbar of height 44 programatically
        activityIndicatorContainer.center.y = webView.center.y - 44
        activityIndicatorContainer.backgroundColor = UIColor.black
        activityIndicatorContainer.alpha = 0.8
        activityIndicatorContainer.layer.cornerRadius = 10
      
        // Configure the activity indicator
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicatorContainer.addSubview(activityIndicator)
        webView.addSubview(activityIndicatorContainer)
        
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
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      self.showActivityIndicator(show: false)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      // Set the indicator everytime webView started loading
      self.setActivityIndicator()
      self.showActivityIndicator(show: true)
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
      self.showActivityIndicator(show: false)
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            print("link")
           
           // stringUrl?.removeSubrange(0..3)
            if(nextScreenHTML != nil){
            newLinkClicked = true;
            }
//            let url1 = navigationAction.request.url
//            webView.load(URLRequest(url: url1!))
            
            
           webView.load(navigationAction.request )
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
        print("no link")
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
