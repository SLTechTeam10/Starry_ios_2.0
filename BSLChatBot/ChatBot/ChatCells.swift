//
//  ChatCells.swift
//  InfogainifyApp
//
//  Created by Rajiv on 07/05/18.
//  Copyright © 2018 Saurabh. All rights reserved.
//

import Foundation
import UIKit
import MapKit


enum labelColor  {
  typealias RawValue = UIColor
  case black
  case red
  case green
}

class MenuCell: UITableViewCell {
    

    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var txtLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}


class SenderCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: RoundedImageView!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageBackground: UIImageView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet var centeralian: NSLayoutConstraint!
    @IBOutlet var topalian: NSLayoutConstraint!
    
    func clearCellData()  {
        self.message.text = nil
        self.message.isHidden = false
    
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.message.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.outerView.layer.maskedCorners = [
            .layerMaxXMaxYCorner,
            .layerMinXMaxYCorner,
            .layerMaxXMinYCorner
        ]
    }
    
    
}
protocol TimeCellDelegate: class {
    func zoomPickerdone(timeSelected: Date)
}


class TimeCell: UITableViewCell {
    @IBOutlet weak var zoomTimePicker: UIDatePicker!
    weak var timeCellDelegate: TimeCellDelegate?

    var preSelectedDate: String? {
          didSet {
             let dateformatter = DateFormatter()
             dateformatter.dateFormat =  "hh:mm a"
            let date = dateformatter.date(from: preSelectedDate!)
            zoomTimePicker.date = date!
            
            

          }
      }
    
   @IBAction func doneButtonClicked(sender: UIBarButtonItem) {
    timeCellDelegate?.zoomPickerdone(timeSelected: zoomTimePicker!.date)
        }

}

class ReceiverCell: UITableViewCell {
    
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageBackground: UIImageView!
    var gradientLayer: CAGradientLayer!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet var centeralian: NSLayoutConstraint!
    @IBOutlet var topalian: NSLayoutConstraint!
    
    func clearCellData()  {
        self.message.text = nil
        self.message.isHidden = false
        
    }
    

    
    override func awakeFromNib() {
        super.awakeFromNib()

                self.outerView.layer.maskedCorners = [
                    .layerMaxXMaxYCorner,
                    .layerMinXMaxYCorner,
                    .layerMinXMinYCorner
                ]
   
    }
    
    
}



class LeaveCell: UITableViewCell,UICollectionViewDelegate ,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var leaveCollectionView: UICollectionView!
  
    var isEnable:Bool?
    
    var menuItems: [LeaveTypes]? {
        didSet {
            
            if isEnable == true {
                self.leaveCollectionView.reloadData()
                self.leaveCollectionView.setContentOffset(.zero, animated: true)
                self.leaveCollectionView.isUserInteractionEnabled = true
                self.leaveCollectionView.allowsSelection = true
                
            } else{
                self.leaveCollectionView.isUserInteractionEnabled = false
                self.leaveCollectionView.allowsSelection = false
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.menuItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "leaveCell", for: indexPath as IndexPath) as! CollectionLeaveCell
        
        let leaveObj = self.menuItems?[indexPath.item]
        cell.leavecount.text = leaveObj!.leaveCount as? String ?? "0"
        cell.leavename.text =  leaveObj!.leaveType
        cell.leavename.backgroundColor = UIColor.init(hexString: leaveObj!.leaveBackgroudColor)
        cell.leavename.layer.cornerRadius = 13
        cell.leavename.clipsToBounds = true
        cell.leavename.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        cell.leavecount.textColor = UIColor.init(hexString: leaveObj!.leaveTextColor)
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let viewController = self.viewControllerForTableView as? ChatVC {
            viewController.collectionView(self.leaveCollectionView, didSelectItemAt: indexPath)
        }
    }
    
    // MARK: - UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: 100, height: 100)
    }
    
}



class RegularizationCell: UITableViewCell,UITableViewDelegate,UITableViewDataSource {
    
    
    
    @IBOutlet weak var tableView: UITableView!

    var superTable : UITableView?
    
    var regularizationData: [RegularizationModel]? {
        didSet {
            self.tableView.reloadData()
            self.tableView.setContentOffset(.zero, animated: true)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.estimatedRowHeight = 270
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    
    
    var rowType : Bool?
    var rowHeightType = -1
    
    
    
    //MARK: Table Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regularizationData?.count ?? 0
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "innerRegularisationCell", for: indexPath) as! innerRegularisationCell
        cell.regularizationData = regularizationData![indexPath.row]
        cell.delegate = tableView
        
        cell.expendButton.addTarget(self, action: #selector(innerexpendButton(_:)), for: .touchUpInside)
        cell.expendButton.tag = indexPath.row
        cell.superexpendButton.tag = indexPath.row
       
        cell.inTimeBtn.addTarget(self, action: #selector(inTimeButton(_:)), for: .touchUpInside)
        cell.inTimeBtn.tag = indexPath.row
        
        cell.outTimeBtn.addTarget(self, action: #selector(outTimeButton(_:)), for: .touchUpInside)
        cell.outTimeBtn.tag = indexPath.row
        
        cell.reasonExpendButton.addTarget(self, action: #selector(reasonExpendButton(_:)), for: .touchUpInside)
        cell.reasonExpendButton.tag = indexPath.row
        cell.reasonsuperBtn.tag = indexPath.row
        
        cell.submitButton.addTarget(self, action: #selector(submitButton(_:)), for: .touchUpInside)
        cell.submitButton.tag = indexPath.row
        
        cell.cancelButton.addTarget(self, action: #selector(cancelButton(_:)), for: .touchUpInside)
        cell.cancelButton.tag = indexPath.row
        
        if indexPath.row == self.rowHeightType {
            cell.subViewHeight.constant = 163
            cell.expendButton.isSelected = true
        } else {
            cell.subViewHeight.constant = 0
            cell.expendButton.isSelected = false
        }

        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        if indexPath.row == self.rowHeightType {
            return 263
        } else {
            return 100
        }
    }
    
  
    
    @objc func innerexpendButton(_ sender: UIButton) {

          let cell = tableView.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as! innerRegularisationCell
          var ExtraHeight:CGFloat = 0
        
          if cell.subViewHeight.constant == 0 {
              cell.expendButton.isSelected = true
              cell.subViewHeight.constant = 163
              self.rowHeightType = sender.tag
              ExtraHeight = 163
          } else if cell.subViewHeight.constant == 163  {
              cell.subViewHeight.constant = 0
              self.rowHeightType = -1
              cell.expendButton.isSelected = false
              ExtraHeight = 0
          }
        
         if let viewController = self.viewControllerForTableView as? ChatVC {
            viewController.extraHeight = ExtraHeight
            viewController.tableView.beginUpdates()
            viewController.tableView.endUpdates()
            viewController.ImplementTimer()
         }

         self.tableView.beginUpdates()
         self.tableView.endUpdates()
        
            
        _ = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: {_ in
            if self.tableView.contentOffset.y  >= (self.tableView.contentSize.height - self.tableView.frame.size.height) {
                self.tableView.scrollToRow(at: IndexPath.init(row: sender.tag, section: 0), at: .top, animated: true)
                self.tableView.setNeedsLayout()
            }
        })
      
    }
    
    
    
    
    
    @IBAction func reasonBtn(_ sender: UIButton) {
        self.reasonExpendButton(sender)
    }
    
    
    
    @IBAction func superexpendBtn(_ sender: UIButton) {
        self.innerexpendButton(sender)
    }
    
    
    
    @objc func inTimeButton(_ sender: UIButton) {
        let cell = tableView.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as! innerRegularisationCell
        cell.tag = 2
        if let viewController = self.viewControllerForTableView as? ChatVC {
           viewController.OpenTimePickerForCheck(cell: cell)
        }
    }
    
    
    
    @objc func outTimeButton(_ sender: UIButton) {
        let cell = tableView.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as! innerRegularisationCell
        cell.tag = 3
        if let viewController = self.viewControllerForTableView as? ChatVC {
            viewController.OpenTimePickerForCheck(cell: cell)
        }
    }
    
    
    
    @objc func reasonExpendButton(_ sender: UIButton) {
        
        let cell = tableView.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as! innerRegularisationCell
        cell.tag = sender.tag
        if let viewController = self.viewControllerForTableView as? ChatVC {
         viewController.OpenPickerForReason(cell: cell)
        }

    }
    
    
    @objc func submitButton(_ sender: UIButton) {
        
        let cell = tableView?.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as! innerRegularisationCell
        cell.tag = sender.tag
           
        self.innerexpendButton(sender)
        let apiString =  "REG_SUBMIT:\(cell.regularizationData?.roster_Date ?? ""),\(cell.regularizationData?.reasonValue ?? ""),\(cell.regularizationData?.checkIn ?? ""),\(cell.regularizationData?.checkOut ?? "")"
            
        if let viewController = self.viewControllerForTableView as? ChatVC {
            viewController.SubmitRegularisation(apiString)
        }
    }
    
    
    @objc func cancelButton(_ sender: UIButton) {
        self.innerexpendButton(sender)
    }
    
    
}



class innerRegularisationCell: UITableViewCell  {
    
   
    @IBOutlet weak var typeName: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var timeInLbl: UILabel!
    @IBOutlet weak var timeOutLbl: UILabel!
    @IBOutlet weak var reasonLbl: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet var subViewHeight: NSLayoutConstraint!
    @IBOutlet weak var expendButton: UIButton!
    @IBOutlet weak var superexpendButton: UIButton!
    
    
    @IBOutlet weak var reasonExpendButton: UIButton!
    @IBOutlet weak var reasonsuperBtn: UIButton!
    @IBOutlet weak var inTimeBtn: UIButton!
    @IBOutlet weak var outTimeBtn: UIButton!
    weak var delegate: UITableView?
    var isOpened:Bool = true
    

    
    var regularizationData: RegularizationModel? {
        didSet {
            
            typeName.text = regularizationData?.regularizationType!
            DateLabel.text = regularizationData?.roster_Date!
            timeInLbl.text = regularizationData?.checkIn!
            timeOutLbl.text = regularizationData?.checkOut!

            reasonLbl.text = regularizationData?.reasonValue
            
            self.setSubmitButton()
            
        }
    }
    
    var regularizationUpdateData: String? {
        didSet {
            self.regularizationData?.submitFlag = true
            if self.tag == 2 {
                self.regularizationData?.checkIn = regularizationUpdateData
                self.timeInLbl.text = regularizationUpdateData
                if self.timeInLbl.textColor == UIColor.red {
                   self.timeInLbl.textColor = UIColor.darkGray
                }
            } else if self.tag == 3 {
                self.timeOutLbl.text = regularizationUpdateData
                self.regularizationData?.checkOut = regularizationUpdateData
                if self.timeOutLbl.textColor == UIColor.red {
                   self.timeOutLbl.textColor = UIColor.darkGray
                }
            }
            
            self.setSubmitButton()
        }
    }
    
    
    var regularizationUpdateReasonData: String? {
        didSet {
           
            self.regularizationData?.reasonValue = regularizationUpdateReasonData!
            self.reasonLbl.text = regularizationUpdateReasonData
            
            self.setSubmitButton()
        }
    }
    
    
    func setSubmitButton() {
        
        if self.regularizationData?.checkIn! == "TimeMissing" || self.regularizationData?.checkOut! == "TimeMissing" || self.regularizationData?.reasonValue == "Reason*" {
            self.submitButton.isEnabled = false
            self.submitButton.alpha = 0.5
        } else {
            self.submitButton.isEnabled = true
            self.submitButton.alpha = 1
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    @IBAction func cancelButton(_ sender: UIButton) {
        
    }
    
}


class LocationViewCell: UITableViewCell, UICollectionViewDelegate ,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIScrollViewDelegate{
    
    @IBOutlet weak var LocationCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet var pageControlHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    var addressItems: [MapModel]? {
        didSet {
            self.LocationCollectionView.reloadData()
            self.LocationCollectionView.setContentOffset(.zero, animated: true)
            if addressItems!.count > 1 {
               self.configurePageControl()
            } else {
               self.pageControlHeight.constant = 0
               self.pageControl.isHidden = true
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.addressItems!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddressCell", for: indexPath as IndexPath) as! AddressCollectionViewCell
        cell.mapObject = addressItems![indexPath.item]
        //cell.lblAddress.text = mapObj.Address
    
        return cell
        
    }
    

    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: SCREEN_WIDTH, height: self.LocationCollectionView.frame.size.height )
    }
    

    
    func configurePageControl() {
        self.pageControl.numberOfPages = self.addressItems!.count
        self.pageControlHeight.constant = 37
        self.pageControl.isHidden = false
    }
    
    
    //MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == LocationCollectionView {
            let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
            pageControl.currentPage = Int(pageNumber)
         }
    }
    
    // MARK: TO CHANGE WHILE CLICKING ON PAGE CONTROL
    @IBAction func changePage(_ sender: UIPageControl) {
        let x = CGFloat(pageControl.currentPage) * LocationCollectionView.frame.size.width
        LocationCollectionView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    
    
}





class EmployeeCard: UITableViewCell, UICollectionViewDelegate ,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIScrollViewDelegate  {
    
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet var pageControlHeight: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
        }
        
        
        var cardItems: [EmployeeModel]? {
            didSet {
                self.cardCollectionView.reloadData()
                self.cardCollectionView.setContentOffset(.zero, animated: true)
                if cardItems!.count > 1 {
                   self.configurePageControl()
                } else {
                   self.pageControlHeight.constant = 0
                   self.pageControl.isHidden = true
                }
            }
        }
        
        // MARK: - UICollectionViewDataSource
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.cardItems!.count
        }
        
    
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmployeeCell", for: indexPath as IndexPath) as! EmployeeCell
            cell.empCardComponents = cardItems![indexPath.item]
        
            return cell
        }
        

        
        public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
            return CGSize(width: SCREEN_WIDTH, height: self.cardCollectionView.frame.size.height )
        }

        
        func configurePageControl() {
            self.pageControl.numberOfPages = self.cardItems!.count
            self.pageControlHeight.constant = 37
            self.pageControl.isHidden = false
        }
        
        
        //MARK: UIScrollViewDelegate
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if scrollView == cardCollectionView {
                let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
                pageControl.currentPage = Int(pageNumber)
             }
        }
        
        // MARK: TO CHANGE WHILE CLICKING ON PAGE CONTROL
        @IBAction func changePage(_ sender: UIPageControl) {
            let x = CGFloat(pageControl.currentPage) * cardCollectionView.frame.size.width
            cardCollectionView.setContentOffset(CGPoint(x:x, y:0), animated: true)
        }
    
    
}




class ApprovalTableCell: UITableViewCell,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
  //@IBOutlet var tableheight: NSLayoutConstraint!
    
    var approvalData: [ApprovalLists]? {
        didSet {
            self.tableView.reloadData()
            self.tableView.setContentOffset(.zero, animated: true)
        }
    }
    
    var listType : Bool?
    
    
    //MARK: Table Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return approvalData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //innercancelTableViewCell
       
        var identifier = "innerTableViewCell"
        
        if self.listType == true {
            identifier = "innercancelTableViewCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! innerTableViewCell
        cell.approvalRow = self.approvalData![indexPath.row]
        cell.listType = self.listType
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
//        if self.listType == false {
//              return 140
//        }
        return UITableView.automaticDimension
    }

    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cell = tableView.cellForRow(at: indexPath) as! innerTableViewCell
        if cell.listType == false {
            
                let action = UIContextualAction(style: .normal, title: "REJECT", handler:{ (action, view, completionHandler) in
                    let type = (cell.approvalRow!.leavetype!).split(separator: " ") 
                    print(type.last as Any)
                let apiString = "\(cell.approvalRow?.userid ?? ""),\(type.last ?? ""),\(cell.approvalRow?.leaveFrom ?? ""),\(cell.approvalRow?.leaveTo ?? ""),Reject"
                
              if let viewController = self.viewControllerForTableView as? ChatVC {
                viewController.MakeApproveANDRejectForStatusReply(apiString, apprvaltext:  cell.approvalRow!.leavetype! + " - Rejected")
              }
                  print("success")
                  completionHandler(true)
            })
            
            action.image = #imageLiteral(resourceName: "reject")
            action.backgroundColor = .red
            let configuration = UISwipeActionsConfiguration(actions: [action])
            return configuration
        }
     
        return nil
    }
    
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cell = tableView.cellForRow(at: indexPath) as! innerTableViewCell
        let title = cell.listType == true ? "CANCEL" : "APPROVE"
      
        
        let action = UIContextualAction(style: .normal, title: title ,
                                        handler:{ (action, view, completionHandler) in
            
                                            
            var apiString = ""
            var userReply = ""
            let type = (cell.approvalRow!.leavetype!).split(separator: " ")
            if title == "APPROVE" {
            
                apiString = "\(cell.approvalRow?.userid ?? ""),\(type.last ?? ""),\(cell.approvalRow?.leaveFrom ?? ""),\(cell.approvalRow?.leaveTo ?? ""),Approve"
            
                userReply =  "Approving "    + (cell.approvalRow!.leavetype!).firstLowercased + "\n"  + cell.DateLabel.text!
                
            } else {
              
                apiString = "CANCEL_REASON:\(type.last ?? ""),\(cell.approvalRow?.leaveFrom ?? ""),\(cell.approvalRow?.leaveTo ?? ""),\(cell.approvalRow?.reason ?? "")"
               
                userReply =  "Cancelling " + (cell.approvalRow!.leavetype!).firstLowercased + "\n"  + cell.DateLabel.text!
            }
             
                                            
             if let viewController = self.viewControllerForTableView as? ChatVC {
                viewController.MakeApproveANDRejectForStatusReply(apiString, apprvaltext: userReply)
             }
                                            
            print("success")
            completionHandler(true)
        })
        
        action.image = cell.listType == true ? #imageLiteral(resourceName: "reject") :  #imageLiteral(resourceName: "approvall")
        action.backgroundColor = cell.listType == true ? #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1) : #colorLiteral(red: 0, green: 0.5019607843, blue: 0, alpha: 1)
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
       
    }
    
   
}


class innerTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var typeName: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var usernameview: UIView!
    @IBOutlet weak var reasonlbl: UILabel!
    var listType : Bool?
    @IBOutlet var reasonViewHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var reasonView: UIView!
    
    var approvalRow: ApprovalLists? {
        didSet {
            
            if UserName != nil {
                UserName.text = approvalRow?.username
            }
            
            typeName.text = approvalRow!.leavetype!
            DateLabel.text = approvalRow?.noOfDays as! NSNumber == 1 ? approvalRow!.leaveFrom! : "From " + approvalRow!.leaveFrom! + " To " + approvalRow!.leaveTo!
            
            if usernameview != nil {
                usernameview.RoundUpparTwoCorners(10.0)
            }
            
            if reasonlbl != nil {
                if approvalRow!.leavetype!.contains("OD") || approvalRow!.leavetype!.contains("ODD") {
                    reasonlbl.text = approvalRow?.reason ?? ""
                    reasonViewHeight.constant = 30
                    //reasonView.isHidden = false
                } else {
                    reasonlbl.text = approvalRow?.reason ?? ""
                    reasonViewHeight.constant = 0
                    //reasonView.isHidden = true
                }
            }
            
        }
    }
    
    var serviceRow: ServiceModelClass? {
        
        didSet {
           
            UserName.text = serviceRow?.refId
            statusLbl.text = serviceRow?.currentState
            typeName.text = serviceRow!.title!
            DateLabel.text = serviceRow?.creationTime
            usernameview.RoundUpparTwoCorners(10.0)
            
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.outerView.layer.maskedCorners = [
            .layerMaxXMaxYCorner,
            .layerMinXMaxYCorner,
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
    }
    
    
    
    
}


class NewApprovalTableCell: UITableViewCell {
    
      @IBOutlet weak var UserName: UILabel!
      @IBOutlet weak var typeName: UILabel!
      @IBOutlet weak var DateLabel: UILabel!
      @IBOutlet weak var outerView: UIView!
      @IBOutlet weak var usernameview: UIView!
      @IBOutlet weak var reasonlbl: UILabel!
      var listType : Bool?
      @IBOutlet var reasonViewHeight: NSLayoutConstraint!
      @IBOutlet weak var reasonView: UIView!
    
    
      var approvalRow: ApprovalLists? {
          didSet {
              
              if UserName != nil {
                  UserName.text = approvalRow?.username
              }
              
              typeName.text = approvalRow!.leavetype!
              DateLabel.text = approvalRow?.noOfDays as! NSNumber == 1 ? approvalRow!.leaveFrom! : "From " + approvalRow!.leaveFrom! + " To " + approvalRow!.leaveTo!
              
              if usernameview != nil {
                  usernameview.RoundUpparTwoCorners(10.0)
              }
              
              if reasonlbl != nil {
                if approvalRow!.leavetype!.contains("OD") || approvalRow!.leavetype!.contains("ODD") || approvalRow!.leavetype!.contains("Regularisation") || approvalRow!.leavetype!.contains("Regularization") {
                      reasonlbl.text = approvalRow?.reason ?? ""
                      reasonViewHeight.constant = 30
                      //reasonView.isHidden = false
                  } else {
                      reasonlbl.text = approvalRow?.reason ?? ""
                      reasonViewHeight.constant = 0
                      //reasonView.isHidden = true
                  }
              }
              
          }
      }
    
      
    
    
      override func awakeFromNib() {
          super.awakeFromNib()
          self.outerView.layer.maskedCorners = [
              .layerMaxXMaxYCorner,
              .layerMinXMaxYCorner,
              .layerMinXMinYCorner,
              .layerMaxXMinYCorner
          ]
      }
    
    
}

class ApprovalAllTableCell: UITableViewCell {
    
      @IBOutlet weak var approveBtn: UIButton!
      @IBOutlet weak var outerView: UIView!
    
      override func awakeFromNib() {
          super.awakeFromNib()
          /*self.outerView.layer.maskedCorners = [
              .layerMaxXMaxYCorner,
              .layerMinXMaxYCorner,
              .layerMinXMinYCorner
          ]*/
      }
    

    
}




class ClaimTableCell: UITableViewCell,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var claimData: [ClaimModel]? {
        didSet {
            self.tableView.reloadData()
            self.tableView.setContentOffset(.zero, animated: true)
        }
    }
    
    var listType : Bool?
    
    
    //MARK: Table Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return claimData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "innerClaimTableCell", for: indexPath) as! innerClaimTableCell
        cell.claimRow = self.claimData![indexPath.row]
        //cell.listType = self.listType
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    
    
}

class innerClaimTableCell: UITableViewCell  {
    
    @IBOutlet weak var outerView: UIView!
    var listType : Bool?
    
    @IBOutlet weak var statuslabel: UILabel!
    @IBOutlet weak var amountlabel: UILabel!
    @IBOutlet weak var datelabel: UILabel!
    @IBOutlet weak var timelabel: UILabel!
    
    
    var claimRow: ClaimModel? {
        didSet {
            statuslabel.text = "Status: " + claimRow!.approval_status
            amountlabel.text = "Amount: " + claimRow!.amount
            datelabel.text = "Date: " + claimRow!.requested_date
            timelabel.text = "Time: " + claimRow!.requested_time
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.outerView.layer.maskedCorners = [
         .layerMaxXMaxYCorner,
         .layerMinXMaxYCorner,
         .layerMinXMinYCorner,
         .layerMaxXMinYCorner
         ]
    }
}

protocol CalendarCellDelegate: class {
    func didSelectedDates(fromDate: Date?, toDate: Date?, indexPath:IndexPath)
    func doneButtonClicked(indexPath: IndexPath)
    func cancelButtonClicked(indexPath: IndexPath)
}

class CalendarCell: UITableViewCell,KoyomiDelegate  {
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var DoneBtn: UIButton!
    @IBOutlet weak var CancelBtn: UIButton!
    var indexPath: IndexPath?
    weak var cellDelegate: CalendarCellDelegate?
    
    var selectionMode: Bool? {
        didSet {
            self.koyomi.selectionMode = selectionMode == true ?  .sequence(style: .semicircleEdge) : .single(style: .circle)
        }
    }
    
    var allowsSelection: Bool? {
        didSet {
            self.koyomi.allowsSelection = allowsSelection ?? false
        }
    }
    
    @IBOutlet weak var koyomi: Koyomi! {
        didSet {
            
            koyomi.circularViewDiameter = 0.5
            koyomi.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            koyomi.weeks = ("SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT")
            koyomi.style = .blue
            koyomi.dayPosition = .center
            //koyomi.selectionMode = .multiple(style: .circle)
           
            koyomi.sectionSeparatorColor = .clear
            koyomi.separatorColor = .clear
            koyomi.weekBackgrondColor = #colorLiteral(red: 0.9530000091, green: 0.9449999928, blue: 0.9449999928, alpha: 1)
            koyomi.weekColor = .darkGray
            koyomi.weekdayColor = .darkGray
          
            koyomi
                .setDayFont(size: 14)
                .setWeekFont(size: 10)
            koyomi.currentDateFormat = "MMMM YYYY"
            koyomi.calendarDelegate = self
            self.date.text = koyomi.currentDateString(withFormat:"MMMM YYYY")
            koyomi.setDayColor(.red, of: Date())

        }
    }
    
    override func prepareForReuse() {
        self.koyomi.unselectAll()
        self.koyomi.reloadData()
    }

    @objc func doneButtonClicked(_ sender: UIButton) {
        if(self.indexPath != nil) {
            cellDelegate?.doneButtonClicked(indexPath: self.indexPath!)
        }
    }
    
    @objc func cancelButtonClicked(_ sender: UIButton) {
        if(self.indexPath != nil) {
            cellDelegate?.cancelButtonClicked(indexPath: self.indexPath!)
        }
    }
    
    func clearCellData()  {
      self.koyomi.unselectAll()
    }
    
    func selectDates(fromDate: Date, toDate: Date)  {
        self.koyomi.select(date: fromDate, to: toDate)
        self.koyomi.reloadData()
    }
    
    func selectDates(dates: [Date])  {
        if dates.count != 0 {
           self.koyomi.select(dates: dates)
           self.koyomi.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.koyomi.unselectAll()
        self.DoneBtn.addTarget(self,
                               action: #selector(doneButtonClicked(_:)),
                               for: .touchUpInside)
        self.CancelBtn.addTarget(self,
                               action: #selector(cancelButtonClicked(_:)),
                               for: .touchUpInside)
    }
    
    @IBAction func tappedControl(_ sender: UIButton) {
        let month: MonthType = {
            switch sender.tag {
            case 1:  return .previous
            case 2:  return .next
            default: return .current
            }
        }()

        koyomi.display(in: month)
        self.date.text = koyomi.currentDateString(withFormat:"MMMM YYYY")
       // self.DoneBtn.isEnabled = false
    }
    
    
    
    //MARK: Koyomi Delegate
    func koyomi(_ koyomi: Koyomi, currentDateString dateString: String)
    {
        
    }
    
    func koyomi(_ koyomi: Koyomi, selectionColorForItemAt indexPath: IndexPath, date: Date) -> UIColor? {
        return  #colorLiteral(red: 0.3490196078, green: 0.2431372549, blue: 0.5215686275, alpha: 1)  //UIColor.init(red: 255.0/255, green: 98.0/255, blue: 103.0/255, alpha: 1)
    }
    
    
    
    func koyomi(_ koyomi: Koyomi, didSelect date: Date?, forItemAt indexPath: IndexPath)
    {

    }
    
    func koyomi(_ koyomi: Koyomi, shouldSelectDates date: Date?, to toDate: Date?, withPeriodLength length: Int) -> Bool {
        if(cellDelegate != nil && indexPath != nil) {
            cellDelegate?.didSelectedDates(fromDate: date, toDate: toDate, indexPath: indexPath!)
        }
        return true
    }
    

}

class FoodCell: UITableViewCell, UICollectionViewDelegate ,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var cafeteriaMenuView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var menuItems: [[String:Any]]? {
        didSet {
            self.cafeteriaMenuView.reloadData()
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.menuItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodMenuCell", for: indexPath as IndexPath) as! FoodCollectionViewCell
        cell.typeLabel.text = self.menuItems![indexPath.item]["name"] as? String
        cell.textLabel.text = self.menuItems![indexPath.item]["description"] as? String
        
        switch Int((self.menuItems![indexPath.item]["id"] as? String)!) {
        case 1:
            cell.imageView.image = UIImage(named:"breakfast")
            break;
        case 2:
            cell.imageView.image = UIImage(named:"lunch")
            break;
        case 3:
            cell.imageView.image = UIImage(named:"dinner")
            break;
        default:
            cell.imageView.image = UIImage(named:"breakfast")
            break;
        }
        
        return cell
        
    }
    
    // MARK: - UICollectionViewDelegate

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
            return CGSize(width: 280, height: 250)
    }
    
}


class HelpDeskTableCell: UITableViewCell,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
   
        var array: [ServiceModelClass]? {
            didSet {
                self.tableView.reloadData()
                self.tableView.setContentOffset(.zero, animated: true)
            }
        }
        
        var listType : Bool?
    var isZoom : Bool?
        
        //MARK: Table Delegates
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return array?.count ?? 0
        }
        
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
            let identifier = "innerTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! innerTableViewCell
            cell.serviceRow = self.array![indexPath.row]
            cell.listType = self.listType
            let item: ServiceModelClass =  self.array![indexPath.row]
            self.isZoom = item.zoomList
            return cell
        }
        
        
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
        }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
       //let cell = tableView.cellForRow(at: indexPath) as! innerTableViewCell
        //  let cell = tableView.cellForRow(at: indexPath) as! innerTableViewCell
        if self.listType == false {
//            let tableIndex =
//            print(tableIndex?.row)
            
//            if let viewController = self.viewControllerForTableView as? ChatVC {
//               let indexPath = viewController.tableView.indexPathForSelectedRow
//                
//            }
            
        let action = UIContextualAction(style: .normal, title: "CANCEL" ,
                                        handler:{ (action, view, completionHandler) in
            
                                       //     print(self.array)
                                            
                                          //  var apiString = "https://hrbot.bluestarindia.com/cancelServiceTicket"
                                            
                                            if(self.isZoom!){
                                                let meetingRefId = (self.array![indexPath.row].problemId)!
                                                var ticketDict = [String:Any]()
                                                        ticketDict = [
                                                                       "meetingId": meetingRefId
                                                                      ]
                                                                                                                                        
                                    if let viewController = self.viewControllerForTableView as? ChatVC {
                                                                                                viewController.cancelServiceTicket(ticketDict, index: indexPath , isZoom: true)
                                                                                              // viewController.MakeApproveANDRejectForStatusReply(apiString, apprvaltext: userReply)
                                                //                                                  let indexPathForremoveMessage = IndexPath.init(row: indexPath.row, section: 0)
                                                //                                                 viewController.cancelServiceTicket(ticketDict, index: indexPathForremoveMessage, msg: viewController.items[indexPath.row])
                                                                                               // viewController.cancelServiceTicket(ticketDict, index: indexPath )
                                                                                            }
                                            }
                                            else{
                                                let ticketProblemId = (self.array![indexPath.row].problemId)!

                                                var ticketDict = [String:Any]()
                                                                   ticketDict = [ "ticketNumber": ticketProblemId ]
                                                                                                                                        
                                                                                            if let viewController = self.viewControllerForTableView as? ChatVC {
                                                                                                viewController.cancelServiceTicket(ticketDict, index: indexPath ,isZoom: false)
                                                                                              // viewController.MakeApproveANDRejectForStatusReply(apiString, apprvaltext: userReply)
                                                //                                                  let indexPathForremoveMessage = IndexPath.init(row: indexPath.row, section: 0)
                                                //                                                 viewController.cancelServiceTicket(ticketDict, index: indexPathForremoveMessage, msg: viewController.items[indexPath.row])
                                                                                               // viewController.cancelServiceTicket(ticketDict, index: indexPath )
                                                                                            }
                                            }
                                           
 
 
                                            
                                            
//                                              var ticketDict = [String:Any]()
//                                             ticketDict = [ "ticketNumber": ticketProblemId ]
//
//                                            MessageManager.shared.send(message: "", visibility: .yes, toID: "UserId", approvalDict: ticketDict, completion: {(success, messages) in
//
//                                            })
                                            
                                            
                                            
           /*var apiString = ""
            var userReply = ""
            let type = (cell.approvalRow!.leavetype!).split(separator: " ")
        
              
                apiString = "CANCEL_REASON:\(type.last ?? ""),\(cell.approvalRow?.leaveFrom ?? ""),\(cell.approvalRow?.leaveTo ?? ""),\(cell.approvalRow?.reason ?? "")"
               
                userReply =  "Cancelling " + (cell.approvalRow!.leavetype!).firstLowercased + "\n"  + cell.DateLabel.text!
           
             
                                            
             if let viewController = self.viewControllerForTableView as? ChatVC {
                viewController.MakeApproveANDRejectForStatusReply(apiString, apprvaltext: userReply)
             }*/
                                            
            print("success")
            completionHandler(true)
        })
        
        action.image = #imageLiteral(resourceName: "reject")
            action.backgroundColor =  .red
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
        
        } else {
            return UISwipeActionsConfiguration()
        }
       
    }

        
        
    
}

