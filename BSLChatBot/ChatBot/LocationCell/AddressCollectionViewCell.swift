//
//  AddressCollectionViewCell.swift
//  BSLChatBot
//
//  Created by Satinder on 08/11/19.
//  Copyright © 2019 Santosh. All rights reserved.
//

import UIKit
import MapKit
import MessageUI
import MobileCoreServices
import CoreLocation



class AddressCollectionViewCell: UICollectionViewCell,MFMailComposeViewControllerDelegate,CLLocationManagerDelegate ,MKMapViewDelegate{
    
    @IBOutlet weak var lblCompany: UILabel!
    @IBOutlet weak var lblAddress: UILabel!    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnDistance: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnEmail: UIButton!
    var officeLocation  = CLLocation.init(latitude: 0.0, longitude: 0.0)
    var contactnumber : String!
    var email : String!

    var mapObject: MapModel? {
        didSet {
            lblCompany.text = mapObject?.Location
            lblAddress.text = mapObject?.Address?.trimSpaceandNewline
            self.mapView.delegate = self
            self.mapView.showsUserLocation = true
            DistanceCalulatefromUserlocation(mapObject!.longitude, mapObject!.latitude,  lblAddress.text!)
            contactnumber = mapObject?.ContactNumber
            email = mapObject?.EmailID
        }
    }
    
    override var bounds: CGRect {
        didSet {
            self.layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        if contactnumber == nil || contactnumber?.isEmpty == true {
//            btnCall.isUserInteractionEnabled = false
//        }
//        if email == nil || email?.isEmpty == true {
//            btnEmail.isUserInteractionEnabled = false
//        }

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.shadow()
        
        self.mapView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
    }
    
    func shadow()  {
        
        contentView.layer.cornerRadius = 15.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0.5)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        layer.backgroundColor = UIColor.clear.cgColor
        
    }
    
    func DistanceCalulatefromUserlocation(_ longitude : String , _ latitude : String ,_ adrs : String )  {
        

        self.officeLocation = CLLocation.init(latitude: CLLocationDegrees(latitude)!, longitude: CLLocationDegrees(longitude)!)
        let officeLocationString = adrs
        
        let Usercoordinate = appdelegate.userLocation
        let distanceInMeters = Usercoordinate.distance(from: self.officeLocation) / 1000
        self.btnDistance.setTitle(String(format: "%.01fkm", distanceInMeters), for: .normal)


        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(self.officeLocation.coordinate.latitude, self.officeLocation.coordinate.longitude )
        annotation.title = officeLocationString
        self.mapView.addAnnotation(annotation)
        
        self.getDirections(loc1: Usercoordinate.coordinate , loc2: self.officeLocation.coordinate, officeLocationString)
        
        /*let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(adrs) { (placemarks, error) in
            if (error != nil){
                print("error in addressString")
            } else {
                let placemark = placemarks! as [CLPlacemark]
                if placemark.count > 0 {

                    let placemark = placemarks![0]
                    print(placemark)
                    let Usercoordinate = appdelegate.userLocation
                    self.officeLocation = placemark.location!
                    self.officeLocationString = "\(placemark.locality!), \(placemark.administrativeArea!), \(placemark.country!)"
                    let distanceInMeters = Usercoordinate.distance(from: self.officeLocation) / 1000
                    self.btnDistance.setTitle(String(format: "%.01fkm", distanceInMeters), for: .normal)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2DMake(self.officeLocation.coordinate.latitude, self.officeLocation.coordinate.longitude )
                    annotation.title = self.officeLocationString
                    self.mapView.addAnnotation(annotation)

                }
            }
        }*/
        

        
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        
        annotationView!.image = #imageLiteral(resourceName: "pin")
        
        
        return annotationView
    }
    
    
    @IBAction func Call(_ sender: UIButton) {
        
        guard let url = URL(string: "tel://\(contactnumber ?? "0")") else {
            return //be safe
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
        //GlobalClass.CallFunction(mapObject?.ContactNumber ?? "0")
        
    }
    
    @IBAction func Email(_ sender: UIButton) {
        
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients([email])
            mailComposerVC.setSubject("")
            mailComposerVC.setMessageBody("", isHTML: true)
            if let viewController = self.viewControllerForCollectionView as? ChatVC {
                viewController.present(mailComposerVC, animated: true, completion: nil)
            }
        } else {
            let coded = "mailto:\(email ?? "google.com")".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let emailURL = URL(string: coded!)
            {
                if UIApplication.shared.canOpenURL(emailURL)
                {
                    UIApplication.shared.open(emailURL, options: [:], completionHandler: { (result) in
                        if !result {
                            // show some Toast or error alert
                            //("Your device is not currently configured to send mail.")
                        }
                    })
                }
            }
        }
        
        //GlobalClass.EmailSend(mapObject!.EmailID)
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("Saved")
        case MFMailComposeResult.sent.rawValue:
            print("Sent")
        case MFMailComposeResult.failed.rawValue:
            print("Error: \(String(describing: error?.localizedDescription))")
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    
    @IBAction func googleMap(_ sender: UIButton) {
        
    
        if (UIApplication.shared.canOpenURL(URL(string:"https://www.google.com/maps/")!)) {
        UIApplication.shared.open(URL(string:"https://www.google.com/maps/dir/?api=1&origin=\("\(appdelegate.userLocation.coordinate.latitude),\(appdelegate.userLocation.coordinate.longitude)")&destination=\("\(self.officeLocation.coordinate.latitude),\(self.officeLocation.coordinate.longitude)")&mode=driving&zoom=14&views=traffic")!, options: [:])
        }
        else {
            print("Can't use comgooglemaps://");
        }
        
    }
    
    
    func getDirections(loc1: CLLocationCoordinate2D, loc2: CLLocationCoordinate2D , _ adrs :  String ) {
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: loc1))
        source.name = appdelegate.userLocationString
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: loc2))
        destination.name = adrs
        
        let directionRequest = MKDirections.Request()
        
        directionRequest.source = source
        directionRequest.destination = destination

        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        // 8.
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    
    @IBAction func UberButton(_ sender: UIButton) {
        
    }
    
}
