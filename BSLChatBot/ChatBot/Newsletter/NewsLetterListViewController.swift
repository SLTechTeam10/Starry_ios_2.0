//
//  NewsLetterListViewController.swift
//  BSLChatBot
//
//  Created by Niharika on 09/08/20.
//  Copyright © 2020 Santosh. All rights reserved.
//

import UIKit
import CoreData
import Firebase
class NewsLetterListViewController: UIViewController, NewsletterDetailDelegateProtocol,URLSessionTaskDelegate,URLSessionDataDelegate{
   
    

    //MARK:Static string
    let  navigationTitle = "Expresso"
    let backImageName = "back_arrow"
    let storyBoardName = "ChatBot"
    let noArticleFound = "There is no article in this magazine"
    let vcIdentifier = "NewsletterDetail"
    let cellIdentifier = "newsLetterCell"
    var selectedNewsletterID: String?
    var newsLetters:[NewsletterModel]?
    var shouldHideNavigationBar: Bool = true
    
    var originalNewsLetter:[NewsletterModel]?

    var sections: [Section] = []
    var sectionsFilter: [Section] = []
    var itemIndexSelected : Int = 0
    var filteredData = [Section]()
    
    @IBOutlet weak var newLetterListTblView: UITableView!

    var vSpinner : UIView?
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    var categories = [Any]()


//    var categories = ["All","Business","Corporate","EHS","Finance","HR", "Law","Marketing","Service","StarTalk","Technology"]
    var selectedCategory = ""
    var previousSelectedCategory = ""
    
    var arrImages = ["CyberApple","DidYouKnow","CyberShot","CyberByte","StarGazer"]
    
    var isSearching : Bool = false
    
    var counter : Int = 0
    @IBOutlet var searchBarYCordinate: NSLayoutConstraint!

    func sendUpdatedReadStatus(myData: [NewsletterModel]) {
        sectionsFilter.removeAll()
        sections.removeAll()
        sortNewsletterResponse(array : myData ,isSearch : isSearching)
       // self.newLetterListTblView.reloadData()

       }
    
    override func viewDidLayoutSubviews(){
        if (self.itemIndexSelected < self.categories.count) {

            let indexPath = IndexPath(row: self.itemIndexSelected, section: 0)
        self.categoryCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.left, animated: true)
        }
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        newLetterListTblView.tableFooterView = UIView(frame: .zero)
        newLetterListTblView.register(HeaderView.nib, forHeaderFooterViewReuseIdentifier: HeaderView.identifier)
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.retrieveNewsletterData()
        delegate.retrieveUtilityData()

        self.processNewsletterResponse()                       
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRowToUpdate), name: NSNotification.Name(rawValue: "reloadRowToUpdate"), object: nil)
        self.searchBar.delegate = self
        self.selectedCategory = "All"
        categoryCollectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
        setupNavigationController()
        fetchNewsletterListing()
    }
    @objc func reloadRowToUpdate(_ notification: Notification){

        let updatedObject = notification.userInfo?["updatedObject"] as? NSDictionary
        
        let updatedLikeCount = updatedObject!["likeCount"] as? String
        let updatedCommentsCount = updatedObject!["commentsCount"] as? String
        let updatedLikeStatus = updatedObject!["likeStatus"] as? Bool
        let newsletterID = updatedObject!["attribute_id"] as? String
        
        print("updatedLikeCount",updatedLikeCount!)
        print("updatedLikeStatus",updatedLikeStatus!)
        print("updatedCommentsCount",updatedCommentsCount!)

        let rowIndex = notification.userInfo?["rowIndex"] as? Int
        let rowSection = notification.userInfo?["rowSection"] as? Int

        
        print("rowIndex",rowIndex!)
        print("rowSection",rowSection!)

        sectionsFilter.removeAll()
        sections.removeAll()
        
        
        self.originalNewsLetter! = self.originalNewsLetter!.map({
            if $0.attribute_id == newsletterID {
                $0.likeCount = updatedLikeCount
                $0.likeStatus = updatedLikeStatus
                $0.commentsCount = updatedCommentsCount
            }
            return $0 })

        newsLetters = originalNewsLetter; // assign the datasource
        manageSelectedCategoryTableReload(isRowUpdate : true)
      // sortNewsletterResponse(array : originalNewsLetter! ,isSearch : false)
        

    }
    func manageSelectedCategoryTableReload(isRowUpdate : Bool){
        
        print("Selected Category is: \(selectedCategory)")
        if (!self.selectedCategory.isEmpty && self.selectedCategory.count > 0) {

            if(selectedCategory == "All"){
                
                sortNewsletterResponse(array : originalNewsLetter! , isSearch : false)
//                let indexPath = IndexPath(item: rowIndex!, section: rowSection!)
//                UIView.performWithoutAnimation {
//                    self.newLetterListTblView.reloadData()
//
//               //     self.newLetterListTblView.reloadRows(at: [indexPath], with: .none)
//                }
            }
            else if(selectedCategory == "Most Liked"){
              ///  self.newLetterListTblView.reloadData()
                if(!isRowUpdate){
                    sectionsFilter.removeAll()

                       let sortedArray = originalNewsLetter?.sorted { $0.likeCount > $1.likeCount! }
                       sortNewsletterResponse(array : sortedArray! , isSearch : true)
       //                let indexPath = IndexPath(item: rowIndex!, section: rowSection!)

                }
                
//                UIView.performWithoutAnimation {
//                    self.newLetterListTblView.reloadData()
//
//                   // self.newLetterListTblView.reloadRows(at: [indexPath], with: .none)
//                }
            }
            else{
               // self.newLetterListTblView.reloadData()
                
                let filteredNewsLetters = originalNewsLetter?.filter {
                    ($0.category ?? "" ).lowercased().contains(selectedCategory.lowercased())
                }
                sortNewsletterResponse(array : filteredNewsLetters! , isSearch : true)
//                let indexPath = IndexPath(item: rowIndex!, section: rowSection!)
                
            }
            UIView.performWithoutAnimation {
                self.newLetterListTblView.reloadData()

           //     self.newLetterListTblView.reloadRows(at: [indexPath], with: .none)
            }
        }
        
    }
    func fetchNewsletterListing() {
           self.showSpinner(onView: self.view)
        ApprovalManager.shared.getNewsletter( completion: { (responseDictionary  )  in
            DispatchQueue.main.async {
                self.removeSpinner()
                if let array = responseDictionary as? NSMutableArray,
                    array.count > 0 {
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.createNewsletterData(array:array)
                    delegate.deleteNewsletterExtraData(array: array)
                    delegate.retrieveNewsletterData()
                    delegate.createExpressoUtilityData(array:array)
                    delegate.deleteNewsletterExtraData(array: array)

                    delegate.retrieveUtilityData()

                    //mark newsletter as read
                    if (self.selectedNewsletterID != nil) {
                        appdelegate.updateReadStatusNewsletter(id: self.selectedNewsletterID ?? "")
                        //self.updateReadStatus(id: self.selectedNewsletterID ?? "")
                    }
                    
                    // process data from local db
                    self.processNewsletterResponse()
                   }
                
                }
            })
       }
    
   
    
    @objc func processNewsletterResponse() {
        sectionsFilter.removeAll()
        sections.removeAll()

        print("appdelegate.newsletterListGlobal",appdelegate.newsletterListGlobal)
        print("appdelegate.newsletterUtilityGlobal",appdelegate.newsletterUtilityGlobal)

        var newsLetterFromDatabase = convertToJSONArray(moArray: appdelegate.newsletterListGlobal)
        let newsLetterUtilityFromDatabase = convertToJSONArray(moArray: appdelegate.newsletterUtilityGlobal)
        

        for (index, item) in (newsLetterFromDatabase ).enumerated() {
            if let filtered = (newsLetterUtilityFromDatabase ).first(where: {($0["attribute_id"]! as? String) == (item["attribute_id"]!as? String) }) {
                newsLetterFromDatabase[index].merge(filtered) { (current, _) in current }
            }
       }
        print("filtered",newsLetterFromDatabase)
        print("filtered count",newsLetterFromDatabase.count)

        print("Categories",newsLetterFromDatabase.compactMap { $0["category"] })
        let categoryArray = NSSet(array: newsLetterFromDatabase.compactMap { $0["category"] })

        let arr  = categoryArray.allObjects
        var sortedCategory =  arr.sorted { ($0 as! String) < ($1 as! String) }

        if(sortedCategory.count > 0){
            sortedCategory.insert("All", at: 0)
            sortedCategory.insert("Most Liked", at: 1)

        }
            self.categories.removeAll()
        self.categories = sortedCategory
        self.categoryCollectionView.reloadData()

      
        let newsLetterArray = newsLetterData(arr: newsLetterFromDatabase as Any)
         originalNewsLetter = newsLetterArray
        print("original newsletter count ", originalNewsLetter!.count)


         newsLetters = originalNewsLetter; // assign the datasource

      //  sortNewsletterResponse(array : originalNewsLetter! ,isSearch : false)
       
            manageSelectedCategoryTableReload(isRowUpdate : false)


       // self.newLetterListTblView.reloadData()
    }
    

     func sortNewsletterResponse(array : [NewsletterModel] , isSearch : Bool){
        print("selectedCategory:", self.selectedCategory)
        if(self.selectedCategory == "Most Liked"){
            
            sectionsFilter.append(Section(name: "Most Liked", items:array))
            filteredData = sectionsFilter

        }
        
        else{
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
            if(isSearch){
                sectionsFilter.append(Section(name: problem, items:groupedReport))
                filteredData = sectionsFilter
            }
            else{
                sections.append(Section(name: problem, items:groupedReport))
                filteredData = sections
            }
         }
 
        }
    }
    public func convertToJSONArray(moArray: [NSManagedObject]) -> [[String: Any]] {
        var jsonArray: [[String: Any]] = []
        for item in moArray {
            var dict: [String: Any] = [:]
            for attribute in item.entity.attributesByName {
                //check if value is present, then add key to dictionary so as to avoid the nil value crash
                if let value = item.value(forKey: attribute.key) {
                    dict[attribute.key] = value
                }
            }
            jsonArray.append(dict)
        }
        return jsonArray
    }
    public func newsLetterData(arr : Any ) -> [NewsletterModel] {
        
        let typeCheck = arr as! NSArray
        
        var arrayOfNewsLetter : [NewsletterModel] = [NewsletterModel]()
     
        for index in 0..<typeCheck.count {
            let dict = typeCheck[index] as! [String : Any]
            let option = NewsletterModel.init(title: dict[APIConstants.title] as? String, subTitle: dict[APIConstants.subTitle] as? String, descriptions: dict[APIConstants.newsLetterDescription] as? String, src: dict[APIConstants.src] as? String, category: dict[APIConstants.category] as? String , newsletterBy: dict[APIConstants.newsletterBy] as? String, date:  dict[APIConstants.date] as! Int64, attribute_id:  dict[APIConstants.attribute_id] as? String,  attribute_markUnread:  dict[APIConstants.attribute_markUnread] as! Bool, headerImageURL: dict[APIConstants.headerImageURL] as? String,footerImageURL: dict[APIConstants.footerImageURL] as? String,videoURL: dict[APIConstants.videoURL] as? String,likeCount: dict[APIConstants.likeCount] as? String,commentsCount: dict[APIConstants.commentsCount] as? String,likeStatus: dict[APIConstants.likeStatus] as? Bool)
            arrayOfNewsLetter.append(option)
            
        }
        
        
        return arrayOfNewsLetter
        
    }
 
    private func setupNavigationController() {
        let backImage = UIImage(named: backImageName)?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backImagePressed))
        
        let searchImage = UIImage(named: "searchIcon")?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: #selector(searchIconClicked))

        navigationItem.title = navigationTitle
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        if #available(iOS 15, *)
        {
               // do nothing auto
        }else{
            self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "header"), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.titleTextAttributes = textAttributes
        }
        //navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.setToolbarHidden(true, animated: false)
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "header"), for: .default)
        //self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @objc func backImagePressed() {
        navigationController?.popViewController(animated: true)
        navigationController?.isNavigationBarHidden = !self.shouldHideNavigationBar
    }
    
    @objc func searchIconClicked(){
        UIView.animate(withDuration: 0.3) { [self] in
            if(self.searchBarYCordinate.constant == 0){
                self.searchBarYCordinate.constant = -56
                self.searchBar.resignFirstResponder()

            }
            else{
                self.searchBarYCordinate.constant = 0
                self.searchBar.becomeFirstResponder()
//                searchBarTextDidBeginEditing(self.searchBar)

            }
                self.view.layoutIfNeeded()
        }
       
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


extension NewsLetterListViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        spinnerView.addSubview(ai)
        onView.addSubview(spinnerView)
        
        self.vSpinner = spinnerView
    }
    
    func removeSpinner() {
        self.vSpinner?.removeFromSuperview()
        self.vSpinner = nil
    }
   
   
}
//MARK:TableView Delegate/DataSource
extension NewsLetterListViewController : UITableViewDataSource , UITableViewDelegate{

     func numberOfSections(in tableView: UITableView) -> Int {
        return filteredData.count
       }
       
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          // return sections[section].collapsed ? 0 : sections[section].items.count
            return filteredData[section].collapsed ? 0 : filteredData[section].items.count
       }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NewsLetterViewCell
        let newsletter: NewsletterModel = filteredData[indexPath.section].items[indexPath.row]
        var subTitleString : String!
        
        if ((newsletter.subTitle) != nil) {
            subTitleString = newsletter.subTitle
        }
        if ((newsletter.category) != nil) {
            subTitleString += (" | " + newsletter.category)
        }
        if((newsletter.newsletterBy) != nil){
            subTitleString += (" | " + newsletter.newsletterBy)

        }
        cell.titleLbl.text = newsletter.title ?? ""
        cell.subTitleLabel.text = subTitleString ?? ""

        let plainText = newsletter.descriptions!.htmlToString
        cell.descriptionLabel.text = plainText
        
        cell.btnLike.tag = Int(newsletter.attribute_id)!
        cell.btnLike.adjustsImageWhenHighlighted = false
        cell.btnLike.showsTouchWhenHighlighted = false
        cell.btnLikeCount.tag = Int(newsletter.attribute_id)!
        

        cell.newsletter = newsletter
        cell.parentNavController = self.navigationController;
        cell.btnComments.addTarget(cell, action: #selector(cell.commentsBtnClicked(_:)), for: .touchUpInside)
        cell.btnLike.isSelected = newsletter.likeStatus
        let likeCount = Int(newsletter.likeCount)
        let commentCount = Int(newsletter.commentsCount)
        if(likeCount == 0) {
            cell.btnLikeCount.setTitle("Like", for:UIControl.State.normal)
        }
        else {
            if(likeCount == 1) {
                cell.btnLikeCount.setTitle(newsletter.likeCount + " like", for:UIControl.State.normal)
            }
            else{
                cell.btnLikeCount.setTitle(newsletter.likeCount + " likes", for:UIControl.State.normal)
            }
        }
        cell.btnLikeCount.addTarget(cell, action: #selector(cell.updateLikeMethod(_:)), for: .touchUpInside)
        
        if(commentCount == 0){
            cell.btnComments.setTitle("Comment", for: .normal)
        }
        else{
            if(commentCount == 1){
                cell.btnComments.setTitle(newsletter.commentsCount + " comment", for: .normal)
            }
            else{
                cell.btnComments.setTitle(newsletter.commentsCount + " comments", for: .normal)
            }
        }

        cell.coverImage.setImageFromUrl(ImageURL:newsletter.src ?? "")
        if(newsletter.attribute_markUnread as Bool == false){
            let font1 = UIFont(name: "Montserrat-Regular", size: 16)
            cell.titleLbl.font = font1
        }
        else{
            let font1 = UIFont(name: "Montserrat-SemiBold", size: 16)
            cell.titleLbl.font = font1
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newsletter: NewsletterModel = filteredData[indexPath.section].items[indexPath.row]
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.updateReadStatusNewsletter(id: newsletter.attribute_id!)
        newsletter.attribute_markUnread = false
        newLetterListTblView.reloadData()
         
        var completeList: [NewsletterModel] = []
        for section in filteredData {
            completeList.append(contentsOf: section.items)
        }
                
        let storyBoard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
        let detailViewController = storyBoard.instantiateViewController(withIdentifier: "NewsletterDetailController") as! NewsletterDetailController
        detailViewController.delegate = self
        detailViewController.newsletters = completeList
        detailViewController.newsletter_index = completeList.index(of: newsletter) ?? 0
        
        self.navigationController?.pushViewController(detailViewController, animated: true)
        
        // reset search mode if it was activated
        self.resetSearchMode()
    }
    
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.identifier) as? HeaderView ?? HeaderView(reuseIdentifier: HeaderView.identifier)
            header.contentView.backgroundColor = UIColor.init(red: 37/255.0, green: 58/255.0, blue: 120/255.0, alpha: 1)
            if(filteredData.count > section) {
                let obj = filteredData[section]
                header.titleLabel?.text = obj.name
                header.setCollapsed(collapsed: obj.collapsed)
                header.numberOfNewsLetter.text = "\(obj.items.count)"
            }
            header.section = section
            header.delegate = self
           
           return header
       }
       
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
           return 44.0
       }
       
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
           return 0.00001
       }
    
}

//MARK:SearchBar Delegate
extension NewsLetterListViewController : UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar){
        
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        searchBar.becomeFirstResponder()
    }
   
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        sectionsFilter.removeAll()
        if searchText.isEmpty {
            //self.searchBarCancelButtonClicked(searchBar)
            searchBar.resignFirstResponder()
            //searchBar.showsCancelButton = false
            searchBar.text = ""
            self.isSearching = false
            newsLetters = originalNewsLetter;
            filteredData = sections
            newLetterListTblView.reloadData()
        }else{
            let keyword = searchText.lowercased()
            DispatchQueue.global(qos: .userInitiated).async {
                self.newsLetters = self.originalNewsLetter?.filter {
                                ($0.title ?? "" ).lowercased().contains(keyword) ||
                                ($0.subTitle ?? "" ).lowercased().contains(keyword) ||
                                ($0.descriptions ?? "" ).lowercased().contains(keyword) ||
                                ($0.category ?? "" ).lowercased().contains(keyword)
                           }
                self.sortNewsletterResponse(array : self.newsLetters! , isSearch : true)
                self.isSearching = true
                DispatchQueue.main.async {
                    self.newLetterListTblView.reloadData()
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           searchBar.resignFirstResponder()
           searchBar.text = ""
           self.isSearching = false
           newsLetters = originalNewsLetter;
           filteredData = sections
           sectionsFilter.removeAll()
           if(selectedCategory == "All") {
                newLetterListTblView.reloadData()
           }
           else {
                sections.removeAll()
                sortNewsletterResponse(array : originalNewsLetter! , isSearch : false)
                manageSelectedCategoryTableReload(isRowUpdate : false)
            }
            UIView.animate(withDuration: 0.3) {
                self.searchBarYCordinate.constant = -56
                self.view.layoutIfNeeded()
           }
       }
    
    func resetSearchMode () {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        self.isSearching = false
        self.searchBarYCordinate.constant = -56
        self.view.layoutIfNeeded()
    }
}


//headerView delegate

// MARK: - Section Header Delegate
//
extension NewsLetterListViewController: HeaderViewDelegate {
    
    func toggleSection(header: HeaderView, section: Int) {
//        let collapsed = !sections[section].collapsed
//
//        // Toggle collapse
//        sections[section].collapsed = collapsed
//        header.setCollapsed(collapsed: collapsed)
        
        let collapsed = !filteredData[section].collapsed
        
        // Toggle collapse
        filteredData[section].collapsed = collapsed
        header.setCollapsed(collapsed: collapsed)
        
        //newLetterListTblView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
        newLetterListTblView.reloadData()
    }
    
}
extension String {
    var htmlToAttributedString: NSAttributedString? {
        return Data(utf8).htmlToAttributedString
    }

    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension Data {
    var htmlToAttributedString: NSAttributedString? {
        // Converts html to a formatted string.
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}


class CategoryCell: UICollectionViewCell {
   // var imageView = UIImageView()
    private var textLabel = UILabel()
    private var underlineView = UIView()


    var category: String? {
        didSet {
            self.textLabel.text = category
        }
    }
    
    var markSelected: Bool = false {
        didSet {
            if (markSelected) {
//                textLabel.layer.backgroundColor = UIColor.black.cgColor
//                textLabel.textColor = UIColor.init(red: 37/255.0, green: 58/255.0, blue: 120/255.0, alpha: 1)
                textLabel.textColor = .black

                underlineView.isHidden = false

                }
            else {
                textLabel.textColor = .gray
                underlineView.isHidden = true
                    

//                textLabel.layer.backgroundColor = UIColor.white.cgColor
//                textLabel.textColor = UIColor.init(red: 37/255.0, green: 58/255.0, blue: 120/255.0, alpha: 1)
            }
            self.contentView.setNeedsLayout()
        }
    }
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
   
    func customInit() {
        // label sizing
        let MIN_LABEL_WIDTH: CGFloat = 100

        textLabel.textColor = .gray
        textLabel.font = UIFont(name: "Montserrat-Medium", size: 16)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 1
        self.contentView.addSubview(textLabel)
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        underlineView.backgroundColor = UIColor.init(red: 37/255.0, green: 58/255.0, blue: 120/255.0, alpha: 1)
        underlineView.isHidden = false
        self.contentView.addSubview(underlineView)

        underlineView.translatesAutoresizingMaskIntoConstraints = false


        let textLabelConstraints = [
            textLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: CGFloat(5)),
            textLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: CGFloat(1)),
           textLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: CGFloat(-1)),
            textLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: MIN_LABEL_WIDTH),
            textLabel.bottomAnchor.constraint(equalTo: self.underlineView.topAnchor, constant: CGFloat(-5)),

           // textLabel.heightAnchor.constraint(equalToConstant: 30),
            //textLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
        ]
        NSLayoutConstraint.activate(textLabelConstraints)
        
        let underlineViewConstraints = [
            underlineView.topAnchor.constraint(equalTo: self.textLabel.bottomAnchor, constant: CGFloat(5)),          underlineView.leftAnchor.constraint(equalTo: self.textLabel.leftAnchor, constant: CGFloat(0)),
            underlineView.rightAnchor.constraint(equalTo: self.textLabel.rightAnchor, constant: CGFloat(0)),
         //   underlineView.widthAnchor.constraint(greaterThanOrEqualToConstant: MIN_LABEL_WIDTH),
            underlineView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: CGFloat(0)),
            underlineView.heightAnchor.constraint(equalToConstant: 1),
            underlineView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
        ]
        NSLayoutConstraint.activate(underlineViewConstraints)

    }
}
extension UILayoutPriority {
  static func +(lhs: UILayoutPriority, rhs: Float) -> UILayoutPriority {
    return UILayoutPriority(lhs.rawValue + rhs)
  }

  static func -(lhs: UILayoutPriority, rhs: Float) -> UILayoutPriority {
    return UILayoutPriority(lhs.rawValue - rhs)
  }
}
extension NewsLetterListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath as IndexPath) as! CategoryCell
        cell.category = (categories[indexPath.row] as! String)
        if(counter == 0){
            self.selectedCategory = "All"
            counter = counter + 1
        }
        cell.markSelected = (categories[indexPath.row] as! String == self.selectedCategory)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        self.selectedCategory = (categories[indexPath.row] == self.selectedCategory) ? "" : categories[indexPath.row]
        self.selectedCategory = categories[indexPath.row] as! String
        self.itemIndexSelected = indexPath.row
           
            self.categoryCollectionView.reloadData()
            self.viewDidLayoutSubviews()
        
        
        // process fiteration of data based on selected category
        print("Selected Category is: \(selectedCategory)")
        if (!self.selectedCategory.isEmpty && self.selectedCategory.count > 0) {

            if(selectedCategory == "All"){
                
                sections.removeAll()
                sortNewsletterResponse(array : originalNewsLetter! , isSearch : false)
            }
            else if(selectedCategory == "Most Liked"){
                sectionsFilter.removeAll()
                self.newLetterListTblView.reloadData()
                let sortedArray = originalNewsLetter?.sorted {
                    // convert likeCount to Integers first before comparing
                    return (Int($0.likeCount)! > Int($1.likeCount)!)
                }

                sortNewsletterResponse(array : sortedArray! , isSearch : true)
            }
            else{
                sectionsFilter.removeAll()
                self.newLetterListTblView.reloadData()
                
                let filteredNewsLetters = originalNewsLetter?.filter {
                    ($0.category ?? "" ).lowercased().contains(selectedCategory.lowercased())
                }
                sortNewsletterResponse(array : filteredNewsLetters! , isSearch : true)
            }
            
        }
        else {
            sectionsFilter.removeAll()
            sections.removeAll()
            sortNewsletterResponse(array : originalNewsLetter! , isSearch : false)
        }
        self.newLetterListTblView.reloadData()
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        // Here, I need 3 equal cells occupying whole screen width so i divided it by 3.0. You can use as per your need.
//        return CGSize(width: 100, height: 60)
//    }

}
extension Array where Element: Equatable {
    func removeDuplicates() -> Array {
        return reduce(into: []) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
}
