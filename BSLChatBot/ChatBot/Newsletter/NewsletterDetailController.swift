import UIKit
import WebKit
import Lightbox

protocol NewsletterDetailDelegateProtocol {
    func sendUpdatedReadStatus(myData: [NewsletterModel])
}

class NewsletterDetailController: UIViewController, UITextViewDelegate {
    var newsletters: [NewsletterModel]?
    var newsletter_index = 0
    var newsletter_id: String?
    var topView = UIView()
   // UI Controls
    var scrollView: UIScrollView = UIScrollView()
    let stickyView = UIView()
    let stickyViewCopy = UIView()
    let lblTitle = UILabel()
    let lblSubtitle = UILabel()

    let lblTitleCopy = UILabel()
    let lblSubtitleCopy = UILabel()

    let contentlabel = UITextView()

//    let contentlabel = UILabel()
    let headerImageView: UIImageView = UIImageView()
    let footerImageView: UIImageView = UIImageView()
    let tutorialView = UIView()
    let tutorialLeftImageView: UIImageView = UIImageView(image: UIImage(named: "leftswipe"))
    let tutorialRightImageView: UIImageView = UIImageView(image: UIImage(named: "rightswipe"))
    let placeholderImage =  UIImage(named: "Loader.png")
    let tutorialLabel = UILabel()
    var webView : WKWebView =  WKWebView()

    var contentView = UIView()
    @IBOutlet weak var footerStickyView: UIView!

    // Constraints
    var headerViewHeightContraint: NSLayoutConstraint?

    var footerViewHeightConstraint: NSLayoutConstraint?
    var stickyViewTopConstraint: NSLayoutConstraint?
    var contentLabelTopConstraint: NSLayoutConstraint?
    
    // Mini cache for faster access of images
    var imageCache = [String: UIImage]()
    
    var delegate: NewsletterDetailDelegateProtocol? = nil

    @IBOutlet weak var btnLikeCount: UIButton!
    @IBOutlet weak var btnComments: UIButton!
    @IBOutlet weak var btnLike: UIButton!

    override func viewDidLoad() {
        setupNavigationController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdatedCount), name: NSNotification.Name(rawValue: "handleUpdatedCount"), object: nil)

        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.isFromPushNotification = false
        
        self.footerViewHeightConstraint = self.footerImageView.heightAnchor.constraint(equalToConstant: 200)
        self.headerViewHeightContraint = self.headerImageView.heightAnchor.constraint(equalToConstant: 200)
        
        
        self.scrollView.showsVerticalScrollIndicator = false
        contentlabel.backgroundColor = .white
        contentlabel.isUserInteractionEnabled = true;

        self.view.backgroundColor = .white
        contentView.backgroundColor = .white
        stickyView.backgroundColor = .black
        stickyView.alpha = 0.8

        self.view.addSubview(self.scrollView)
        self.scrollView.delegate = self
        self.scrollView.addSubview(contentView)
        
//        self.footerStickyView.backgroundColor = .green
//        self.view.addSubview(self.footerStickyView)
        
//
        self.view.bringSubviewToFront(footerStickyView)

        footerStickyView.layer.shadowColor = UIColor.gray.cgColor
        footerStickyView.layer.shadowOpacity = 0.7
        footerStickyView.layer.shadowOffset = .zero
        footerStickyView.layer.shadowRadius = 5
        footerStickyView.layer.shadowPath = UIBezierPath(rect: footerStickyView.bounds).cgPath

        
        // create copy of sticky view
        stickyViewCopy.backgroundColor = .black
        stickyViewCopy.alpha = 0.8
        self.view.addSubview(stickyViewCopy)
        self.view.bringSubviewToFront(stickyViewCopy)
        stickyViewCopy.isHidden = true
        
        lblTitleCopy.numberOfLines = 0
        lblTitleCopy.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblTitleCopy.font = UIFont(name: "Montserrat-SemiBold", size: 17.0)
        lblTitleCopy.textColor = .white
        lblTitleCopy.textAlignment = .left
        stickyViewCopy.addSubview(lblTitleCopy)


        lblSubtitleCopy.numberOfLines = 0
        lblSubtitleCopy.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblSubtitleCopy.font = UIFont(name: "Montserrat-Medium", size: 14.0)
        lblSubtitleCopy.textColor = .white
        lblSubtitleCopy.textAlignment = .left
        stickyViewCopy.addSubview(lblSubtitleCopy)

        
        stickyViewCopy.translatesAutoresizingMaskIntoConstraints = false
        lblSubtitleCopy.translatesAutoresizingMaskIntoConstraints = false
        lblTitleCopy.translatesAutoresizingMaskIntoConstraints = false
        footerStickyView.translatesAutoresizingMaskIntoConstraints = false

        
        
        // add constraints
        let stickyViewContraints = [
           stickyViewCopy.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
           stickyViewCopy.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
           stickyViewCopy.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
           stickyViewCopy.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
        ]

        NSLayoutConstraint.activate(stickyViewContraints)
        
        let lblTitleCopyConstraints = [
                         lblTitleCopy.topAnchor.constraint(equalTo: stickyViewCopy.topAnchor, constant: 10),
                         lblTitleCopy.leftAnchor.constraint(equalTo: stickyViewCopy.leftAnchor, constant: 20),
                         lblTitleCopy.rightAnchor.constraint(equalTo: stickyViewCopy.rightAnchor, constant: -20),
                         lblTitleCopy.bottomAnchor.constraint(equalTo: lblSubtitleCopy.topAnchor, constant: -5),
                         lblTitleCopy.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
                      ]
                      NSLayoutConstraint.activate(lblTitleCopyConstraints)
               
       let lblSubTitleCopyConstraints = [
                   lblSubtitleCopy.topAnchor.constraint(equalTo: lblTitleCopy.bottomAnchor, constant: 5),
                   lblSubtitleCopy.leftAnchor.constraint(equalTo: stickyViewCopy.leftAnchor, constant: 20),
                   lblSubtitleCopy.rightAnchor.constraint(equalTo: stickyViewCopy.rightAnchor, constant: -20),
                   lblSubtitleCopy.bottomAnchor.constraint(equalTo: stickyViewCopy.bottomAnchor, constant: -10),
                   lblSubtitleCopy.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
              ]
              NSLayoutConstraint.activate(lblSubTitleCopyConstraints)

                
        // add left right gestures on scrollview
        let leftSwipeRecognizer : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        let rightSwipeRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        leftSwipeRecognizer.direction = .left
        rightSwipeRecognizer.direction = .right
        self.view.addGestureRecognizer(leftSwipeRecognizer)
        self.view.addGestureRecognizer(rightSwipeRecognizer)
        
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        // set constraints
        let scrollviewConstraints = [
                scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
                scrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                scrollView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
                scrollView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            ]
        NSLayoutConstraint.activate(scrollviewConstraints)
        
     
        
     
        if let newsletters = self.newsletters {
            let newsletterModel: NewsletterModel = newsletters[self.newsletter_index]
            self.newsletter_id = String(newsletterModel.date)
            self.title = "\(self.newsletter_index + 1) of \(newsletters.count)"
            loadNewsletter(newsletterModel , newsletterIndex: self.newsletter_index + 1)
            if(newsletters.count > 1){
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.showTutorial()
                }

            }
        }
    }
    
    @objc func headerImageTapAction(recognizer: UITapGestureRecognizer) {
        guard let image = headerImageView.image else {
            return
        }
        let images = [LightboxImage(image: image, text: lblTitle.text ?? "")]
        openImageViewer(withImages: images)
    }
       
    @objc func footerImageTapAction(recognizer: UITapGestureRecognizer) {
        guard let image = footerImageView.image else {
            return
        }
        let images = [LightboxImage(image: image, text: lblTitle.text ?? "")]
        openImageViewer(withImages: images)
    }
   
    func openImageViewer(withImages images:[LightboxImage]) {
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        for view in controller.view.subviews {
            if view.isKind(of: Lightbox.FooterView.self) {
                for subview in view.subviews {
                    if subview.isKind(of: UILabel.self) {
                        subview.isHidden = true
                        break;
                    }
                }
                break;
            }
        }
        present(controller, animated: true, completion: nil)
    }
    
    func showTutorial () {
        tutorialView.frame = CGRect(x: 0, y: 0, width:self.view.frame.size.width , height: 120)
        tutorialView.backgroundColor = .black
        tutorialView.alpha = 0.8
        
        tutorialLabel.text = "Swipe left or right to read next article"
        tutorialLabel.font =  UIFont(name: "Montserrat-Bold", size: 17.0)
        tutorialLabel.textAlignment = .center
        tutorialLabel.numberOfLines = 0
        tutorialLabel.textColor = .white
        tutorialLabel.frame = CGRect(x: 100, y: 10, width: self.view.frame.size.width - 200 , height: 100)
        
        tutorialLeftImageView.contentMode = .scaleAspectFit
        tutorialLeftImageView.frame = CGRect(x: self.view.frame.size.width - 110, y: 10, width: 100, height: 100)
        tutorialRightImageView.contentMode = .scaleAspectFit
        tutorialRightImageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        
        
        tutorialView.addSubview(tutorialLeftImageView)
        tutorialView.addSubview(tutorialRightImageView)
        tutorialView.addSubview(tutorialLabel)
        self.view.addSubview(tutorialView)
        
        let animation = CATransition()
        animation.duration = 0.5
        animation.type = .moveIn
        animation.delegate = self
        animation.subtype = .fromBottom
        tutorialView.layer.add(animation, forKey: "tutorialanimation")
    }
    
    
    
    func resetNewsletterView() {
        // stop any loading tasks
        URLSession.shared.invalidateAndCancel()
        
        // remove existing subviews
        headerImageView.removeFromSuperview()
        headerImageView.image = nil
        if(webView != nil){
            webView.removeFromSuperview()

        }
        contentlabel.removeFromSuperview()
        contentlabel.attributedText = nil
       // contentlabel.text = nil
        footerImageView.image = nil
        footerImageView.removeFromSuperview()
        stickyView.removeFromSuperview()
        
        self.contentView.updateConstraints()
        self.contentView.layoutIfNeeded()
    }
    
    func loadNewsletter (_ newsletter: NewsletterModel , newsletterIndex : Int) {
        self.resetNewsletterView()
        if(newsletter.videoURL != nil && newsletter.videoURL != "" ){
            contentView.addSubview(webView)
        }
        else if (newsletter.headerImageURL != nil && newsletter.headerImageURL != "") {
            headerImageView.image = self.placeholderImage
            contentView.addSubview(headerImageView)
            
            let headerImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerImageTapAction))
                     headerImageTapGestureRecognizer.numberOfTapsRequired = 1
                     self.headerImageView.addGestureRecognizer(headerImageTapGestureRecognizer)
                     self.headerImageView.isUserInteractionEnabled = true
        }
                
        contentView.addSubview(stickyView)
        
        lblTitle.numberOfLines = 0
        lblTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblTitle.font = UIFont(name: "Montserrat-SemiBold", size: 17.0)
        lblTitle.textColor = .white
        lblTitle.text = newsletter.title
        lblTitleCopy.text = newsletter.title

        lblTitle.textAlignment = .left
        stickyView.addSubview(lblTitle)
                
        lblSubtitle.numberOfLines = 0
        lblSubtitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblSubtitle.font = UIFont(name: "Montserrat-Medium", size: 14.0)
        lblSubtitle.textColor = .white
        
        var subTitleString : String!
        if ((newsletter.subTitle) != nil && (newsletter.subTitle) != "") {
            subTitleString = newsletter.subTitle
        }
        if ((newsletter.category) != nil && (newsletter.category) != "") {
            subTitleString += (" | " + newsletter.category)
        }
        if((newsletter.newsletterBy) != nil && (newsletter.newsletterBy) != ""){
            subTitleString += (" | " + newsletter.newsletterBy)
        }
        lblSubtitle.text = subTitleString ?? ""
        lblSubtitleCopy.text = subTitleString ?? ""
        lblSubtitle.textAlignment = .left
        stickyView.addSubview(lblSubtitle)

        let data = Data(newsletter.descriptions!.utf8)
        if let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            contentlabel.isScrollEnabled = false
            contentlabel.isEditable = false
            contentlabel.attributedText = attributedString
            contentlabel.dataDetectorTypes = UIDataDetectorTypes.link
            contentlabel.delegate = self

            //contentlabel.numberOfLines = 0
            contentlabel.backgroundColor = .white
            contentView.addSubview(contentlabel)
        }
        
        if (newsletter.footerImageURL != nil && newsletter.footerImageURL != "") {
            contentView.addSubview(footerImageView)
        }
        
        
        self.btnLike.tag = Int(newsletter.attribute_id)!
        self.btnLike.adjustsImageWhenHighlighted = false
        self.btnLike.showsTouchWhenHighlighted = false
        self.btnLikeCount.tag = Int(newsletter.attribute_id)!
        
       
        updateFooterStickyView(newsletter)
        
        updateLayoutContraints(newsletter)
       
        // perform lazy loading once constraints are all set
        loadHeeaderFooter(newsletter)
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if LightUtility.getLightUser() != nil{
            delegate.updateProspReadStatusNewsletter(id: newsletter.attribute_id!)
        }else{
            delegate.updateReadStatusNewsletter(id: newsletter.attribute_id!)
        }
       // delegate.updateReadStatusNewsletter(id: newsletter.attribute_id!)
        
        let newsletterModel: NewsletterModel = newsletters![newsletterIndex - 1]
        newsletterModel.attribute_markUnread = false
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    func updateFooterStickyView(_ newsletter : NewsletterModel){
        if(newsletter.likeStatus == true){
            self.btnLike.isSelected = true

        }
        else{
            self.btnLike.isSelected = false

        }
        if(Int(newsletter.likeCount) == 0){
            self.btnLikeCount.setTitle("Like", for:.normal)

        }
        else{
            if(Int(newsletter.likeCount) == 1){
                self.btnLikeCount.setTitle(newsletter.likeCount + " like", for:.normal)
            }
            else{
                self.btnLikeCount.setTitle(newsletter.likeCount + " likes", for:.normal)

            }

        }
        
        if(self.btnLikeCount.currentTitle == "Like"){
            let btn = UIButton()
            btn.tag = Int(newsletter.attribute_id)!
            self.btnLikeCount.addTarget(self, action: #selector(self.likeBtnClicked), for: .touchUpInside)

        }
        else{
            self.btnLikeCount.tag = Int(newsletter.attribute_id)!
            self.btnLikeCount.addTarget(self, action: #selector(self.getUsersList(_:)), for: .touchUpInside)
        }
        if(Int(newsletter.commentsCount) == 0){
            self.btnComments.setTitle("Comment", for: .normal)

        }
        else{
            if(Int(newsletter.commentsCount) == 1){
                self.btnComments.setTitle(newsletter.commentsCount + " comment", for: .normal)

            }
            else{
                self.btnComments.setTitle(newsletter.commentsCount + " comments", for: .normal)

            }

        }
    }
    func loadHeeaderFooter(_ newsletter: NewsletterModel) {
        // if videoURL or header Image URL exist
        if(newsletter.videoURL != nil && newsletter.videoURL != "" ){
           setVideoURL(videoURL: newsletter.videoURL)
        }
        else if (newsletter.headerImageURL != nil && newsletter.headerImageURL != "") {
            self.setHeaderImageFromUrl(ImageURL: newsletter.headerImageURL)
        }
        
        // if footer image URL exist
        if (newsletter.footerImageURL != nil && newsletter.footerImageURL != "") {
           setFooterImageFromUrl(ImageURL: newsletter.footerImageURL)
        }
    }
    
    func updateLayoutContraints (_ newsletter: NewsletterModel) {
        stickyView.translatesAutoresizingMaskIntoConstraints = false
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        lblSubtitle.translatesAutoresizingMaskIntoConstraints = false

        if (newsletter.videoURL != nil && newsletter.videoURL != "") {
            webView.translatesAutoresizingMaskIntoConstraints = false
        }
        else if (newsletter.headerImageURL != nil && newsletter.headerImageURL != "") {
            headerImageView.translatesAutoresizingMaskIntoConstraints = false
        }
        if (newsletter.footerImageURL != nil && newsletter.footerImageURL != "") {
            footerImageView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        contentlabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        
        if (newsletter.videoURL != nil && newsletter.videoURL != "") {
            topView = webView

            let webViewConstraints = [
                        webView.topAnchor.constraint(equalTo: contentView.topAnchor),
                        webView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                        webView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
                        webView.heightAnchor.constraint(equalToConstant: 200),
                        webView.bottomAnchor.constraint(equalTo: stickyView.topAnchor)
                      ]
            NSLayoutConstraint.activate(webViewConstraints)
        }

       else if (newsletter.headerImageURL != nil && newsletter.headerImageURL != "") {
            topView = headerImageView
            let headerConstraints = [
                        headerImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                        headerImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                        headerImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
                      ]
            NSLayoutConstraint.activate(headerConstraints)
            
            NSLayoutConstraint.deactivate([self.headerViewHeightContraint!])
            self.headerViewHeightContraint = self.headerImageView.heightAnchor.constraint(equalToConstant: 200)
            NSLayoutConstraint.activate([self.headerViewHeightContraint!])
        }
                        
        // set constraints
        let stickyViewConstraints = [
            stickyView.topAnchor.constraint(equalTo: ((newsletter.headerImageURL != nil && newsletter.headerImageURL != "") || (newsletter.videoURL != nil && newsletter.videoURL != "")) ? topView.bottomAnchor: contentView.topAnchor),
            stickyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stickyView.bottomAnchor.constraint(equalTo: contentlabel.topAnchor, constant: -10),
            stickyView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            stickyView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
        ]
        NSLayoutConstraint.activate(stickyViewConstraints)
        
        
        let lblTitleConstraints = [
                  lblTitle.topAnchor.constraint(equalTo: stickyView.topAnchor, constant: 10),
                  lblTitle.leftAnchor.constraint(equalTo: stickyView.leftAnchor, constant: 20),
                  lblTitle.rightAnchor.constraint(equalTo: stickyView.rightAnchor, constant: -20),
                  lblTitle.bottomAnchor.constraint(equalTo: lblSubtitle.topAnchor, constant: -5),
                  lblTitle.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
               ]
               NSLayoutConstraint.activate(lblTitleConstraints)
        
        let lblSubTitleConstraints = [
                    lblSubtitle.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 5),
                    lblSubtitle.leftAnchor.constraint(equalTo: stickyView.leftAnchor, constant: 20),
                    lblSubtitle.rightAnchor.constraint(equalTo: stickyView.rightAnchor, constant: -20),
                    lblSubtitle.bottomAnchor.constraint(equalTo: stickyView.bottomAnchor, constant: -10),
                    lblSubtitle.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
               ]
               NSLayoutConstraint.activate(lblSubTitleConstraints)

        // set constraints
         let contentlabelConstraints = [
            contentlabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentlabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -40),
         ]
         NSLayoutConstraint.activate(contentlabelConstraints)


        if (newsletter.footerImageURL != nil && newsletter.footerImageURL != "") {
            let footerConstraints = [
                  footerImageView.topAnchor.constraint(equalTo: contentlabel.bottomAnchor),
                  footerImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                  footerImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                  footerImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            ]
            NSLayoutConstraint.activate(footerConstraints)
        }
        else {
             let contentlabelBottomConstraint = contentlabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            NSLayoutConstraint.activate([contentlabelBottomConstraint])
        }

        let heightConstraint =  contentView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor)
        heightConstraint.priority = UILayoutPriority(rawValue: 249)
        let contentViewConstraints = [
            contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: 0),
            contentView.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor, constant: 0),
            contentView.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            heightConstraint,
        ]

        NSLayoutConstraint.activate(contentViewConstraints)
        
        // enforce layout drawing
        self.view.layoutIfNeeded()
    }
    
    func setVideoURL(videoURL : String){
        
        let videoID = videoURL.youtubeID

        guard let youtubeURL = URL(string: "https://www.youtube.com/embed/\(videoID!)?playsinline=1") else {
        return
        }
        webView.load(URLRequest(url: youtubeURL))

    }
    func setHeaderImageFromUrl(ImageURL :String) {
        let currentSelectedIndex = self.newsletter_index
        if (self.imageCache[ImageURL] != nil) {
            let image = self.imageCache[ImageURL]
            self.headerImageView.image = image
            
            NSLayoutConstraint.deactivate([self.headerViewHeightContraint!])
            self.headerViewHeightContraint = self.headerImageView.heightAnchor.constraint(equalTo: self.headerImageView.widthAnchor, multiplier: image!.size.height / image!.size.width)
            NSLayoutConstraint.activate([self.headerViewHeightContraint!])
        }
        else {
            URLSession.shared.dataTask( with: NSURL(string:ImageURL)! as URL, completionHandler: {
                (data, response, error) -> Void in
                DispatchQueue.main.async {
                    if let data = data {
                        
                        let image = UIImage(data: data)
                        
                        
                        // maintain in cache for faster access
                        self.imageCache[ImageURL] = image
                        
                        let newlySelectedIndex = self.newsletter_index
                        if (newlySelectedIndex == currentSelectedIndex) {
                            self.headerImageView.image = image
                            // Deactivate older contraints and Activate new height constraint
                            NSLayoutConstraint.deactivate([self.headerViewHeightContraint!])
                           self.headerViewHeightContraint = self.headerImageView.heightAnchor.constraint(equalTo: self.headerImageView.widthAnchor, multiplier: image!.size.height / image!.size.width)
                           NSLayoutConstraint.activate([self.headerViewHeightContraint!])
                        }
                    }
                }
            }).resume()
        }
    }
    
    func setFooterImageFromUrl(ImageURL :String) {
        let currentSelectedIndex = self.newsletter_index
        if (self.imageCache[ImageURL] != nil) {
            // maintain in cache for faster access
            let image = imageCache[ImageURL]
            self.footerImageView.image = image
            
            // Deactivate older contraints and Activate new height constraint
           NSLayoutConstraint.deactivate([self.footerViewHeightConstraint!])
           self.footerViewHeightConstraint = self.footerImageView.heightAnchor.constraint(equalTo: self.footerImageView.widthAnchor, multiplier: image!.size.height / image!.size.width)
           NSLayoutConstraint.activate([self.footerViewHeightConstraint!])
        }
        else {
            URLSession.shared.dataTask( with: NSURL(string:ImageURL)! as URL, completionHandler: {
                (data, response, error) -> Void in
                DispatchQueue.main.async {
                    
                    if let data = data {
                        let image = UIImage(data: data)
                        
                        // maintain in cache for faster access
                        self.imageCache[ImageURL] = image
                        
                        let newlySelectedIndex = self.newsletter_index
                        if (newlySelectedIndex == currentSelectedIndex) {
                            self.footerImageView.image = image
                            // Deactivate older contraints and Activate new height constraint
                            NSLayoutConstraint.deactivate([self.footerViewHeightConstraint!])
                            self.footerViewHeightConstraint = self.footerImageView.heightAnchor.constraint(equalTo: self.footerImageView.widthAnchor, multiplier: image!.size.height / image!.size.width)
                            NSLayoutConstraint.activate([self.footerViewHeightConstraint!])
                        }
                    }
                }
            }).resume()
                        
        }
    }
    @objc func getUsersList(_ sender: UIButton){
        print(sender.tag)
        let storyBoard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
        let peopleViewController = storyBoard.instantiateViewController(withIdentifier: "PeopleLikedViewController") as! PeopleLikedViewController
        peopleViewController.newsletterId = String(sender.tag)
        self.navigationController?.pushViewController(peopleViewController, animated: true)
     //   self.push(peopleViewController, animated: true, completion: nil)

    }
    @IBAction func likeBtnClicked(_ sender: UIButton){
        var operation :String!
        if(sender.isSelected == true){
            operation = "dislike"
        }
        else{
            operation = "Like"
        }
        ExpressoUtilityManager.shared.likeOperation(operation : operation ,newsletterID: String(sender.tag),  completion: { (responseDictionary  )  in
            let dictUpdatedObject = responseDictionary as! NSDictionary

            DispatchQueue.main.async {
                
                let dictInfo = ["updatedObject" : dictUpdatedObject ] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "handleUpdatedCount"), object: nil,userInfo: dictInfo)

                
            }
        })
    }
    @objc func handleUpdatedCount(_ notification: Notification){
        
        let updatedObject = notification.userInfo?["updatedObject"] as? NSDictionary
        let updatedLikeCount = updatedObject!["likeCount"] as? String
        let updatedCommentsCount = updatedObject!["commentsCount"] as? String
        let updatedLikeStatus = updatedObject!["likeStatus"] as? Bool
        let newsletterID = updatedObject!["attribute_id"] as? String

        self.newsletters! = self.newsletters!.map({
            if $0.attribute_id == newsletterID {
                $0.likeCount = updatedLikeCount
                $0.likeStatus = updatedLikeStatus
                $0.commentsCount = updatedCommentsCount

            }
            return $0 })
        let newsletterModel: NewsletterModel = self.newsletters![self.newsletter_index]

        self.updateFooterStickyView(newsletterModel)
        
    }
    func animatePage(direction: CATransitionSubtype) {
           let animation = CATransition()
           animation.duration = 0.25
           animation.type = .moveIn
           animation.subtype = direction
           self.view.layer.add(animation, forKey: "newsletterPageChange")
       }
    
    @objc func handleSwipe (swipe : UISwipeGestureRecognizer) {
        if let newsletters = self.newsletters {
            if (swipe.direction == .right && self.newsletter_index > 0) {
                self.newsletter_index -= 1
                let newsletter = newsletters[self.newsletter_index]
                self.title = "\(self.newsletter_index + 1) of \(newsletters.count)"
                self.animatePage(direction: .fromLeft)
                self.loadNewsletter(newsletter , newsletterIndex: self.newsletter_index + 1 )
            }
            else if (swipe.direction == .left && self.newsletter_index < newsletters.count - 1) {
                self.newsletter_index += 1
                let newsletter = newsletters[self.newsletter_index]
                self.title = "\(self.newsletter_index + 1) of \(newsletters.count)"
                self.animatePage(direction: .fromRight)
                self.loadNewsletter(newsletter, newsletterIndex: self.newsletter_index + 1)
            }
        }
    }
    
    
       private func setupNavigationController() {
           let backImage = UIImage(named: "back_arrow")?.withRenderingMode(.alwaysOriginal)
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
           //navigationController?.navigationBar.titleTextAttributes = textAttributes
           
           self.navigationController?.setNavigationBarHidden(false, animated: false)
           self.navigationController?.setToolbarHidden(true, animated: false)
           //self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "header"), for: .default)
           //self.navigationController?.navigationBar.shadowImage = UIImage()
       }
       
       @objc func backImagePressed() {
            // empty image cache
            self.imageCache.removeAll()
            navigationController?.popViewController(animated: true)
       }
    
   
    @objc @IBAction func commentsBtnClicked(_ sender: UIButton) {
        
        let newsletterModel: NewsletterModel = self.newsletters![self.newsletter_index]
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
        let commentViewController = storyBoard.instantiateViewController(withIdentifier: "CommentListingController") as! CommentListingController
        commentViewController.newsLetter = newsletterModel
        commentViewController.viewPresentedFrom = "NewsletterDetailController"
        self.navigationController?.pushViewController(commentViewController, animated: true)
//        let navVC = UINavigationController(rootViewController:commentViewController)
//        navVC.isNavigationBarHidden = true
////        parentViewController!.present(navVC, animated: true, completion:nil)
//
//        self.present(navVC, animated: true, completion: nil)

    }

}

extension NewsletterDetailController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        // fade out animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let animation = CATransition()
            animation.duration = 0.5
            self.tutorialView.layer.add(animation, forKey: "removetutorialanimation")
            self.tutorialView.alpha = 0.0
            
            // remove from superview after a second
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.tutorialView.removeFromSuperview()
            }
        }
    }
}

extension NewsletterDetailController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y =  scrollView.contentOffset.y
        stickyViewCopy.isHidden = !(y > self.headerImageView.bounds.size.height)
        stickyView.isHidden = !stickyViewCopy.isHidden
    }
}
