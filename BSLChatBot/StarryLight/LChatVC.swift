//
//  LChatVC.swift
//  BSLChatBot
//
//  Created by Shweta Singh on 02/02/22.
//  Copyright © 2022 Santosh. All rights reserved.
//





import UIKit
import Photos
import CoreLocation
import MessageUI
import Speech
import CoreData
import Firebase
import EventKit
import EventKitUI

class LChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,  UINavigationControllerDelegate,UICollectionViewDelegate ,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout ,UIPickerViewDelegate,UIPickerViewDataSource,UIScrollViewDelegate, SFSpeechRecognizerDelegate , SFSpeechRecognitionTaskDelegate , CalendarCellDelegate, TimeCellDelegate {
    
    @IBOutlet weak var notificationIcon: UIBarButtonItem!
    @IBOutlet weak var sosBttn: UIButton!
    
    @IBOutlet var inputBar: UIView!
    @IBOutlet weak var sendTextImage: UIImageView!
    @IBOutlet weak var sendAudioImage: UIImageView!
    
    @IBOutlet weak var textMessageView: UIView!
    @IBOutlet weak var audioMessageView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var SuggestionCellView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var inputPickerView: UIView!
    @IBOutlet weak var PickerView: UIPickerView!
    
    @IBOutlet weak var TextfiledContainerView: UIView!
    var setCurrentIndex:Int = 0;
    let storyBoardName = "SLChatBot"
    
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet var InputBarHeight: NSLayoutConstraint!
    @IBOutlet weak var FirstTimeCollectionView: UICollectionView!
    @IBOutlet var FirstTimeCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var TimeView: UIView!
    @IBOutlet weak var datepicker: UIDatePicker!
    
    @IBOutlet weak var itemBarCovidMenu: UIBarButtonItem!
    //var audioIdleTimer: Timer?
    var speechText : String?
    @IBOutlet weak var AudioButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var shadowPopUpView : UIView!
    var notificationUnreadCount = 0
    var newsNotificationUnreadCount = 0
    
    
    var preSelectedDates : Dictionary<String, [Date]> = [:]
    var delegate : UITableViewCell?
    var extraHeight : CGFloat = 0.0
    var CollectionvViewSize = CGSize.init(width: 0.0, height: 0.0)
    var textFromAlert = false
    var sosSucessText:String?
    var attributePopText:NSMutableAttributedString?
    var boldFontSize = 16.0
    
    let newsLetterString = "Newsletter"
    //Implement Speech Recognisation
    var speechRecognizer : SFSpeechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    var speechRecogniserEnable = false
    var swipableItemIndexRow:Int!
    var popUpView:SOSPopUp?
    var backPopUpView : UIView?
    var isSOSPressed=false
    var lbl_count = UILabel()
    var showNewsletterBadge = false
    
    var vSpinner : UIView?
    var activityIndicator : UIActivityIndicatorView?
    
    var longPress = UILongPressGestureRecognizer()
    
    var glowBttn = "SOSGlow"
    private let _itemsPerRow = 4
    private let _itemsPerColumn = 2
    private let _itemsPerPage = 4 * 2
    private let collectionViewHeight = 170
    
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var items = [Message]()
    var approvalIndexpaths:[IndexPath] = []
    var cancelServiceIndexpaths:[IndexPath]=[]
    let barHeight: CGFloat = 130
    
    //Static Custom Welcome Suggestions
    var welcomeSuggestions = [String]()
    var sosBttnShow = false;
    
    
    
    
    //MARK: ViewController lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        
        if(delegate.isFromPushNotification ){
            self.showSpinner(onView: self.view)
        }
        var option = ["Covid-19","Main Menu"]
        
        if(appdelegate.isFromGuidline){
            if(appdelegate.isFromGuidline){
                option = ["Covid-19","Main Menu"]
                appdelegate.isFromGuidline = false
            }
            
            let message:Message = Message.init(content: "hidden", owner: .receiver)
            message.options = option;
            message.mainoptions = false
            self.items.append(message)
            let indexPathForNewMessage = IndexPath.init(row: self.items.count - 1, section: 0)
            self.InsertRowsToTableView(indexPaths: [indexPathForNewMessage])
            
            if self.items.last?.mainoptions != nil {
                self.MakeBottomView((self.items.last?.mainoptions)!)
            }
            
        }
        
        self.inputBar.backgroundColor = UIColor.white
        self.inputBar.layer.shadowColor = UIColor.black.cgColor
        self.inputBar.layer.shadowOpacity = 0.2
        self.inputBar.layer.shadowOffset = CGSize.zero
        self.inputBar.layer.shadowRadius = 10
        self.inputBar.layer.masksToBounds = false
        self.inputBar.layer.shadowPath = UIBezierPath(rect: self.inputBar.bounds).cgPath
        
        let placeholderAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray ]
        let placeholderAttributedString = NSAttributedString(string:  "Type a message....", attributes: placeholderAttribute)
        self.inputTextField.attributedPlaceholder = placeholderAttributedString
        let buttonItemView = notificationIcon.value(forKey: "view") as? UIView
        
        // prospective specific UI updation
        itemBarCovidMenu.isEnabled = false
        // image for above removed from storyboard
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.hidesBottomBarWhenPushed = true
    }
    
    
    
    func showSpinner(onView : UIView) {
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        var ai = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            ai = UIActivityIndicatorView.init(style: .large)
        } else {
            // Fallback on earlier versions
            ai = UIActivityIndicatorView.init(style: .gray)
            
        }
        ai.center = spinnerView.center
        let label = UILabel(frame: CGRect(x: w / 2, y: h / 2 + 50, width: 200, height: 30))
        label.text = "Fetching Expresso..."
        label.textColor = .black
        label.center = CGPoint(x: w / 2, y: h / 2 + 50)
        label.textAlignment = .center
        
        ai.startAnimating()
        
        
        
        spinnerView.addSubview(ai)
        spinnerView.addSubview(label)
        
        onView.addSubview(spinnerView)
        
        self.vSpinner = spinnerView
        
        
    }
    
    func removeSpinner() {
        // self.activityIndicator!.stopAnimating()
        
        self.vSpinner?.removeFromSuperview()
        self.vSpinner = nil
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        guard NetReachability.isConnectedToNetwork() else {
            SwAlert.showNoActionAlert(Title, message: internetErrorMessage, buttonTitle: keyOK)
            return
        }
        
        //            if(appdelegate.isFromPushNotification ){
        //            self.showSpinner(onView: self.view)
        //            }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.ReceivedNotification(notification:)), name: Notification.Name("NotificationAdded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.ReceivedNewsNotification(notification:)), name: Notification.Name("NewsletterAdded"), object: nil)
        
        // request for network data for notification update
        loadNotificationCount()
        
        
        retrieveNewsNotificationCount()
        // update notification count on header
        retrieveNotificationCount()
        
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()
        
        sosBttn.isHidden = !sosBttnShow
        NotificationCenter.default.addObserver(self, selector: #selector(LChatVC.showKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        retrieveNotificationCount()
        lbl_count = UILabel(frame: CGRect(x: screenSize.width-65, y: 0, width: 22, height: 22))
        lbl_count.backgroundColor = UIColor.red
        lbl_count.textColor = UIColor.white
        let font = UIFont(name: "Montserrat-SemiBold", size: 12)
        lbl_count.font = font
        lbl_count.layer.cornerRadius = lbl_count.frame.width/2
        lbl_count.textAlignment = .center
        lbl_count.layer.masksToBounds = true
        lbl_count.text = String(notificationUnreadCount)
        if(notificationUnreadCount==0){
            lbl_count.isHidden=true
        }
        else{
            lbl_count.isHidden=false
        }
        self.navigationController?.navigationBar.addSubview(lbl_count)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        lbl_count.removeFromSuperview()
        if(self.vSpinner != nil){
            self.removeSpinner()
        }
        pageControl.isHidden = false
        
    }
    
    @IBAction func sosBttnClicked(_ sender: Any) {
        backPopUpView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        // backPopUpView?.alpha = 0
        backPopUpView?.backgroundColor = UIColor.black
        backPopUpView?.alpha = 0.3
        self.view.addSubview(backPopUpView!)
        popUpView =   Bundle.main.loadNibNamed("SOSPopUp", owner: nil, options: nil)?[0] as? SOSPopUp
        popUpView?.frame =  CGRect(x: 0, y: 0, width: screenSize.width/1.3, height: screenSize.height/2.8)
        
        popUpView?.crossBttn.addTarget(self, action: #selector(self.crossPressed), for: .touchUpInside)
        popUpView?.sosBttn.addTarget(self, action: #selector(self.glow), for: .touchUpInside)
        popUpView?.layer.cornerRadius = 20.0
        //var main_string = "Are you safe? Do you need urgent help of any kind? Have you run out of cash? Are you unwell and living alone? If so, please tap and hold SOS to send alert."
        var main_string = "Are you safe? Do you need urgent help of any kind? If so, please TAP and HOLD SOS button below to send an alert."
        
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.callSOS))
        longPress.minimumPressDuration = 1
        popUpView?.sosBttn.addGestureRecognizer(longPress)
        
        popUpView?.sosBttn.adjustsImageWhenHighlighted=false
        
        // [btn setImage:[UIImage imageNamed:@"your image.png"] forState:UIControlStateSelected];
        
        let font = UIFont(name: "Montserrat-SemiBold", size: CGFloat(boldFontSize))
        let string_to_color1 = "safe"
        let range1 = (main_string as NSString).range(of: string_to_color1)
        
        attributePopText = NSMutableAttributedString.init(string: main_string)
        attributePopText?.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red , range: range1)
        attributePopText?.addAttribute(NSAttributedString.Key.font, value: font, range: range1)
        
        var string_to_color2 = "help of any kind"
        var range2 = (main_string as NSString).range(of: string_to_color2)
        
        
        attributePopText?.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red , range: range2)
        attributePopText?.addAttribute(NSAttributedString.Key.font, value: font , range: range2)
        
        ////
        let string_to_color3 = "TAP and HOLD"
        let range3 = (main_string as NSString).range(of: string_to_color3)
        
        
        attributePopText?.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 35/255, green: 121/255, blue: 185/255, alpha: 1) , range: range3)
        attributePopText?.addAttribute(NSAttributedString.Key.font, value: font , range: range3)
        //        attributePopText?.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: range3)
        
        
        
        ///
        
        let string_to_bold = "Starry"
        let range4 = (main_string as NSString).range(of: string_to_bold)
        attributePopText?.addAttribute(NSAttributedString.Key.font, value: font , range: range4)
        
        attributePopText?.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black , range: range4)
        
        
        
        let string_to_bold1 = "\nStarry"
        let range5 = (main_string as NSString).range(of: string_to_bold1)
        attributePopText?.addAttribute(NSAttributedString.Key.font, value: font , range: range5)
        //
        attributePopText?.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black , range: range5)
        //
        string_to_color2 = "unwell and living alone"
        range2 = (main_string as NSString).range(of: string_to_color2)
        
        
        attributePopText?.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red , range: range2)
        attributePopText?.addAttribute(NSAttributedString.Key.font, value: font , range: range2)
        //
        
        
        //
        popUpView?.txtLbl.attributedText = attributePopText
        
        shadowPopUpView = UIView(frame: popUpView!.frame)
        shadowPopUpView.layer.shadowColor = UIColor(red: 236/255, green: 54/255, blue: 58/255, alpha: 1).cgColor
        shadowPopUpView.layer.shadowOffset = CGSize.zero
        shadowPopUpView.layer.shadowOpacity = 0.5
        shadowPopUpView.layer.shadowRadius = 15
        shadowPopUpView.center.y = self.view.center.y
        shadowPopUpView.center.x = self.view.center.x
        shadowPopUpView.addSubview(popUpView!)
        
        self.view.addSubview(shadowPopUpView)
        // self.view.addSubview(popUpView!)
        
        
    }
    
    @objc func glow(){
        let img = UIImage(named: glowBttn)
        popUpView?.sosBttn.setBackgroundImage(img, for: .highlighted)
        //         popUpView?.sosBttn.setBackgroundImage(img, for: .selected)
        popUpView?.sosBttn.setBackgroundImage(img, for: .normal)
    }
    @objc func callSOS(){
        let img = UIImage(named: glowBttn)
        popUpView?.sosBttn.removeGestureRecognizer(longPress)
        popUpView?.sosBttn.setBackgroundImage(img, for: .normal)
        if(!isSOSPressed){
            isSOSPressed=true
            
            let user = userDefaults.value(forKey: "user") as? [String: Any]
            let apiDict = ["empID":"\(user!["empID"] ?? "")"]
            //self.popUpView?.sosBttn.isUserInteractionEnabled=false
            
            ApprovalManager.shared.sendSOSRequest(parameters: apiDict, completion: { (responseDictionary  )  in
                
                guard let messagesString: Bool = responseDictionary["success"] as? Bool else {
                    self.isSOSPressed = false
                    
                    return
                    
                }
                
                self.sosSucessText = responseDictionary["textResponse"] as! String
                
                
                DispatchQueue.main.async {
                    self.isSOSPressed = false
                    self.sosSucessText = responseDictionary["textResponse"] as! String
                    var str = "\n\n"
                    str.append(self.sosSucessText!)
                    let myAttrString = NSAttributedString(string: str)
                    self.attributePopText?.append(myAttrString)
                    self.popUpView?.txtLbl.attributedText = self.attributePopText
                    //self.popUpView?.sosBttn.isHidden=true
                    //self.popUpView?.sosBttn.isUserInteractionEnabled=true
                    
                }
            })
        }
    }
    
    
    @objc func crossPressed()  {
        backPopUpView!.removeFromSuperview()
        //self.popUpView?.sosBttn.isUserInteractionEnabled=true
        //isSOSPressed = false
        shadowPopUpView.removeFromSuperview()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //      fatalError()
        self.SetNavigationBar()
        
        
        
        self.customization()
        self.composeWelcomeMessage()
        pageControl.isHidden = true
        shadowView.isHidden = true
        pageControl.hidesForSinglePage = true
        
        //populating the demo suggestions
        welcomeSuggestions = ["Hello" , "Hi" , "GooD morning", "ola" , "Who Made You" , "Holiday"]
        inputTextField.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        SetAudioandTextView(sender: inputTextField)
        
        self.changeCollectionViewVisibilityStatus(shouldShow: false)
        
        //Add Gestures
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)));
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right;
        FirstTimeCollectionView.addGestureRecognizer(swipeRight);
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)));
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left;
        FirstTimeCollectionView.addGestureRecognizer(swipeLeft);
        
        
        
    }
    
    func loadNotificationCount(){
        ApprovalManager.shared.getNotification( completion: { (responseDictionary  )  in
            var arrayNotification = NSMutableArray()
            print("Responcse for Notification \(responseDictionary)")
            arrayNotification = responseDictionary as! NSMutableArray
            if(arrayNotification.count>0){
                DispatchQueue.main.async {
                    NotificationCenter.default.addObserver(self, selector: #selector(self.ReceivedNotification(notification:)), name: Notification.Name("NotificationAdded"), object: nil)
                    appdelegate.createProspNotificationTbl(array: arrayNotification)
                    appdelegate.deleteProspNotificationExtraData(array: arrayNotification)
                    appdelegate.retrieveProspNotificationData()
                    
                }}
        })
    }
    
    //MARK:- Handle Swipe Gesture Recognizer.
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        print(gesture)
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                if setCurrentIndex > 0 {
                    setCurrentIndex -= 1
                    
                    let transition:CATransition! = CATransition();
                    transition.duration = 0.5;
                    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut);
                    transition.type = CATransitionType.push;
                    transition.subtype = CATransitionSubtype.fromLeft;
                    FirstTimeCollectionView.layer.add(transition, forKey: nil);
                    FirstTimeCollectionView.contentOffset.x = (CGFloat(setCurrentIndex) * self.view.frame.size.width)
                    
                    pageControl.currentPage = setCurrentIndex;
                }
                
                
            case UISwipeGestureRecognizer.Direction.left:
                
                if setCurrentIndex < pageControl.numberOfPages - 1 {
                    setCurrentIndex += 1;
                    
                    let transition:CATransition! = CATransition();
                    transition.duration = 0.5;
                    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut);
                    transition.type = CATransitionType.push;
                    transition.subtype = CATransitionSubtype.fromRight;
                    FirstTimeCollectionView.layer.add(transition, forKey: nil);
                    
                    FirstTimeCollectionView.contentOffset.x = (CGFloat(setCurrentIndex) * FirstTimeCollectionView.frame.size.width)
                    pageControl.currentPage = setCurrentIndex;
                    
                }
            default:
                break
            }
        }
        print(setCurrentIndex)
        
        //sosBttn.isHidden = setCurrentIndex == 0 ? false : true
        //        inputBar.layoutSubviews()
        //        inputBar.layoutIfNeeded()
        
    }
    
    @objc func ReceivedNotification(notification: Notification) {
        retrieveNotificationCount()
    }
    
    @objc func ReceivedNewsNotification(notification: Notification) {
        retrieveNewsNotificationCount()
    }
    //MARK: Methods
    func customization() {
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    
    
    
    
    
    // Hides current viewcontroller
    @objc func dismissSelf() {
        if let navController = self.navigationController {
            self.Lmenuscreen()
        }
    }
    
    
    func composeMessage(type: MessageType, visibilty : MessageShow , content: Any , approvaltype : Bool , approvalText :  String)  {
        
        guard NetReachability.isConnectedToNetwork() else {
            SwAlert.showNoActionAlert(Title, message: internetErrorMessage, buttonTitle: keyOK)
            return
        }
        
        
        self.approvalIndexpaths.removeAll()
        // self.inputTextField.placeholder = "Starry is typing..."
        let placeholderAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray ]
        let placeholderAttributedString = NSAttributedString(string:  "Starry is typing...", attributes: placeholderAttribute)
        self.inputTextField.attributedPlaceholder = placeholderAttributedString
        
        
        
        
        var message : Message?
        var approvalDict = [String:Any]()
        
        if((content as! String).contains("GUIDELINES_HTML:")){
            
            message = Message.init(type: type, content: approvalText, owner: .sender, timestamp: Int(Date().timeIntervalSince1970), isRead: false)
            approvalDict = ["Content" : content]
        }
        
        else{
            changeCollectionViewVisibilityStatus(shouldShow: false)
            if approvaltype == true {
                message = Message.init(type: type, content: approvalText, owner: .sender, timestamp: Int(Date().timeIntervalSince1970), isRead: false)
                approvalDict = ["Content" : content]
            } else {
                message = Message.init(type: type, content: content, owner: .sender, timestamp: Int(Date().timeIntervalSince1970), isRead: false)
            }
        }
        
        if approvalText == "isCancel"{
            approvalDict = ["ticketNumber" : content]
        }
        
        if visibilty == .yes {
            self.items.append(message!)
            let indexPathForNewMessage = IndexPath.init(row: self.items.count - 1, section: 0)
            self.InsertRowsToTableView(indexPaths: [indexPathForNewMessage])
        }
        
        MessageManager.shared.send(message: message!, visibility: visibilty, toID: "UserId", approvalDict: approvalDict, completion: {(success, messages) in
            
            let placeholderAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray ]
            let placeholderAttributedString = NSAttributedString(string:  "Type a message...", attributes: placeholderAttribute)
            self.inputTextField.attributedPlaceholder = placeholderAttributedString
            
            if (success) {
                
                
                var indexPaths: [IndexPath]? = [IndexPath]()
                
                if(messages[0].type == .next_screen){
                    
                    let storyBoard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
                    let notiFicationController = storyBoard.instantiateViewController(withIdentifier: "NotificationListController") as! NotificationListController
                    notiFicationController.isFromNextScreen = true
                    notiFicationController.nextScreenList = messages[0].nextScreenList
                    
                    self.navigationController?.pushViewController(notiFicationController, animated: true)
                    return
                }
                
                for msg in messages {
                    //append
                    self.items.append(msg)
                    let indexPathForNewMessage = IndexPath.init(row: self.items.count - 1, section: 0)
                    indexPaths?.append(indexPathForNewMessage)
                }
                
                self.MakeTextFieldEnable()
                
                
                if self.items.last?.type == .picker {
                    self.inputBar.isHidden = true
                    self.textFromAlert = false
                    self.TextfiledContainerView.isUserInteractionEnabled = true
                    self.PickerView.reloadAllComponents()
                    self.inputTextField.inputView = self.inputPickerView
                    self.inputTextField.becomeFirstResponder()
                    self.changeCollectionViewVisibilityStatus(shouldShow: false)
                } else {
                    self.inputBar.isHidden = false
                    //append
                    if self.items.last?.mainoptions != nil {
                        self.MakeBottomView((self.items.last?.mainoptions)!)
                    }
                    
                }
                
                if let indexPathToInsert = indexPaths, let _ = indexPaths?.count {
                    if self.items.last?.type == .approvals {
                        print(indexPathToInsert)
                        self.approvalIndexpaths.append(contentsOf: indexPathToInsert)
                        var scrollIndex = 0
                        
                        if indexPathToInsert.count > 2 {
                            scrollIndex = 2
                        } else if indexPathToInsert.count >= 1 {
                            scrollIndex = 1
                        }
                        
                        self.ScrollApprovalRowsToTableView(indexPaths: indexPathToInsert, scrollItem: (indexPaths?[scrollIndex])!)
                        
                    } else {
                        self.InsertRowsToTableView(indexPaths: indexPathToInsert)
                    }
                    
                }
            } else {
                if let errorMessage = messages.first,
                   let errorString = errorMessage.content as? String {
                    SwAlert.showNoActionAlert(Title, message: errorString, buttonTitle: keyOK)
                }
            }
        })
    }
    
    
    
    
    func ImplementTimer() {
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: {_ in
            if self.tableView.contentOffset.y  <= (self.tableView.contentSize.height - self.tableView.frame.size.height) {
                self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
                self.tableView.setNeedsLayout()
            }
        })
    }
    
    
    
    
    
    func InsertRowsToTableView(indexPaths : [IndexPath]) {
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: indexPaths, with: .none)
        self.tableView.endUpdates()
        
        self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0),
                                   at: .bottom,
                                   animated: true)
    }
    
    
    func ScrollApprovalRowsToTableView(indexPaths : [IndexPath] , scrollItem : IndexPath) {
        
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: indexPaths, with: .none)
        self.tableView.endUpdates()
        
        self.tableView.scrollToRow(at: scrollItem ,
                                   at: .none,
                                   animated: true)
    }
    
    
    func InsertApprovalRowsToTableView(indexPaths : [IndexPath]) {
        
        
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: indexPaths, with: .none)
        self.tableView.endUpdates()
        
        self.tableView.scrollToRow(at: indexPaths.first!,
                                   at: .none,
                                   animated: true)
    }
    
    
    
    func RemoveRowsToTableView(indexPaths : [IndexPath]) {
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: indexPaths, with: .none)
        self.tableView.endUpdates()
    }
    
    
    
    func composeWelcomeMessage() {
        
        guard NetReachability.isConnectedToNetwork() else {
            SwAlert.showNoActionAlert(Title, message: internetErrorMessage, buttonTitle: keyOK)
            return
        }
        
        changeCollectionViewVisibilityStatus(shouldShow: false)
        
        let message = Message.init(type: .text, content: "Main Menu", owner: .sender, timestamp: Int(Date().timeIntervalSince1970), isRead: false)
        
        MessageManager.shared.send(message: message, visibility: .yes, toID: "UserId", approvalDict: [String:Any](), completion: {(success, messages) in
            if (success) {
                var newMessages = messages[self.items.count..<messages.count]
                var indexPaths: [IndexPath]? = [IndexPath]()
                
                while(newMessages.count > 0) {
                    let newMessage = newMessages.first!
                    self.items.append(newMessage)
                    let indexPathForNewMessage = IndexPath.init(row: 0, section: 0)
                    indexPaths?.append(indexPathForNewMessage)
                    newMessages.removeFirst()
                }
                
                self.MakeTextFieldEnable()
                
                if self.items.last?.mainoptions != nil {
                    let deadlineTime = DispatchTime.now() + .seconds(1)
                    
                    self.MakeBottomView((self.items.last?.mainoptions)!)
                    
                }
                
                if let indexPathToInsert = indexPaths,
                   let _ = indexPaths?.count
                {
                    self.InsertRowsToTableView(indexPaths: indexPathToInsert)
                }
                
            } else {
                //handle error
            }
        })
    }
    
    
    func composeRejectServiceTicket(type: MessageType, visibilty : MessageShow , position : IndexPath , apiContent: Any , msg : Message )  {
        
        guard NetReachability.isConnectedToNetwork() else {
            SwAlert.showNoActionAlert(Title, message: internetErrorMessage, buttonTitle: keyOK)
            return
        }
        
        self.items.remove(at: position.row)
        self.RemoveRowsToTableView(indexPaths: [position])
        
        if let findIndex = self.approvalIndexpaths.index(of: position) {
            print("Hellooo" , findIndex)
            self.approvalIndexpaths.remove(at: findIndex)
        }
        
        // self.inputTextField.placeholder = "Starry is typing..."
        let placeholderAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray ]
        let placeholderAttributedString = NSAttributedString(string:  "Starry is typing...", attributes: placeholderAttribute)
        self.inputTextField.attributedPlaceholder = placeholderAttributedString
        
        
        MessageManager.shared.sendCancelResponse(setmessage: msg, visibility: visibilty, position: position, toID: "UserId", approvalDict: apiContent as! [String : Any], completion: {(success, messages , place , error ) in
            
            //  self.inputTextField.placeholder = "Type a message..."
            let placeholderAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray ]
            let placeholderAttributedString = NSAttributedString(string:  "Type a message...", attributes: placeholderAttribute)
            self.inputTextField.attributedPlaceholder = placeholderAttributedString
            
            
            if !(success as! Bool) {
                self.AppendMessages(place, messages)
                self.approvalIndexpaths.append(place)
                self.CheckAllApproveButtonFunction(numbers:self.approvalIndexpaths)
                
            } else if (success as! Bool) {
                self.CheckAllApproveButtonFunction(numbers:self.approvalIndexpaths)
            }
            
        })
        
    }
    
    
    
    func composeApprovalMessage(type: MessageType, visibilty : MessageShow , position : IndexPath , apiContent: Any , msg : Message )  {
        
        guard NetReachability.isConnectedToNetwork() else {
            SwAlert.showNoActionAlert(Title, message: internetErrorMessage, buttonTitle: keyOK)
            return
        }
        
        self.items.remove(at: position.row)
        self.RemoveRowsToTableView(indexPaths: [position])
        
        if let findIndex = self.approvalIndexpaths.index(of: position) {
            self.approvalIndexpaths.remove(at: findIndex)
        }
        
        // self.inputTextField.placeholder = "Starry is typing..."
        let placeholderAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray ]
        let placeholderAttributedString = NSAttributedString(string:  "Starry is typing...", attributes: placeholderAttribute)
        self.inputTextField.attributedPlaceholder = placeholderAttributedString
        
        
        MessageManager.shared.sendApprovalResponse(setmessage: msg, visibility: visibilty, position: position, toID: "UserId", approvalDict: apiContent as! [String : Any], completion: {(success, messages , place , error ) in
            
            // self.inputTextField.placeholder = "Type a message..."
            let placeholderAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray ]
            let placeholderAttributedString = NSAttributedString(string:  "Type a message...", attributes: placeholderAttribute)
            self.inputTextField.attributedPlaceholder = placeholderAttributedString
            
            
            if !(success as! Bool) {
                self.AppendMessages(place, messages)
                self.approvalIndexpaths.append(place)
                self.CheckAllApproveButtonFunction(numbers:self.approvalIndexpaths)
                
            } else if (success as! Bool) {
                self.CheckAllApproveButtonFunction(numbers:self.approvalIndexpaths)
            }
            
        })
        
    }
    
    
    
    func CheckAllApproveButtonFunction(numbers: [IndexPath]) {
        
        guard numbers.count > 0 else {
            return
        }
        
        guard self.items.count > 2 else {
            return
        }
        
        
        let range = self.items.index(self.items.endIndex, offsetBy: -2) ..< self.items.endIndex
        let lasttwoarray = self.items[range]
        
        
        
        let approvalcount = lasttwoarray.filter({$0.type == .approvals})
        let allapprovalcount = lasttwoarray.filter({$0.type == .allApprove})
        
        
        if approvalcount.count == 1 && allapprovalcount.count != 0 {
            
            if  self.items.index(of: allapprovalcount.first!) != nil {
                let removeMsg = self.items.index(of: allapprovalcount.first!)
                self.items.remove(at: removeMsg!)
                let indexPathForoldMessage = IndexPath.init(row: removeMsg!, section: 0)
                self.tableView.deleteRows(at:[indexPathForoldMessage] , with: .none)
            }
        }
        
        
        
        if approvalcount.count == 0 && allapprovalcount.count == 0 {
            let newMessage = Message.allapprovedMessage()
            self.items.append(newMessage)
            let indexPathForNewMessage = IndexPath.init(row: self.items.count - 1, section: 0)
            self.InsertApprovalRowsToTableView(indexPaths: [indexPathForNewMessage])
        }
        
        
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        dismissSelf()
    }
    
    //MARK: click on notificatiion
    @IBAction func clickOnNotication(_ sender: Any) {
        
        print("noti clicked")
        
        // pre check for propesctive user status
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let lu = LightUtility.getLightUser()
        if lu != nil{
            delegate.checkProspectiveUserStatus(mobileNumber: lu!.mobile){isActive in
                if !isActive{
                    DispatchQueue.main.async(execute: { () -> Void in
                        LoginModel.sharedInstance.Logout()
                    })
                    return
                }
            }
        }
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "SLChatBot", bundle: nil)
        let notiFicationController = storyBoard.instantiateViewController(withIdentifier: "NotificationListControllerlight") as! LNotificationListController
        //        webViewController.flag = "Cashless Hosp"
        self.navigationController?.pushViewController(notiFicationController, animated: true)
        
    }
    //MARK: -Initiate Chat
    @IBAction func ClickonHomeIcon(_ sender: Any) {
        disableSpeech(false)
        shadowView.isHidden = true
        //sosBttn.isHidden = true
        pageControl.isHidden = true
        
        FirstTimeCollectionView.contentOffset.x = 0
        
        setCurrentIndex = 0
        
        if self.inputTextField.inputView == inputPickerView {
            self.inputTextField.inputView = nil
        }
        
        self.MakeTextFieldEnable()
        
        // initial check
        // pre check for propesctive user status
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let lu = LightUtility.getLightUser()
        if lu != nil{
            delegate.checkProspectiveUserStatus(mobileNumber: lu!.mobile){isActive in
                if !isActive{
                    DispatchQueue.main.async(execute: { () -> Void in
                        LoginModel.sharedInstance.Logout()
                    })
                    return
                }
            }
        }
        
        self.composeMessage(type: .text, visibilty: .yes, content: "Main Menu", approvaltype: false, approvalText: "")
        
        
    }
    
    
    //MARK: -Sent Text Query to Server
    @IBAction func sendMessage(_ sender: Any) {
        
        if self.inputTextField.text!.count > 0 && ValidationClass.Shared.isBlank(self.inputTextField!) == false {
            
            if self.items.last?.type == .reject_reason {
                
                self.composeMessage(type: .text, visibilty: .yes , content: "REJECT_REASON:" + self.inputTextField.text!, approvaltype: true, approvalText: self.inputTextField.text!)
                
            }
            
            else if self.items.last?.type == .hr_query {
                
                //  self.composeMessage(type: .text, visibilty: .yes , content: "HR_QUERY:" + self.inputTextField.text!, approvaltype: true, approvalText: self.inputTextField.text!)
                
                
                self.composeMessage(type: .text, visibilty: .yes, content: "HR_QUERY:" + self.inputTextField.text!, approvaltype: true, approvalText: self.inputTextField.text!)
                
                
            }
            else if self.items.last?.type == .zoom_topic {
                
                self.composeMessage(type: .text, visibilty: .yes , content: "ZOOM_TOPIC:" + self.inputTextField.text!, approvaltype: true, approvalText: self.inputTextField.text!)
                
            }
            else {
                
                self.composeMessage(type: .text, visibilty: .yes, content: self.inputTextField.text!, approvaltype: false, approvalText: "")
                
            }
            
            SetTextFieldEmpty()
        }
        else{
            
        }
        
    }
    
    
    //MARK: -SpeechRecognisationDelegate
    @IBAction func sendAudioMessage(_ sender: UIButton) {
        
        
        sendAudioImage.image = #imageLiteral(resourceName: "voice_active")
        self.speechRecogniserEnable = true
        self.AudioButton.isEnabled = false
        self.inputTextField.isEnabled = false
        self.speechToTextConversion()
        
    }
    
    func SendAudioRequest(_ speech : String ) {
        self.speechText = ""
        self.inputTextField.text = ""
        self.sendAudioImage.image = #imageLiteral(resourceName: "voice_normal")
        self.composeMessage(type: .text, visibilty: .yes, content: speech , approvaltype: false, approvalText: "")
    }
    
    
    func speechToTextConversion() {
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // The callback may not be called on the main thread. Add an
            // operation to the main queue to update the record button's state.
            OperationQueue.main.addOperation {
                var alertTitle = ""
                var alertMsg = ""
                
                switch authStatus {
                case .authorized:
                    do {
                        try self.startRecording()
                    } catch {
                        alertTitle = "Recorder Error"
                        alertMsg = "There was a problem starting the speech recorder"
                    }
                    
                case .denied:
                    alertTitle = "Speech recognizer not allowed"
                    alertMsg = "You enable the recgnizer in Settings"
                    
                case .restricted, .notDetermined:
                    alertTitle = "Could not start the speech recognizer"
                    alertMsg = "Check your internect connection and try again"
                    
                }
                
                if alertTitle != "" {
                    SwAlert.showNoActionAlert(alertTitle, message: alertMsg, buttonTitle: "OK")
                }
            }
        }
    }
    
    
    
    //MARK: Stop Speech Recogniser
    @objc func disableSpeech(_ check : Bool ) {
        
        DispatchQueue.main.async {
            
            self.AudioButton.isEnabled = true
            self.inputTextField.isEnabled = true
            self.SetAudioandTextView(sender: self.inputTextField)
            self.speechRecogniserEnable = false
            
            if check == false {
                
                if self.audioEngine.isRunning {
                    self.audioEngine.stop()
                    if self.recognitionTask != nil {
                        self.recognitionTask?.cancel()
                        self.recognitionTask = nil
                    }
                    self.recognitionRequest?.endAudio()
                    self.audioEngine.inputNode.removeTap(onBus: 0)
                    self.speechText = ""
                }
            } else {
                
                self.audioEngine.stop()
                
                if self.recognitionTask != nil {
                    self.recognitionTask?.cancel()
                    self.recognitionTask = nil
                }
                
                self.recognitionRequest?.endAudio()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                
                
                let speech =  self.speechText ?? ""
                guard speech != "" || speech.isEmpty == false   else {
                    //  self.inputTextField.placeholder = "Type a message..."
                    let placeholderAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray ]
                    let placeholderAttributedString = NSAttributedString(string:  "Type a message...", attributes: placeholderAttribute)
                    self.inputTextField.attributedPlaceholder = placeholderAttributedString
                    
                    return
                }
                
                self.SendAudioRequest(self.speechText ?? "")
                
            }
        }
        
    }
    
    
    
    
    //MARK: Enable Speech Recogniser
    func startRecording() {
        
        if !audioEngine.isRunning {
            
            var audioIdleTimer: Timer?
            audioIdleTimer?.invalidate()
            
            
            if(!self.AudioButton.isEnabled) {
                audioIdleTimer = Timer.scheduledTimer(withTimeInterval: 3.0 , repeats: false, block: { [weak self] timer in
                    //Do whatever needs to be done when the timer expires
                    
                    audioIdleTimer?.invalidate()
                    
                    if(!(self?.AudioButton.isEnabled)!) {
                        self?.disableSpeech(true)
                    }
                })
            }
            
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSession.Category.record)
                try audioSession.setMode(AVAudioSession.Mode.measurement)
                try audioSession.setActive(true)
            }  catch {
                print("audioSession properties weren't set because of an error.")
            }
            
            
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            let inputNode = audioEngine.inputNode
            
            guard let recognitionRequest = recognitionRequest else {
                fatalError("Unable to create the recognition request")
            }
            
            // Configure request so that results are returned before audio recording is finished
            recognitionRequest.shouldReportPartialResults = true
            
            // A recognition task is used for speech recognition sessions
            // A reference for the task is saved so it can be cancelled
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                
                self.speechText = result?.transcriptions.last?.formattedString
                audioIdleTimer!.invalidate()
                
                print(self.speechText as Any)
                
                if(!self.AudioButton.isEnabled) {
                    audioIdleTimer = Timer.scheduledTimer(withTimeInterval: 1.5 , repeats: false, block: {[weak self] timer in
                        
                        audioIdleTimer!.invalidate()
                        if(!(self?.AudioButton.isEnabled)!) {
                            self?.disableSpeech(true)
                        }
                    })
                }
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.recognitionRequest?.append(buffer)
            }
            
            print("Begin recording")
            audioEngine.prepare()
            
            do {
                try audioEngine.start()
            } catch {
                print("audioEngine couldn't start because of an error.")
            }
            
            inputTextField.placeholder = "Starry is listening"
            
        }
        
    }
    
    
    
    
    
    func MakeTextFieldEnable()  {
        
        if self.items.last?.options?.count == nil || self.items.last?.options?.count == 0 {
            
            if self.items.last?.type != MessageType.none && self.items.last?.type != MessageType.text && self.items.last?.type != MessageType.hr_query && self.items.last?.type != MessageType.zoom_topic{
                
                self.inputTextField.resignFirstResponder()
                self.TextfiledContainerView.alpha = 0.7
                self.TextfiledContainerView.isUserInteractionEnabled = false
                self.blueButton.tintColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
            } else {
                
                self.TextfiledContainerView.alpha = 1.0
                self.TextfiledContainerView.isUserInteractionEnabled = true
                self.blueButton.tintColor = #colorLiteral(red: 0.03529411765, green: 0.4431372549, blue: 0.7294117647, alpha: 1)
            }
            
        } else {
            
            self.inputTextField.resignFirstResponder()
            self.TextfiledContainerView.alpha = 0.7
            self.TextfiledContainerView.isUserInteractionEnabled = false
            self.blueButton.tintColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
            
        }
        
    }
    
    
    func SetTextFieldEmpty()  {
        self.inputTextField.text = ""
        SetAudioandTextView(sender: self.inputTextField)
    }
    
    
    
    //MARK: NotificationCenter handlers
    @objc func showKeyboard(notification: Notification) {
        
        if let frame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let height = frame.cgRectValue.height
            self.bottomConstraint.constant = height
            self.inputBar.setNeedsLayout()
            if textFromAlert == false {
                self.ImplementTimer()
            }
        }
        
    }
    
    
    
    //MARK: Collection view Delegates SuggestionCell
    //MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionView.collectionViewLayout.invalidateLayout()
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // to make the blanks cells in the page to scroll entirely
        if collectionView == FirstTimeCollectionView{
            return virtualCount()
        }
        return self.items.last?.options?.count ?? 0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == FirstTimeCollectionView{
            if let index = _tryGetDataIndex(indexPath: indexPath){
                
                var cell : SuggestionCollectionViewCell
                var identifier = ""
                sosBttn.isHidden=true
                
                if collectionView == FirstTimeCollectionView {
                    identifier = "SuggestionCell"
                    //sosBttn.isHidden = setCurrentIndex == 0 ? false : true
                    //sosBttnShow = !sosBttn.isHidden
                    //                sosBttn.isHidden=false
                    //  sosBttnShow = true
                    
                }else if collectionView == SuggestionCellView {
                    identifier = "secondSuggestionCell"
                    //sosBttnShow = false
                }
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath as IndexPath) as! SuggestionCollectionViewCell
                
                
                let receivedText = self.items.last?.options?[index] as? String
                
                
                if( receivedText != nil && (receivedText?.contains("|"))!){
                    let splitStringArr = receivedText?.components(separatedBy: "|")
                    if(splitStringArr!.count>0){
                        cell.project = splitStringArr![0]
                    }
                }
                else{
                    cell.project = self.items.last?.options?[index] as? String
                }
                
                if(collectionView == FirstTimeCollectionView && cell.SuggestionLabel.text == "Volympics"){
                    //cell.SuggestionLabel.textColor = UIColor(red: 250/255, green: 166/255, blue: 44/255, alpha: 1)
                    let font = UIFont(name: "Montserrat-Regular", size: 10)
                    cell.SuggestionLabel.font = font
                }
                
                else if (collectionView == FirstTimeCollectionView){
                    if(  (cell.SuggestionLabel.text?.contains("Broadcast"))!){
                        let img = UIImage.init(named: "broadcast")
                        cell.cellImage.image = img
                    }
                    cell.SuggestionLabel.textColor = UIColor.init(hexString: "#01426F")
                    
                    let font = UIFont(name: "Montserrat-Regular", size: 10)
                    cell.SuggestionLabel.font = font
                    //Montserrat-Medium 14.0
                    
                    if(  (cell.SuggestionLabel.text?.contains("Expresso"))!)
                    {
                        cell.badgeView.isHidden = !(self.newsNotificationUnreadCount > 0)
                        cell.badgeCount.text = String(self.newsNotificationUnreadCount)
                        //light user spesific setting
                        let img = UIImage.init(named: "lexpresso")
                        cell.cellImage.image = img
                        
                    }
                    else{
                        cell.badgeView.isHidden = true
                    }
                    if(  (cell.SuggestionLabel.text?.contains("faq"))!)
                    {
                        //light user spesific setting
                        let img = UIImage.init(named: "faq")
                        cell.cellImage.image = img
                    }
                    
                    if(  (cell.SuggestionLabel.text?.contains("My Buddy"))!)
                    {
                        //light user spesific setting
                        let img = UIImage.init(named: "zoom")
                        cell.cellImage.image = img
                    }
                    if(  (cell.SuggestionLabel.text?.contains("Find Broker"))!)
                    {
                        //light user spesific setting
                        let img = UIImage.init(named: "findbroker")
                        cell.cellImage.image = img
                    }
                    if(  (cell.SuggestionLabel.text?.contains("My HR"))!)
                    {
                        //light user spesific setting
                        let img = UIImage.init(named: "myhr")
                        cell.cellImage.image = img
                    }
                    
                    if(  (cell.SuggestionLabel.text?.contains("GST"))!)
                    {
                        let img = UIImage.init(named: "gst")
                        cell.cellImage.image = img
                        
                        
                    }
                    if(  (cell.SuggestionLabel.text?.contains("Mr./ Ms. Blue Star"))!)
                    {
                        let img = UIImage.init(named: "MrBluestar")
                        cell.cellImage.image = img
                        
                        
                    }
                    if(  (cell.SuggestionLabel.text?.contains("Work Schedule & Leave"))!)
                    {
                        let img = UIImage.init(named: "work schedule & leave")
                        cell.cellImage.image = img
                    }
                }
                
                return cell
            }else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell-Holder", for: indexPath)
            }
        }
        else{
            var cell : SuggestionCollectionViewCell
            var identifier = ""
            //sosBttn.isHidden=true
            
            identifier = "secondSuggestionCell"
            //sosBttnShow = false
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath as IndexPath) as! SuggestionCollectionViewCell
            cell.SuggestionLabel.textColor = UIColor.init(hexString: "#01426F")
            cell.Border.backgroundColor =  UIColor.clear
            let font = UIFont(name: "Montserrat-Medium", size: 14)
            cell.SuggestionLabel.font = font
            
            
            let receivedText = self.items.last?.options?[indexPath.item] as? String
            
            
            if( receivedText != nil && (receivedText?.contains("|"))!){
                let splitStringArr = receivedText?.components(separatedBy: "|")
                
                
                
                if(splitStringArr!.count>0){
                    
                    cell.project = splitStringArr![0]
                    if (  (cell.SuggestionLabel.text?.contains("Registration"))!){
                        let font = UIFont(name: "Montserrat-Bold", size: 10)
                        cell.SuggestionLabel.font = font
                        cell.SuggestionLabel.textColor = UIColor.white
                        
                        cell.Border.backgroundColor = UIColor.init(hexString: "#3C7E40")
                        
                    }
                }
                
            }
            
            else{
                cell.project = self.items.last?.options?[indexPath.item] as? String
                
                
            }
            
            
            //                       if(indexPath.item==0 && collectionView == FirstTimeCollectionView && cell.SuggestionLabel.text == "COVID-19"){
            //                           cell.SuggestionLabel.textColor = UIColor(red: 250/255, green: 166/255, blue: 44/255, alpha: 1)
            //                           let font = UIFont(name: "Montserrat-SemiBold", size: 10)
            //                           cell.SuggestionLabel.font = font
            //
            //                       }
            //                       else if (collectionView == FirstTimeCollectionView){
            //
            //                           if(  (cell.SuggestionLabel.text?.contains("Broadcast"))!){
            //                               let img = UIImage.init(named: "broadcast")
            //                               cell.cellImage.image = img
            //
            //                           }
            //
            //
            //                           cell.SuggestionLabel.textColor = UIColor.init(hexString: "#01426F")
            //
            //                           let font = UIFont(name: "Montserrat-Regular", size: 10)
            //                           cell.SuggestionLabel.font = font
            //                       }
            
            return cell
        }
        
    }
    
    
    
    // MARK: -   seggation item click/select UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //sosBttn.isHidden=true
        shadowView.isHidden = true
        pageControl.isHidden = true
        var text = ""
        let index = 0
        
        // pre check for propesctive user status
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let lu = LightUtility.getLightUser()
        if lu != nil{
            delegate.checkProspectiveUserStatus(mobileNumber: lu!.mobile){isActive in
                if !isActive{
                    DispatchQueue.main.async(execute: { () -> Void in
                        LoginModel.sharedInstance.Logout()
                    })
                }
            }
        }
        
        
        if let cell = collectionView.cellForItem(at:indexPath) as? CollectionLeaveCell {
            text = cell.leavename.text!
        } else if let cell = collectionView.cellForItem(at: indexPath) as? SuggestionCollectionViewCell {
            text = cell.SuggestionLabel.text!
            
        }
        
        if (text != nil) && (text.hasPrefix("Call ") || text.hasPrefix("Email")) {
            
        }
        
        else if (text.contains("Broadcast")){
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "SLChatBot", bundle: nil)
            let notiFicationController = storyBoard.instantiateViewController(withIdentifier: "NotificationListControllerlight") as! LNotificationListController
            
            //        webViewController.flag = "Cashless Hosp"
            
            self.navigationController?.pushViewController(notiFicationController, animated: true)
        }
        else if (text.contains("Expresso")) {
            // NOTE: worked with Pushnotification Manager class
            //identifier name for UI story board
            let storyBoard: UIStoryboard = UIStoryboard(name: "SLChatBot", bundle: nil)
            let notiFicationController = storyBoard.instantiateViewController(withIdentifier: "NewsLetterListViewControllerLight") as! LNewsLetterListViewController
            self.navigationController?.pushViewController(notiFicationController, animated: true)
        }
        else if (text == "Cashless hospitals"){
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
            let webViewController = storyBoard.instantiateViewController(withIdentifier: "WebViewInterface") as! TestYourselfWebViewViewController
            
            webViewController.flag = "Cashless Hosp"
            
            self.navigationController?.pushViewController(webViewController, animated: true)
            
        }
        else if (text == "Assess Yourself"){
            let storyBoard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
            let webViewController = storyBoard.instantiateViewController(withIdentifier: "WebViewInterface") as! TestYourselfWebViewViewController
            webViewController.flag = "Assess Yourself"
            
            self.navigationController?.pushViewController(webViewController, animated: true)
            
        }
        else if (text == "FAQ"){
            let storyBoard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
            let webViewController = storyBoard.instantiateViewController(withIdentifier: "WebViewInterface") as! TestYourselfWebViewViewController
            webViewController.flag = "FAQs"
            self.navigationController?.pushViewController(webViewController, animated: true)
        }
        else   if self.items.last?.type == .guidline_html {
            
            //  self.composeMessage(type: .text, visibilty: .yes , content: "HR_QUERY:" + self.inputTextField.text!, approvaltype: true, approvalText: self.inputTextField.text!)
            
            let typeCheck = self.items.last?.type == .picker ? "LEAVE_REASON - \(text)" : text
            
            self.composeMessage(type: .text, visibilty: .yes, content: "GUIDELINES_HTML:" + typeCheck, approvaltype: true, approvalText: typeCheck)
            
            
        }
        else {
            if collectionView == FirstTimeCollectionView{
                if let index = _tryGetDataIndex(indexPath: indexPath){
                    if index < self.items.last?.options?.count ?? 0 {
                        let receivedText = self.items.last?.options?[index] as? String
                        if(receivedText != nil && (receivedText?.contains("|"))!){
                            let splitStringArr = receivedText?.components(separatedBy: "|")
                            
                            
                            
                            if(splitStringArr!.count>0){
                                
                                
                                if(splitStringArr![1]=="WebView"){
                                    
                                    let storyBoard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
                                    let webViewController = storyBoard.instantiateViewController(withIdentifier: "WebViewInterface") as! TestYourselfWebViewViewController
                                    
                                    webViewController.flag = "Warehouse"
                                    webViewController.url = splitStringArr![2]
                                    
                                    self.navigationController?.pushViewController(webViewController, animated: true)
                                    
                                }
                                
                                
                                else if(splitStringArr![1]=="WebViewExternal"){
                                    
                                    
                                    if let link = URL(string: splitStringArr![2]) {
                                        UIApplication.shared.open(link)
                                        return
                                    }
                                    
                                    
                                }
                                else if(splitStringArr![1]=="CalendarEvent"){
                                    
                                    print("Calendar INvite PArticipants")
                                    
                                }
                            }
                        }
                        else{
                            
                            
                            //      self.composeMessage(type: .text, visibilty: .yes, content: "HR_QUERY:" + self.inputTextField.text!, approvaltype: true, approvalText: self.inputTextField.text!)
                            
                            let typeCheck = self.items.last?.type == .picker ? "LEAVE_REASON - \(text)" : text
                            
                            
                            
                            
                            
                            
                            self.composeMessage(type: .text, visibilty: .yes, content: typeCheck, approvaltype: false, approvalText: "")
                            
                        }
                    }
                    else
                    {
                        shadowView.isHidden = false
                        pageControl.isHidden = false
                    }
                    
                }
            }
            else{
                // if indexPath.item < self.items.last?.options?.count ?? 0 {
                let receivedText = self.items.last?.options?[indexPath.item] as? String
                if(receivedText != nil && (receivedText?.contains("|"))!){
                    let splitStringArr = receivedText?.components(separatedBy: "|")
                    
                    
                    
                    if(splitStringArr!.count>0){
                        
                        
                        if(splitStringArr![1]=="WebView"){
                            
                            let storyBoard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
                            let webViewController = storyBoard.instantiateViewController(withIdentifier: "WebViewInterface") as! TestYourselfWebViewViewController
                            
                            webViewController.flag = "Warehouse"
                            webViewController.url = splitStringArr![2]
                            
                            self.navigationController?.pushViewController(webViewController, animated: true)
                            
                        }
                        else if(splitStringArr![1]=="WebViewExternal"){
                            
                            
                            if let link = URL(string: splitStringArr![2]) {
                                UIApplication.shared.open(link)
                                return
                            }
                            
                            
                        }
                        else if(splitStringArr![1]=="CalendarEvent"){
                            
                            print("Calendar Invite Participants")
                            let eventArrayString = splitStringArr![2]
                            let arrayEvent = eventArrayString.components(separatedBy: "$%$#")
                            print(arrayEvent)
                            let title = arrayEvent[0]
                            let date = arrayEvent[1]
                            print("date", date)
                            let startDate = getDate(string: arrayEvent[1])
                            print("startDate", startDate!)
                            let timeDuration = Double(arrayEvent[2])
                            let description = arrayEvent[3]
                            // 2 hours
                            let endDate = startDate!.addingTimeInterval(timeDuration!)
                            
                            CalendarService.addEventToCalendar(title: title,
                                                               description: description,
                                                               startDate: startDate!,
                                                               endDate: endDate,
                                                               completion: { (success, error) in
                                if success {
                                    CalendarService.openCalendar(with: startDate!)
                                } else if let error = error {
                                    print(error)
                                }
                            })
                            
                        }
                    }
                }
                else{
                    
                    
                    //      self.composeMessage(type: .text, visibilty: .yes, content: "HR_QUERY:" + self.inputTextField.text!, approvaltype: true, approvalText: self.inputTextField.text!)
                    
                    let typeCheck = self.items.last?.type == .picker ? "LEAVE_REASON - \(text)" : text
                    
                    
                    
                    
                    
                    
                    self.composeMessage(type: .text, visibilty: .yes, content: typeCheck, approvaltype: false, approvalText: "")
                    
                }
                //   }
                //                else
                //                {
                //                    shadowView.isHidden = false
                //                    pageControl.isHidden = false
                //                }
            }
            //   }
            
            
        }
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        
        if collectionView == FirstTimeCollectionView {
            
            return CGSize(width: CollectionvViewSize.width , height: CollectionvViewSize.height + 60 )
            
        }
        
        var str = ""
        let receivedText = self.items.last?.options?[indexPath.item] as? String
        if(self.items.last?.type != .next_screen){
            
            
            if( receivedText != nil && (receivedText?.contains("|"))!){
                let splitStringArr = receivedText?.components(separatedBy: "|")
                
                
                
                if(splitStringArr!.count>0){
                    
                    str = splitStringArr![0]
                    
                }
            }
            else{
                str = self.items.last?.options?[indexPath.item] as? String ?? "A long String"
            }
        }
        let width = str.width(withConstrainedHeight: 40 , font: UIFont(name: "Montserrat", size: 15.0)!)
        
        return CGSize(width: width + 40 , height: 40)
        
        
    }
    
    
    
    //MARK: Hides collection View
    func changeCollectionViewVisibilityStatus(shouldShow: Bool) {
        
        SuggestionCellView.isHidden = !shouldShow
        FirstTimeCollectionView.isHidden = !shouldShow
        collectionViewHeightConstraint.constant = 0
        FirstTimeCollectionViewHeight.constant = 0
        self.InputBarHeight.constant = 60
        self.inputBar.setNeedsLayout()
        
    }
    
    func getDate(string : String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd-MMM-yyyy hh:mm a"
        let date = dateFormatter.date(from: string)
        return date
    }
    
    //MARK:Paging in CollectionView
    private func _tryGetDataIndex(indexPath: IndexPath)-> Int? {
        let index = indexPath.row;
        let page = index / _itemsPerPage
        let indexInPage = index - page * _itemsPerPage;
        let row = indexInPage % _itemsPerColumn;
        let column = indexInPage / _itemsPerColumn;
        
        let dataIndex = row * _itemsPerRow + column + page * _itemsPerPage
        if dataIndex >= self.items.last?.options?.count ?? 0 {
            return nil
        }
        return dataIndex
    }
    private func virtualCount() ->Int{
        let count = self.items.last?.options?.count ?? 0
        let totalPages = Int(ceil(Double(count) / Double(_itemsPerPage)))
        return Int(totalPages) * _itemsPerPage
    }
    
    
    private func  numberOfPages() -> Int
    {
        let count = self.items.last?.options?.count ?? 0
        return   Int(ceil(Double(count) / Double(_itemsPerPage)))
    }
    
    func MakeBottomView(_ hide :  Bool)  {
        
        
        guard self.items.last?.options != nil , self.items.last?.options?.count ?? 0 != 0 else {
            
            return
        }
        shadowView.isHidden = false
        
        
        if  hide == true  {
            pageControl.numberOfPages = numberOfPages()
            
            let flowLayout = FirstTimeCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
            let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right + (flowLayout.minimumLineSpacing * 3)
            + (flowLayout.minimumInteritemSpacing * 3)
            let size = Int((FirstTimeCollectionView.bounds.width - totalSpace )  / CGFloat(4))
            
            var maxheight = [CGFloat]()
            
            for row in self.items.last?.options ?? [] {
                let str = row as? String ?? "A long String"
                let wheight = str.height(withConstrainedHeight: CGFloat(size), font: UIFont(name: "Montserrat", size: 10.0)!)
                maxheight.append(wheight)
            }
            
            let hght = maxheight.max()
            CollectionvViewSize = CGSize.init(width: CGFloat(size), height: CGFloat(hght!))
            
            FirstTimeCollectionView.reloadData()
            FirstTimeCollectionView.setNeedsLayout()
            FirstTimeCollectionView.isHidden = false
            SuggestionCellView.isHidden = true
            collectionViewHeightConstraint.constant = 0
            let height = self.FirstTimeCollectionView.collectionViewLayout.collectionViewContentSize
            //            FirstTimeCollectionViewHeight.constant = height.height + 10
            FirstTimeCollectionViewHeight.constant = CGFloat(collectionViewHeight);//height.height + 10
            pageControl.isHidden = false
            
            self.InputBarHeight.constant = FirstTimeCollectionViewHeight.constant + 85 // height of input view + pagecontrol + shadow view (top padding)
            self.inputBar.setNeedsLayout()
        } else {
            SuggestionCellView.reloadData()
            self.SuggestionCellView.setContentOffset(.zero, animated: true)
            pageControl.isHidden = true
            
            FirstTimeCollectionView.isHidden = true
            FirstTimeCollectionViewHeight.constant = 0
            SuggestionCellView.isHidden = false
            collectionViewHeightConstraint.constant = 70
            self.InputBarHeight.constant = collectionViewHeightConstraint.constant + 60
            self.inputBar.setNeedsLayout()
        }
        
        self.ImplementTimer()
    }
    
    //MARK: Table Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
        
        
        if (self.items[indexPath.row].type == .claim) || (self.items[indexPath.row].type == .employee) ||  (self.items[indexPath.row].type == .map) || (self.items[indexPath.row].type == .text) {
            
            cell.isUserInteractionEnabled = true
            
        }  else if ( self.items.last!.type == .approvals )  {
            
            if approvalIndexpaths.contains(indexPath)  {
                cell.isUserInteractionEnabled = true
                
            } else {
                cell.isUserInteractionEnabled = false
            }
            
        } else {
            
            if indexPath.row == self.items.count - 1 {
                cell.isUserInteractionEnabled = true
                cell.contentView.isUserInteractionEnabled = true
            }else{
                cell.isUserInteractionEnabled = false
                cell.contentView.isUserInteractionEnabled = false
            }
        }
    }
    
    // MARK: Receiver and send cell logic chat table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (self.items[indexPath.row].type == .calendar)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Calendar", for: indexPath) as! CalendarCell
            
            cell.cellDelegate = self
            cell.indexPath = indexPath
            cell.selectionMode = self.items[indexPath.row].calendarRange
            
            // pre-select dates for cells of past conversation
            if let selectedDates = preSelectedDates[String(format: "%d",indexPath.row)] {
                if (selectedDates.count == 2) {
                    let fromDate = selectedDates[0]
                    let toDate = selectedDates[1]
                    cell.selectDates(fromDate: fromDate, toDate: toDate)
                }
                else {
                    cell.selectDates(dates: selectedDates)
                }
            }
            
            return cell
            
        }else if (self.items[indexPath.row].type == .zoomTimer) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath) as! TimeCell
            //            cell.zoomTimePicker.isUserInteractionEnabled = true
            cell.zoomTimePicker.date = NSDate() as Date
            cell.timeCellDelegate = self
            if(self.items[indexPath.row].zoomTimerComponents != nil){
                cell.preSelectedDate = self.items[indexPath.row].zoomTimerComponents
                
            }
            
            return cell
            
        }
        else if (self.items[indexPath.row].type == .leave) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LeaveCell", for: indexPath) as! LeaveCell
            
            if indexPath.row == self.items.count - 1 {
                cell.isEnable = true
                cell.menuItems = self.items[indexPath.row].componentValues
            } else{
                cell.isEnable = false
            }
            
            return cell
            
        } else if (self.items[indexPath.row].type == .allApprove) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "approveAll", for: indexPath) as! ApprovalAllTableCell
            cell.approveBtn.tag = indexPath.row
            cell.approveBtn.addTarget(self, action: #selector(confirmApproveAlert(_:)), for: .touchUpInside)
            
            return cell
            
        } else if (self.items[indexPath.row].type == .approvals) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewApprovalTableCell", for: indexPath) as! NewApprovalTableCell
            
            cell.approvalRow = self.items[indexPath.row].newapprovallist
            cell.listType = false
            
            
            return cell
            
        } else if (self.items[indexPath.row].type == .map) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationViewCell", for: indexPath) as! LocationViewCell
            cell.addressItems = self.items[indexPath.row].componentMapValues
            
            return cell
            
        }
        else if (self.items[indexPath.row].type == .regularisation) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegularizationCell", for: indexPath) as! RegularizationCell
            cell.regularizationData = self.items[indexPath.row].componentRegularizationValues
            cell.rowType = false
            
            return cell
            
        } else if (self.items[indexPath.row].type == .statuslist) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalTableCell", for: indexPath) as! ApprovalTableCell
            cell.approvalData = self.items[indexPath.row].approvallist
            cell.listType = true
            
            return cell
            
        } else if (self.items[indexPath.row].type == .cancel_service_ticket) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HelpDeskTableCell", for: indexPath) as! HelpDeskTableCell
            cell.array = self.items[indexPath.row].cancelServiceList
            cell.listType = false
            
            return cell
            
        }else if (self.items[indexPath.row].type == .service_list) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HelpDeskTableCell", for: indexPath) as! HelpDeskTableCell
            cell.array = self.items[indexPath.row].serviceList
            cell.listType = true
            
            return cell
            
        } else if (self.items[indexPath.row].type == .food) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FoodTableCell", for: indexPath) as! FoodCell
            
            cell.menuItems = self.items[indexPath.row].foodMenu
            
            return cell
            
        }
        else if (self.items[indexPath.row].type == .employee) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCard", for: indexPath) as! EmployeeCard
            
            cell.cardItems = self.items[indexPath.row].employeeValues
            
            
            
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            
            
            return cell
        } else if (self.items[indexPath.row].type == .claim) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClaimTableCell", for: indexPath) as! ClaimTableCell
            cell.claimData = self.items[indexPath.row].componentsClaims
            
            
            return cell
        }
        
        switch self.items[indexPath.row].owner {
            
        case .sender:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Receiver", for: indexPath) as! ReceiverCell
            cell.clearCellData()
            print("Sender\(self.items[indexPath.row].content)")
            
            cell.message.text = self.items[indexPath.row].content as? String
            
            return cell
        case .receiver:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! SenderCell
            cell.clearCellData()
            cell.profilePic.image = #imageLiteral(resourceName: "chatbot")
            print("Receiver\(self.items[indexPath.row].content)")
            cell.message.text = self.items[indexPath.row].content as? String
            
            return cell
        }
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        
        
        if (self.items[indexPath.row].type == .approvals) && self.approvalIndexpaths.contains(indexPath) {
            
            
            let cell = tableView.cellForRow(at: indexPath) as! NewApprovalTableCell
            
            self.textFromAlert = true
            let action = UIContextualAction(style: .normal, title: "REJECT", handler:{ (action, view, completionHandler) in
                
                
                SwAlert.showTwoActionAlert("", message: "Please enter a reason", styleone: .cancel, styletwo: .destructive, onebuttonTitle: "Cancel", twobuttonTitle: "Reject", placeholder: "Reason" , onecompletion:  { AnyObject in
                    self.bottomConstraint.constant = 0
                    self.inputBar.setNeedsLayout()
                    self.textFromAlert = false
                    self.ResetCellofTable(indexPath)
                    
                }, twocompletion: {  AnyObject in
                    
                    self.bottomConstraint.constant = 0
                    self.inputBar.setNeedsLayout()
                    self.textFromAlert = false
                    guard let textfield = AnyObject?.object(at: 0) as? UITextField , textfield.text! != "" else {
                        self.ResetCellofTable(indexPath)
                        return
                    }
                    
                    let type = (cell.approvalRow!.leavetype!).split(separator: " ")
                    let user = userDefaults.value(forKey: "user") as? [String: Any]
                    
                    let apiDict = ["empID":"\(user!["empID"] ?? "")", "startDate":"\(cell.approvalRow?.leaveFrom ?? "")", "endDate":"\(cell.approvalRow?.leaveTo ?? "")", "selectedEmpId":"\(cell.approvalRow?.userid ?? "")", "leaveType":"\(type.last ?? "")", "leaveAction":"Reject" , "leaveReason":textfield.text!]
                    
                    let indexPathForremoveMessage = IndexPath.init(row: indexPath.row, section: 0)
                    self.MakeApproveANDRejectReply(apiDict, index: indexPathForremoveMessage, msg: self.items[indexPath.row])
                    
                    print("success")
                    completionHandler(true)
                })
                
                
                
                
            })
            
            action.image = #imageLiteral(resourceName: "reject")
            action.backgroundColor = .red
            let configuration = UISwipeActionsConfiguration(actions: [action])
            return configuration
            
            
        }else {
            return UISwipeActionsConfiguration()
        }
        
        
        
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        if(self.items[indexPath.row].type == .cancel_service_ticket ){
            swipableItemIndexRow = indexPath.row
            
        }
        
        
        if (self.items[indexPath.row].type == .approvals) && self.approvalIndexpaths.contains(indexPath) {
            
            let cell = tableView.cellForRow(at: indexPath) as! NewApprovalTableCell
            
            let action = UIContextualAction(style: .normal, title: "APPROVE" ,
                                            handler:{ (action, view, completionHandler) in
                
                let type = (cell.approvalRow!.leavetype!).split(separator: " ")
                let user = userDefaults.value(forKey: "user") as? [String: Any]
                
                let apiDict = ["empID":"\(user!["empID"] ?? "")", "startDate":"\(cell.approvalRow?.leaveFrom ?? "")", "endDate":"\(cell.approvalRow?.leaveTo ?? "")", "selectedEmpId":"\(cell.approvalRow?.userid ?? "")", "leaveType":"\(type.last ?? "")", "leaveAction":"Approve"]
                
                print("success")
                
                let indexPathForremoveMessage = IndexPath.init(row: indexPath.row, section: 0)
                self.MakeApproveANDRejectReply(apiDict, index: indexPathForremoveMessage, msg: self.items[indexPath.row])
                
                completionHandler(true)
            })
            
            action.image = cell.listType == true ? #imageLiteral(resourceName: "reject") :  #imageLiteral(resourceName: "approvall")
            action.backgroundColor = cell.listType == true ? #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1) : #colorLiteral(red: 0, green: 0.5019607843, blue: 0, alpha: 1)
            let configuration = UISwipeActionsConfiguration(actions: [action])
            return configuration
            
        } else {
            return UISwipeActionsConfiguration()
        }
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if (self.items[indexPath.row].type == .statuslist)  {
            return CGFloat(self.items[indexPath.row].approvallist!.count * 110 )
        } else if (self.items[indexPath.row].type == .regularisation)  {
            return CGFloat(self.items[indexPath.row].componentRegularizationValues!.count * 100) + extraHeight
        } else if (self.items[indexPath.row].type == .cancel_service_ticket)  {
            return CGFloat(self.items[indexPath.row].cancelServiceList!.count * 122 )
        } else if (self.items[indexPath.row].type == .service_list)  {
            return CGFloat(self.items[indexPath.row].serviceList!.count * 122 )
        }
        else if(self.items[indexPath.row].content as! String == "hidden"){
            return 0;
        }
        
        return UITableView.automaticDimension
        
    }
    
    
    func ResetCellofTable(_ index : IndexPath)  {
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [index], with: .none)
        self.tableView.endUpdates()
    }
    
    
    
    //MARK: TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    @objc func textFieldDidChange(sender: UITextField) {
        
        guard speechRecogniserEnable == false else {
            return
        }
        
        SetAudioandTextView(sender: sender)
        
    }
    
    
    func SetAudioandTextView(sender : UITextField) {
        
        
        if sender.text?.count == 0 {
            
            audioMessageView.isHidden = false
            textMessageView.isHidden = true
            sendAudioImage.image = #imageLiteral(resourceName: "voice_normal")
        } else {
            
            audioMessageView.isHidden = true
            textMessageView.isHidden = false
            if sender.text?.count == 0 {
                sendTextImage.image = #imageLiteral(resourceName: "voice_normal")
            } else {
                sendTextImage.image = #imageLiteral(resourceName: "send")
            }
            
        }
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.bottomConstraint.constant = 0
        self.inputBar.setNeedsLayout()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.speechRecogniserEnable = false
        
    }
    
    
    
    
    
    
    //MARK: SEND API REQUESTS
    
    func cancelServiceTicket(_ str : Any , index : IndexPath , isZoom : Bool){
        
        let lastIndex = self.items.count
        
        
        let deletedTicket = self.items[swipableItemIndexRow].cancelServiceList![index.row]
        
        self.items[swipableItemIndexRow].cancelServiceList?.remove(at: index.row)
        let itemIndexPath = IndexPath(row: swipableItemIndexRow, section: 0)
        
        self.tableView.reloadRows(at: [itemIndexPath], with: .none)
        
        SendCancelTicketRequest(str, ticketIndex: index,itemIndex: itemIndexPath,deletedCancelTicket: deletedTicket , isZoom : isZoom)
        
        
    }
    
    
    
    func SendCancelTicketRequest(_ str : Any , ticketIndex : IndexPath,itemIndex:IndexPath , deletedCancelTicket: ServiceModelClass , isZoom : Bool ) {
        
        
        
        
        
        ApprovalManager.shared.sendCancelRequest(parameters: str as! [String : Any], position: ticketIndex, isZoom: isZoom, completion: { (responseDictionary , place )  in
            
            
            guard let _: Bool = responseDictionary["success"] as? Bool else {
                
                
                
                if(self.items[itemIndex.row].cancelServiceList!.count > 0) {
                    self.items[itemIndex.row].cancelServiceList?.insert(deletedCancelTicket, at: ticketIndex.row)
                }
                else{
                    self.items[itemIndex.row].cancelServiceList?.append(deletedCancelTicket)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [itemIndex], with: .none)
                    
                }
                
                return
            }
            
            DispatchQueue.main.async {
                if(isZoom){
                    let newMessage = Message(content:responseDictionary["textResponse"]! , owner: .receiver)
                    newMessage.type = .text
                    newMessage.options = responseDictionary["options"] as? [Any]
                    
                    
                    
                    self.items.append(newMessage)
                    let indexPathForNewMessage = IndexPath.init(row: self.items.count - 1, section: 0)
                    self.InsertRowsToTableView(indexPaths: [indexPathForNewMessage])
                }else{
                    if self.items.last?.cancelServiceList?.count == 0 {
                        let newMessage = Message.allCancelRequestMessage()
                        self.items.append(newMessage)
                        let indexPathForNewMessage = IndexPath.init(row: self.items.count - 1, section: 0)
                        self.InsertRowsToTableView(indexPaths: [indexPathForNewMessage])
                    }
                }
            }
            
        })
        
    }
    
    
    
    func MakeApproveANDRejectForStatusReply(_ str : Any , apprvaltext : String) {
        self.composeMessage(type: .text, visibilty: .no, content: str, approvaltype: true, approvalText: apprvaltext)
    }
    
    
    func MakeApproveANDRejectReply(_ str : Any , index : IndexPath , msg : Message) {
        self.composeApprovalMessage(type: msg.type, visibilty: .no, position: index, apiContent: str, msg: msg)
    }
    
    func SendApiForAllApprove(_ apiArray : Any , lastMsg : Message) {
        
        var times = 0
        let approvalitems:[(apiD: [String:Any] , value: IndexPath , msg : Message)] = apiArray as! [(apiD: [String : Any], value: IndexPath, msg: Message)]
        
        
        DispatchQueue.global(qos: .background).async {
            
            for row in 0..<approvalitems.count {
                
                let item = approvalitems[row]
                if item.msg.type == .approvals {
                    MessageManager.shared.sendApprovalResponse(setmessage: item.msg,
                                                               visibility: .no,
                                                               position: item.value,
                                                               toID: "UserId",
                                                               approvalDict: item.apiD,
                                                               completion: {(success, messages , place , error ) in
                        
                        print("Response for ", place ," is ", success)
                        
                        if !(success as! Bool) {
                            
                            times = times + 1
                            
                            if  self.items.index(of: lastMsg) != nil && times == 1 {
                                let removeMsg = self.items.index(of: lastMsg)
                                self.items.remove(at: removeMsg!)
                                let indexPathForoldMessage = IndexPath.init(row: removeMsg!, section: 0)
                                self.tableView.deleteRows(at:[indexPathForoldMessage] , with: .none)
                            }
                            
                            if times == 2 {
                                self.items.insert(approvalitems[0].msg, at: approvalitems[0].value.row)
                                self.InsertApprovalRowsToTableView(indexPaths: [approvalitems[0].value])
                                self.approvalIndexpaths.append(approvalitems[0].value)
                            }
                            
                            self.AppendMessages(place, messages)
                            self.approvalIndexpaths.append(place)
                            print(self.approvalIndexpaths)
                            
                        }
                        
                    })
                } else {
                    
                }
            }
            
        }
        
        
    }
    
    @objc func confirmApproveAlert(_ sender : UIButton ) {
        
        SwAlert.showTwoActionAlert("", message: "Are you sure you'd like to approve all requests?", styleone: .cancel, styletwo: .Default, onebuttonTitle: "No", twobuttonTitle: "Yes", placeholder: "" , onecompletion: nil , twocompletion: { AnyObject in
            self.MakeAllApprove(sender)
        })
        
    }
    
    
    @objc func MakeAllApprove(_ sender : UIButton) {
        
        
        guard self.items.last?.type == .approvals else {
            
            return
            
        }
        
        let index = sender.tag
        let itemsCopy = self.items
        let itemsCount = itemsCopy.count
        
        var indexPathsArrayToDelete = [IndexPath]()
        
        var counter = index
        
        while counter < itemsCount {
            let indexPath = IndexPath.init(row: counter , section: 0)
            indexPathsArrayToDelete.append(indexPath)
            counter = counter + 1
            self.items.remove(at: index)
        }
        
        
        // remove all rows from table view
        self.approvalIndexpaths.removeAll()
        self.RemoveRowsToTableView(indexPaths: indexPathsArrayToDelete)
        
        //Append New Message - ALLAPPROVE
        let newMessage = Message.allapprovedMessage()
        self.items.append(newMessage)
        let indexPathForNewMessage = IndexPath.init(row: self.items.count - 1, section: 0)
        self.InsertApprovalRowsToTableView(indexPaths: [indexPathForNewMessage])
        
        var approvalitems:[(apiD: [String:Any] , value: IndexPath , msg : Message)] = []
        
        //Send API call
        for i in index..<itemsCopy.count {
            
            if i == index && (itemsCopy[i].type == .allApprove) {
                approvalitems.append(([String:Any]() , IndexPath.init(row: i , section: 0) , itemsCopy[i]))
            } else {
                if (itemsCopy[i].type == .approvals) {
                    
                    let messageDictionary = itemsCopy[i].newapprovallist
                    
                    let leaveFrom = messageDictionary?.leaveFrom
                    let leaveTo = messageDictionary?.leaveTo
                    let userid = messageDictionary?.userid
                    let leavetype = messageDictionary?.leavetype
                    
                    let type = (leavetype)?.split(separator: " ")
                    let user = userDefaults.value(forKey: "user") as? [String: Any]
                    
                    let apiDict = ["empID":"\(user!["empID"] ?? "")", "startDate":"\(leaveFrom ?? "")", "endDate":"\(leaveTo ?? "")", "selectedEmpId":"\(userid ?? "")", "leaveType":"\(type?.last ?? "")", "leaveAction":"Approve"]
                    
                    let indexPathForremoveMessage = IndexPath.init(row: i , section: 0)
                    
                    approvalitems.append((apiDict , indexPathForremoveMessage , itemsCopy[i]))
                    
                } else {
                    
                    break
                    
                }
            }
        }
        
        print(approvalitems)
        self.SendApiForAllApprove(approvalitems, lastMsg: newMessage)
        
    }
    
    
    
    
    
    
    //MARK: Append Unsuccessful Messages
    func AppendMessages(_ index : IndexPath , _ msg : [Message])  {
        
        if index.row < self.items.count - 1 {
            print(index.row , "less" , self.items.count - 1 )
            self.items.insert(msg.first!, at: index.row)
            self.InsertApprovalRowsToTableView(indexPaths: [index])
        } else if index.row > self.items.count - 1 || index.row == self.items.count - 1 {
            print(index.row , "greater" , self.items.count - 1 )
            self.items.append(msg.first!)
            let indexPathForNewMessage = IndexPath.init(row: self.items.count - 1, section: 0)
            self.InsertApprovalRowsToTableView(indexPaths: [indexPathForNewMessage])
        }
        
    }
    
    
    
    func didSelectedDates(fromDate: Date?, toDate: Date?, indexPath: IndexPath) {
        var currentDateSelection = [Date]()
        
        if fromDate != nil {
            currentDateSelection.append(fromDate!)
        }
        
        if toDate != nil {
            currentDateSelection.append(toDate!)
        }
        
        let indexPathString = String(format: "%d",indexPath.row)
        preSelectedDates[indexPathString] = currentDateSelection
    }
    
    
    func doneButtonClicked(indexPath: IndexPath) {
        
        
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "dd-MMM-yyyy"
        
        let indexPathString = String(format: "%d",indexPath.row)
        
        if let selectedDates = preSelectedDates[indexPathString],
           selectedDates.count > 0 {
            var dateForUser: String?
            var dateForAPI: String?
            if(selectedDates.count == 2) {
                let fromDate =  dateStringFormatter.string(from: selectedDates[0])
                let toDate =  dateStringFormatter.string(from: selectedDates[1])
                dateForUser = String(format: "From %@ to %@",fromDate, toDate)
                dateForAPI = String(format: "%@,%@", fromDate,toDate)
            }
            else {
                let fromDate =  dateStringFormatter.string(from: selectedDates[0])
                dateForUser = String(format: "%@",fromDate)
                let selectionMode = self.items[indexPath.row].calendarRange
                dateForAPI = selectionMode == false ? String(format: "%@",fromDate) : String(format: "%@,%@", fromDate,fromDate)
                
            }
            
            print("Sending date: %@ to the API",dateForAPI)
            print("Showing date: %@ to the User",dateForUser)
            
            self.composeMessage(type: .text,
                                visibilty: .yes,
                                content: dateForAPI,
                                approvaltype: true,
                                approvalText: dateForUser!)
        }
    }
    
    
    func cancelButtonClicked(indexPath: IndexPath) {
        self.composeMessage(type: .text, visibilty: .yes, content: "Cancel", approvaltype: false, approvalText: "")
    }
    
    
    //MARK: PickerView Delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.items.last?.type == .regularisation {
            let updatecell = self.delegate as! innerRegularisationCell
            return updatecell.regularizationData?.reasonOptions?.count ?? 0
        }
        
        return self.items.last?.options?.count ?? 0
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if self.items.last?.type == .regularisation {
            let updatecell = self.delegate as! innerRegularisationCell
            return updatecell.regularizationData?.reasonOptions?[row].value
        }
        
        return self.items.last?.options?[row] as? String
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    @IBAction func CancelPicker(_ sender: UIButton) {
        
        self.textFromAlert = false
        if sender.tag == 1 {
            if self.items.last?.type == .regularisation {
                TimePickerClose("")
            }else {
                self.PickerClose("")
            }
            
        } else if sender.tag == 3 {
            TimePickerClose("")
        }
        
    }
    
    
    @IBAction func DonePicker(_ sender: UIButton) {
        
        self.textFromAlert = false
        if sender.tag == 2 {
            
            if self.items.last?.type == .regularisation {
                
                let row = self.PickerView.selectedRow(inComponent: 0)
                let updatecell = self.delegate as! innerRegularisationCell
                let selectedtext = updatecell.regularizationData?.reasonOptions?[row].value
                updatecell.regularizationUpdateReasonData = selectedtext
                TimePickerClose("")
                
            } else if self.items.last?.type == .picker {
                let row = self.PickerView.selectedRow(inComponent: 0)
                let selectedtext = self.items.last?.options?[row] as? String
                self.PickerClose(selectedtext!)
            }
            
        } else if sender.tag == 4 {
            if self.items.last?.type == .regularisation {
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "hh:mm a"
                let dateValue = dateformatter.string(from: datepicker.date)
                let updatecell = self.delegate as! innerRegularisationCell
                if updatecell.tag == 2 {
                    updatecell.regularizationUpdateData = dateValue
                }else if updatecell.tag == 3 {
                    updatecell.regularizationUpdateData = dateValue
                }
                
                TimePickerClose("")
            }
            
        }
        //        else{
        //            let dateformatter = DateFormatter()
        //            dateformatter.dateFormat = "hh:mm a"
        //            let dateValue = dateformatter.string(from: zoomTimePicker.date)
        //            self.zoomPickerClose(dateValue)
        //        }
    }
    
    func zoomPickerdone(timeSelected: Date){
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "hh:mm a"
        let dateValue = dateformatter.string(from: timeSelected)
        self.composeMessage(type: .text, visibilty: .yes, content: dateValue, approvaltype: false, approvalText: "")
        
    }
    func TimePickerClose(_ string : String)  {
        self.inputBar.isHidden = false
        self.inputTextField.resignFirstResponder()
        self.inputTextField.inputView = nil
    }
    
    
    func PickerClose(_ string : String)  {
        
        
        self.inputBar.isHidden = false
        self.inputTextField.resignFirstResponder()
        self.inputTextField.inputView = nil
        
        guard string != "" else {
            return
        }
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {_ in
            self.composeMessage(type: .text, visibilty: .yes, content: string, approvaltype: false, approvalText: "")
        })
        
    }
    
    //MARK: generate count of notification
    func retrieveNotificationCount() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        notificationUnreadCount = 0
        
        //var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NotificationEntity")
        var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Table.Name.prospNotifiaction)
        fetchRequest.predicate = NSPredicate(format: "attribute_markUnread = %d", Int(true))
        
        var results: [NSManagedObject] = []
        
        do {
            results = try managedContext.fetch(fetchRequest)
            if(results.count > 0){
                notificationUnreadCount = results.count
            }
            if(notificationUnreadCount == 0){
                lbl_count.isHidden=true
            }
            else {
                lbl_count.isHidden=false
            }
            lbl_count.text = String(notificationUnreadCount)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
    }
    
    func retrieveNewsNotificationCount()  {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Table.Name.prospNewsLetter)
        fetchRequest.predicate = NSPredicate(format: "attribute_markUnread = %d", Int(truncating: true))
        var results: [NSManagedObject] = []
        do {
            results = try managedContext.fetch(fetchRequest)
            newsNotificationUnreadCount = results.count
            FirstTimeCollectionView.reloadData()
        }
        catch {
            print("error executing fetch request: \(error)")
        }
    }
    
    
    //MARK: UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.inputTextField.isUserInteractionEnabled == true && self.inputTextField.inputView == inputPickerView || self.inputTextField.inputView == TimeView {
            self.inputBar.isHidden = true
            self.inputTextField.becomeFirstResponder()
        } else {
        }
    }
    
    func OpenTimePickerForCheck(cell : UITableViewCell)  {
        
        self.inputBar.isHidden = true
        self.textFromAlert = true
        self.TextfiledContainerView.isUserInteractionEnabled = true
        self.inputTextField.inputView = self.TimeView
        self.inputTextField.becomeFirstResponder()
        self.delegate = cell as! innerRegularisationCell
    }
    
    
    func OpenPickerForReason(cell : UITableViewCell)  {
        
        self.inputBar.isHidden = true
        self.textFromAlert = true
        self.TextfiledContainerView.isUserInteractionEnabled = true
        self.delegate = cell as! innerRegularisationCell
        self.PickerView.reloadAllComponents()
        self.inputTextField.inputView = self.inputPickerView
        self.inputTextField.becomeFirstResponder()
        self.changeCollectionViewVisibilityStatus(shouldShow: false)
        
    }
    
    
    func SubmitRegularisation(_ apiString  : String)  {
        self.textFromAlert = false
        _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {_ in
            self.composeMessage(type: .text, visibilty: .yes, content: apiString, approvaltype: true, approvalText: "Submitted")
        })
    }
    
    //MARK: covid button action
    @IBAction func clickCovidMenu(_ sender: Any) {
        //sosBttn.isHidden=true
        let typeCheck = "COVID-19"
        self.composeMessage(type: .text, visibilty: .yes, content: typeCheck, approvaltype: false, approvalText: "")
    }
    
}

/*
 // already having copy in orignal file
 extension String {
 
 func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
 let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
 let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
 
 return ceil(boundingBox.width)
 }
 
 func height(withConstrainedHeight width: CGFloat, font: UIFont) -> CGFloat {
 let constraintRect = CGSize(width: width , height: .greatestFiniteMagnitude)
 let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
 
 return boundingBox.height
 }
 }
 */

/*
 extension UIView {
 
 // OUTPUT 1
 func dropShadow(scale: Bool = true) {
 layer.masksToBounds = false
 layer.shadowColor = UIColor.black.cgColor
 layer.shadowOpacity = 0.5
 layer.shadowOffset = CGSize(width: -1, height: 1)
 layer.shadowRadius = 1
 layer.shadowPath = UIBezierPath(rect: bounds).cgPath
 layer.shouldRasterize = true
 layer.rasterizationScale = scale ? UIScreen.main.scale : 1
 }
 
 }
 */
//
//extension ChatVC {
//    func loadExpressoScreen (newsletterId: String) {
//        let storyBoard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
//        let notificationController = storyBoard.instantiateViewController(withIdentifier: "NewsLetterListViewController") as! NewsLetterListViewController
//        notificationController.selectedNewsletterID = newsletterId
//        self.navigationController?.pushViewController(notificationController, animated: true)
//
//    }
//
//}


