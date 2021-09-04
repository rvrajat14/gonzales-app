//
//  OrderTrackVC.swift
//  FoodApplication
//
//  Created by Kishore on 20/07/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import GoogleMaps
import ListPlaceholder
import SDWebImage

class OrderTrackVC: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var addressLbl: UILabel!
    var isMapSet = false
    var destinationCoordinates = (lat: "", long : "")

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var orderNumberLbl: UILabel!
    var timer : Timer!
    
    @IBOutlet weak var serverErrorView: UIView!
    @IBAction func callButton(_ sender: UIButton) {
        
        if let  url1 = NSURL(string: "tel://\(driverDetailsDic["phone"] as! String)"),
            UIApplication.shared.canOpenURL(url1 as URL)
        {
            UIApplication.shared.open(url1 as URL, options: [:], completionHandler: nil)
        }
    }
    @IBOutlet weak var driverInfoView: UIView!
    @IBOutlet weak var shimmerView: UIView!
    var locationManager = CLLocationManager()
    var order_id = ""
    var driverDetailsDic = NSDictionary.init()
    var currentzoom : Float = 14.0
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var imageMainView: UIView!
    
    
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var userProfileImageV: UIImageView!
    var pickupMarker : GMSMarker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shimmerView.showLoader()
        self.topView.layer.masksToBounds = true
        self.topView.layer.cornerRadius = 10
        
        self.userProfileImageV.layer.cornerRadius = self.userProfileImageV.frame.size.width/2
        self.userProfileImageV.layer.borderWidth = 2
        self.userProfileImageV.layer.borderColor = UIColor.white.cgColor
        self.getDriverCurrentLocation()
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(getCurrentLocation), userInfo: nil, repeats: true)
        
        orderNumberLbl.text = "Order Tracking #\(order_id)"
        print(driverDetailsDic)
        self.userNameLbl.text = "Driver: " +  COMMON_FUNCTIONS.checkForNull(string: driverDetailsDic["first_name"] as AnyObject).1 + " " +  COMMON_FUNCTIONS.checkForNull(string: driverDetailsDic["last_name"] as AnyObject).1
        var imageURL : URL!
        self.addressLbl.text = ""
        if let image = driverDetailsDic.object(forKey: "photo") as? String
        {
            imageURL = URL(string: IMAGE_BASE_URL + "user/" +  image)
            
        }
        self.userProfileImageV.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "empty_item"), options: .refreshCached, completed: nil)
        self.driverInfoView.isHidden = false
        self.shimmerView.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    //MARK: -Selector Methods
    
    @objc func popVC(_ sender: UIBarButtonItem)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func getCurrentLocation( )   {
        self.getDriverCurrentLocation()
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        currentzoom = mapView.camera.zoom
    }
    
    //MARK: Info Window
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 50))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 6
        let userDataDic = marker.userData as! NSDictionary
        
        let leftView = UIView(frame: CGRect.init(x: 0, y: 0, width: 60, height: 50))
        leftView.backgroundColor = UIColor(red: 57/255.0, green: 87/255.0, blue: 107/255.0, alpha: 1)
        let lbl1 = UILabel(frame: CGRect.init(x: 5, y: 2, width: 50, height: 46))
        lbl1.textAlignment = .center
        lbl1.font = UIFont(name: SEMIBOLD, size: 16)
        lbl1.textColor = UIColor.white
        lbl1.lineBreakMode = .byWordWrapping
        if let time = (userDataDic["estimatedTime"] as? String) {
            lbl1.text = time
        }
        view.addSubview(leftView)
        view.addSubview(lbl1)
        
        let lbl2 = UILabel(frame: CGRect.init(x: 64 , y: 2, width: 136, height: 46))
        lbl2.numberOfLines = 0
        
        lbl2.font = UIFont(name: SEMIBOLD, size: 12)
        if let driverAddress = (userDataDic["address"] as? String) {
            lbl2.text = driverAddress
        }
        
        
        view.addSubview(lbl2)
        
        return view
    }
    
    //MARK: Get Driver Current Position
    func getDriverCurrentPosition(desLatitude: String,desLongitude: String) -> (estimatedTime: String, address:String)  {
        var estimateTime = "", address = ""
        
        let url_string = "https://maps.googleapis.com/maps/api/directions/json?origin=\(destinationCoordinates.lat),\(destinationCoordinates.long)&destination=\(desLatitude),\(desLongitude)&key=AIzaSyC8i3j9ZZAQVWkRX3d4-9HH5yP97gaSUVQ"
        let urlRequest = URLRequest(url: URL(string: url_string)!)
        
        do {
            // Perform the request
            let response : AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
            let data = try NSURLConnection.sendSynchronousRequest(urlRequest, returning: response)
            // Get data as string
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
            print(json)
            let routesArray = (json["routes"] as! NSArray)
            var routeDict : [AnyHashable:Any]!
            
            if routesArray.count > 0 {
                routeDict = routesArray[0] as? [AnyHashable : Any]
                let arrLeg = routeDict["legs"] as? [AnyHashable]
                let dictleg = arrLeg?[0] as? [AnyHashable : Any]
                if let driverAddress = (dictleg?["end_address"] as? String)
                {
                    address = driverAddress
                }
                if let aKey = (dictleg?["duration"] as? [AnyHashable : Any])?["text"] {
                    estimateTime = aKey as! String
                    print("\("Estimated Time \(aKey)")")
                }
            }
            
        } catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        return (estimateTime,address)
    }
    
    //MARK: Set Google Map Setting
    
    func setGoogleMapSetting(driver_latitude:Double,driver_longitude:Double,isAnimation:Bool) {
        if !isMapSet {
            isMapSet = true
        }
        let currentPosition = CLLocationCoordinate2D(latitude: driver_latitude, longitude: driver_longitude)
        if !isAnimation {
            self.googleMapView.clear()
            self.googleMapView?.isMyLocationEnabled = true
            //Location Manager code to fetch current location
            print(currentzoom)
            var googleMapCamera = GMSCameraPosition.camera(withTarget: currentPosition, zoom: 26)
            googleMapView.camera = googleMapCamera
            googleMapView.settings.myLocationButton = false
            googleMapView.isMyLocationEnabled = true
            googleMapView.delegate = self
            googleMapView.mapType = .normal
            googleMapCamera = GMSCameraPosition(target: currentPosition, zoom: currentzoom, bearing: 0.0, viewingAngle: 0.0)
            pickupMarker = GMSMarker()
            googleMapView.animate(to: googleMapCamera)
            self.locationManager.startUpdatingLocation()
            //self.mapMainView.bringSubview(toFront: markerImageView)
            locationManager.startUpdatingLocation()
            self.locationManager.delegate = self
        }
        let (time,address) = getDriverCurrentPosition(desLatitude: String(driver_latitude) , desLongitude: String(driver_longitude))
        pickupMarker.position = currentPosition
        pickupMarker.icon = #imageLiteral(resourceName: "marker-taxi")
        pickupMarker.groundAnchor = CGPoint(x: 1, y: 1)
        pickupMarker.userData = NSDictionary(dictionaryLiteral: ("address",address),("estimatedTime",time))
        pickupMarker.position = currentPosition
        pickupMarker.map = self.googleMapView
        // pickupMarker.isTappable = false
        self.googleMapView.selectedMarker = pickupMarker
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Get Driver Details
    
    
    func getDriverCurrentLocation() {
        
        let api_name = APINAME().GET_DRIVER_LOCATION + "/\(COMMON_FUNCTIONS.checkForNull(string: driverDetailsDic["id"] as AnyObject).1)?timezone=\(localTimeZoneName)"
        
        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init() , is_loader_required: false, success: { (response) in
            
            
            
            if response["status_code"] as! NSNumber == 1
            {
                self.shimmerView.isHidden = true
                self.driverInfoView.isHidden = false
                DispatchQueue.main.async {
                    let dataDic = (response["data"] as! NSDictionary)
                    if dataDic.count > 0
                    {
                        var d_lat = 0.0
                        var d_long = 0.0
                        
                        if let latitude1 = (dataDic.object(forKey: "ag_lat") as? String)
                        {
                            d_lat = Double(latitude1)!
                        }
                        if let longitude1 = (dataDic.object(forKey: "ag_lng") as? String)
                        {
                            d_long = Double(longitude1)!
                        }
                        
                        self.setGoogleMapSetting(driver_latitude: d_lat, driver_longitude: d_long, isAnimation: self.isMapSet)
                    }
                }
                
                
            }
            else
                
            {
                self.view.makeToast((response["message"] as! String), duration: 1, position: .center, title: "", image: nil, style: .init(), completion: { (result) in
                    self.dismiss(animated: true, completion: nil)
                    return
                })
                self.view.clearToastQueue()
            }
            
        }) { (failure) in
            
        }
        
        
    }
    
    
}
