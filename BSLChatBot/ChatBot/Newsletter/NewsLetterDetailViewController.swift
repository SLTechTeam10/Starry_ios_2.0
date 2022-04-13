//
//  NewsLetterDetailViewController.swift
//  BSLChatBot
//
//  Created by Niharika on 12/08/20.
//  Copyright © 2020 Santosh. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation
import AVKit

class NewsLetterDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    let navigationTitle  = "Expresso"
    let backImageName = "back_arrow"
    
    var spinner: UIView?
    var newsletters: [NewsletterModel]?
    var newsletter_id: String?
    var newsletter_index = 0

    var avpController = AVPlayerViewController()

    var player = AVPlayer()

    var sections: [Section] = []

    var isImage = Bool()
    
    @IBOutlet var  lblTitle: UILabel!
     @IBOutlet var  lblSubTitle: UILabel!
    @IBOutlet weak var bannerImageView: UIImageView!
    
    @IBOutlet var tableview : UITableView!
    @IBOutlet var headerView : UIView!
    @IBOutlet var HeaderTitleView : UIView!
    @IBOutlet var webView : WKWebView!

    @IBOutlet var heightTableView : NSLayoutConstraint!
    
    @IBOutlet var headerViewHeight: NSLayoutConstraint!
    
    @IBOutlet var headerViewYCordinate: NSLayoutConstraint!


    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        
        if(self.newsletters!.count == 0 ){
             let delegate = UIApplication.shared.delegate as! AppDelegate
                        delegate.retrieveNewsletterData()
            delegate.retrieveUtilityData()

                       let storyboard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
                       let newsletterListViewController =
                           storyboard.instantiateViewController(withIdentifier: "NewsLetterListViewController") as! NewsLetterListViewController

                       let newsLetterFromDatabase = newsletterListViewController.convertToJSONArray(moArray: appdelegate.newsletterListGlobal)
                       let newsLetterArray = newsletterListViewController.newsLetterData(arr: newsLetterFromDatabase as Any)
                       sortNewsletterDataResponse(array : newsLetterArray)
                       var completeList: [NewsletterModel] = []
                       for section in sections {
                           completeList.append(contentsOf: section.items)
                       }
                       self.newsletters = completeList
                       let intValueNewsletterID = Int(self.newsletter_id!)!

                       let index = self.newsletters!.index{ $0.date  == intValueNewsletterID }
                       self.newsletter_index = index!
    }
        
         if let newsletters = self.newsletters {
            let newsletterModel: NewsletterModel = newsletters[self.newsletter_index]
            self.newsletter_id = String(newsletterModel.date)
            
            let leftSwipeRecognizer : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
            let rightSwipeRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
            leftSwipeRecognizer.direction = .left
            rightSwipeRecognizer.direction = .right
            self.view.addGestureRecognizer(leftSwipeRecognizer)
            self.view.addGestureRecognizer(rightSwipeRecognizer)
            self.tableview.reloadData()
            
        }
        self.newsletters![2].videoURL = "https://youtu.be/h924kiLlvA0"
        tableview.estimatedRowHeight = 100
        tableview.rowHeight = UITableView.automaticDimension

        tableview.alwaysBounceVertical = true
     
//        avpController.view.frame.size.height = videoView.frame.size.height
//
//        avpController.view.frame.size.width = videoView.frame.size.width
//
//        self.videoView.addSubview(avpController.view)
        
        loadNewsLetterDetails(newsletterIndex:self.newsletter_index, direction: .fromTop)
    }
        func sortNewsletterDataResponse(array : [NewsletterModel]){
           var groupByCategory = Dictionary(grouping: array) { (news) -> String in
                return news.dateHeader
            }

            let formatter : DateFormatter = {
                let df = DateFormatter()
                df.locale = Locale(identifier: "en_US_POSIX")
                df.dateFormat = "MMMM yyyy"
                return df
            }()

            for (key, value) in groupByCategory
            {
                groupByCategory[key] = value.sorted(by: { $0.date > $1.date })
            }
           
            let sortedArrayOfMonths = groupByCategory.sorted( by: { formatter.date(from: $0.key)! > formatter.date(from: $1.key)! })

           for (problem, groupedReport) in sortedArrayOfMonths {
              
                   sections.append(Section(name: problem, items:groupedReport))

               
            }
    
               
       }
    func animatePage(direction: CATransitionSubtype) {
        let animation = CATransition()
        animation.duration = 0.25
        
        animation.type = .moveIn
        animation.subtype = direction
        self.view.layer.add(animation, forKey: "newsletterPageChange")
    }
    
    func loadNewsLetterDetails(newsletterIndex:Int, direction: CATransitionSubtype) {
        // set the title
        print("Loading newsletter Index: \(newsletterIndex)")
        self.bannerImageView.image = nil

        if let newsletters = self.newsletters {
            guard newsletters.count > newsletterIndex else { return }
            guard -1 < newsletterIndex else { return }
            
            self.title = String(newsletterIndex + 1) + " of " + String(newsletters.count)
            let newsletterContent = newsletters[newsletterIndex].descriptions
            if (newsletterContent != nil) {
               
                var subTitleString : String!
                                           
                                           if ((newsletters[newsletterIndex].subTitle) != nil) {
                                                      subTitleString = newsletters[newsletterIndex].subTitle
                                                  }
                                           if ((newsletters[newsletterIndex].category) != nil) {
                                               subTitleString += (" | " + newsletters[newsletterIndex].category)
                                           }
                                           if((newsletters[newsletterIndex].newsletterBy) != nil){
                                               subTitleString += (" | " + newsletters[newsletterIndex].newsletterBy)

                                           }
                                           self.lblTitle.text = newsletters[newsletterIndex].title ?? ""
                                           self.lblSubTitle.text = subTitleString ?? ""
                self.tableview.reloadData()
                if(newsletters[newsletterIndex].videoURL != nil && newsletters[newsletterIndex].videoURL != "" ){
                 //  self.videoView.isHidden = false
                    self.isImage = false
                    self.webView.isHidden = false
                    self.bannerImageView.isHidden = true
                    self.headerViewYCordinate.constant = 0

                    NSLayoutConstraint.deactivate([self.headerViewHeight])

                    self.headerViewHeight = self.headerView.heightAnchor.constraint(equalTo: self.headerView.widthAnchor, multiplier: 0.5)

                    NSLayoutConstraint.activate([self.headerViewHeight])

                    let videoURL = "https://www.youtube.com/watch?v=Oa9aWdcCC4o"

                    
                    let videoID = videoURL.youtubeID

                    guard let youtubeURL = URL(string: "https://www.youtube.com/embed/\(videoID!)") else {
                    return
                    }
                    webView.load(URLRequest(url: youtubeURL))


                }
                else{
                if(newsletters[newsletterIndex].headerImageURL != nil && newsletters[newsletterIndex].headerImageURL != "" ){
                    self.isImage = true
                    self.bannerImageView.isHidden = false

                   // self.videoView.isHidden = true
                    self.webView.isHidden = true

                    self.setImageFromUrl(ImageURL: newsletters[newsletterIndex].headerImageURL)
                    self.headerViewYCordinate.constant = 0

                }
                else{
                    self.isImage = false
                    self.bannerImageView.isHidden = false

                 //   self.videoView.isHidden = false
                    self.webView.isHidden = false


                   // self.headerViewYCordinate.constant = self.headerView.frame.size.height - self.HeaderTitleView.frame.size.height
                    self.headerViewYCordinate.constant = self.headerView.frame.size.height

                    //self.headerViewYCordinate.constant = headerViewHeight.constant-80

                }
                }
                self.animatePage(direction: direction)
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableview.scrollToRow(at: indexPath, at: .top, animated: false)
                appdelegate.updateReadStatusNewsletter(id: newsletters[newsletterIndex].attribute_id!)

//                let storyboard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
//                let newsletterListViewController =
//                    storyboard.instantiateViewController(withIdentifier: "NewsLetterListViewController") as! NewsLetterListViewController
//
//                newsletterListViewController.updateReadStatus(id: newsletters[newsletterIndex].attribute_id!)

            }

        }
        else {
            self.title = "Expresso"
        }
    }

    func setImageFromUrl(ImageURL :String){
        URLSession.shared.dataTask( with: NSURL(string:ImageURL)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                if let data = data {
                    let image = UIImage(data: data)
                    self.bannerImageView.image = UIImage(data: data)
                    NSLayoutConstraint.deactivate([self.headerViewHeight])

                        // Activate new height constraint
                    self.headerViewHeight = self.headerView.heightAnchor.constraint(equalTo: self.headerView.widthAnchor, multiplier: image!.size.height / image!.size.width)

                    NSLayoutConstraint.activate([self.headerViewHeight])
                }
            }
        }).resume()
    }
    @objc func handleSwipe (swipe : UISwipeGestureRecognizer) {
        if let newsletters = self.newsletters {
            if (swipe.direction == .right && self.newsletter_index > 0) {
                self.newsletter_index -= 1
                self.loadNewsLetterDetails(newsletterIndex: self.newsletter_index, direction: .fromLeft)
            }
            else if (swipe.direction == .left && self.newsletter_index < newsletters.count - 1) {
                self.newsletter_index += 1
                self.loadNewsLetterDetails(newsletterIndex: self.newsletter_index, direction: .fromRight)
            }
        }
    }
    
    private func setupNavigationController() {
        let backImage = UIImage(named: backImageName)?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backImagePressed))
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        if #available(iOS 15, *)
        {
               // do nothing auto
        }else{
            self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "header"), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.titleTextAttributes = textAttributes
        }
       
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.setToolbarHidden(true, animated: false)
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "header"), for: .default)
        //self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @objc func backImagePressed() {
        navigationController?.popViewController(animated: true)
    }
    
    
}

extension NewsLetterDetailViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        spinnerView.addSubview(ai)
        onView.addSubview(spinnerView)
        
        self.spinner = spinnerView
    }
    
    func removeSpinner() {
        self.spinner?.removeFromSuperview()
        self.spinner = nil
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView,
                   estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if(indexPath.row == 0){
            let cellNews:NewsletterDetailCell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier") as! NewsletterDetailCell

            let newsletterContent = self.newsletters![newsletter_index].descriptions
            if (newsletterContent != nil) {
                let data = Data(newsletterContent!.utf8)
//                if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                    if let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {

                    attributedString.addAttribute(.font, value:UIFont(name: "Montserrat-Regular", size: 18.0)!, range: NSRange(location: 0, length: attributedString.length))

                    cellNews.htmlLabel.attributedText = attributedString
                }
               


            }
            return cellNews
        }
        if(self.newsletters![newsletter_index].footerImageURL != nil && self.newsletters![newsletter_index].footerImageURL != ""){
            
        if(indexPath.row == 1){
            let cellImage:NewsletterDetailImageFooterCell = tableView.dequeueReusableCell(withIdentifier: "footerImageCell") as! NewsletterDetailImageFooterCell
            let imageURL = self.newsletters![newsletter_index].footerImageURL
            if(imageURL != nil && imageURL != ""){
            cellImage.footerImage.setImageFromUrl(ImageURL: imageURL ?? "")
                updateCell(withImage :cellImage.footerImage.image! , cell : cellImage)
                        cellImage.setNeedsLayout()

            }
            return cellImage

            }
        }
        return  UITableViewCell()

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 60
        }
    }
    func updateCell(withImage image: UIImage , cell : NewsletterDetailImageFooterCell) {

            // Deactivate old height constraint
        NSLayoutConstraint.deactivate([cell.footerImageHeight])

            // Activate new height constraint
        cell.footerImageHeight = cell.footerImage.heightAnchor.constraint(equalTo: cell.footerImage.widthAnchor, multiplier: image.size.height / image.size.width)
        NSLayoutConstraint.activate([cell.footerImageHeight])
            }
    


    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y =  scrollView.contentOffset.y
        if(isImage == true){
//            self.headerViewYCordinate.constant = min(y,250-80)
           // self.headerViewYCordinate.constant = min(y,self.headerView.frame.size.height - self.HeaderTitleView.frame.size.height)
            self.headerViewYCordinate.constant = min(y,self.headerView.frame.size.height)


        }
        print ("self.headerViewYCordinate.constant",self.headerViewYCordinate.constant)
    }
}



extension String {
var youtubeID: String? {
let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
let range = NSRange(location: 0, length: count)
guard let result = regex?.firstMatch(in: self, range: range) else {
return nil
}
return (self as NSString).substring(with: result.range)
}
}


