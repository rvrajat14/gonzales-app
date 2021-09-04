//
//  AddNewAddressVC.swift
//  FoodApplication
//
//  Created by Kishore on 17/07/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import GoogleMaps
 


class AddNewAddressVC: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate,UITextFieldDelegate {
     var googlePlacesArray = NSArray.init()
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var serverErrorView: UIView!
   
    @IBAction func doneButton(_ sender: UIButton) {
        self.getTextFieldsValues()
        let (isValid,title) = self.isValid()
        if isValid == true {
            addNewAddressAPI()
        }
        else
        {
            self.view.makeToast(title, duration: 1, position: .center, title: "", image: nil, style: .init(), completion: nil)
            self.view.clearToastQueue()
            
        }
    }
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var navLbl: UILabel!
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var homeButton: UIButton!
    
    @IBAction func homeButton(_ sender: UIButton) {
        workButton.backgroundColor = .white
        otherButton.backgroundColor = .white
        otherButton.setTitleColor(MAIN_COLOR, for: .normal)
        workButton.setTitleColor(MAIN_COLOR, for: .normal)
        sender.backgroundColor = MAIN_COLOR
        sender.setTitleColor(.white, for: .normal)
        address_title = sender.currentTitle!
    }
    @IBAction func workButton(_ sender: UIButton) {
        homeButton.backgroundColor = .white
        otherButton.backgroundColor = .white
        otherButton.setTitleColor(MAIN_COLOR, for: .normal)
        homeButton.setTitleColor(MAIN_COLOR, for: .normal)
         sender.backgroundColor = MAIN_COLOR
        sender.setTitleColor(.white, for: .normal)
        address_title = sender.currentTitle!
    }
    @IBOutlet weak var workButton: UIButton!
   
    
    @IBAction func otherButton(_ sender: UIButton) {
        homeButton.backgroundColor = .white
        workButton.backgroundColor = .white
        workButton.setTitleColor(MAIN_COLOR, for: .normal)
        homeButton.setTitleColor(MAIN_COLOR, for: .normal)
         sender.backgroundColor = MAIN_COLOR
        sender.setTitleColor(.white, for: .normal)
        address_title = sender.currentTitle!
    }
    @IBOutlet weak var otherButton: UIButton!
     var isDataSet = false
    var user_data:UserDataClass!
    var address_title = "z_home".getLocalizedValue()
    var address_line1 = ""
    var address_line2 = ""
    var city = ""
    var state = ""
    var country = ""
    var mobile_number = ""
     var user_full_name = ""
    var address_latitude = ""
    var address_longitude = ""
    var default_address = "0"
    
    
    var isDefaultAddress = false
    var addressDataDictionary = AddressModel()
    var isForAddressEditing = false
    
    
    @IBOutlet weak var mobileNumberTxtField: UITextField!
    @IBOutlet weak var stateTxtField: UITextField!
    @IBOutlet weak var cityTownTxtField: UITextField!
   
    @IBOutlet weak var addressLine2TxtField: UITextField!
    @IBOutlet weak var addressLine1TxtField: UITextField!
    @IBOutlet weak var googleMapiew: GMSMapView!
    var locationManager = CLLocationManager()
    //var user_current_location = ""
    var marker = GMSMarker()
    
    @IBOutlet weak var markerImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
      
        doneButton.setTitle("z_done".getLocalizedValue(), for: .normal)
        workButton.setTitle("z_work".getLocalizedValue().uppercased(), for: .normal)
        homeButton.setTitle("z_home".getLocalizedValue().uppercased(), for: .normal)
        otherButton.setTitle("z_other".getLocalizedValue().uppercased(), for: .normal)
        addressLine1TxtField.placeholder = "h_address_l1".getLocalizedValue()
        addressLine2TxtField.placeholder = "h_address_l2".getLocalizedValue()
        cityTownTxtField.placeholder = "z_city".getLocalizedValue()
        mobileNumberTxtField.placeholder = "h_mobile".getLocalizedValue()
        stateTxtField.placeholder = "y_address_province".getLocalizedValue()
        
        //Check for location permissions
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdateNotification(_:)), name: NSNotification.Name?.init(NSNotification.Name.init(rawValue: "locationUpdateNotification")), object: nil)
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case  .restricted, .denied:
                UserDefaults.standard.set(false, forKey: "locationStatus")
                let alert = UIAlertController(title: "a_address_title".getLocalizedValue(), message: "a_address_desc".getLocalizedValue(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "a_address_title".getLocalizedValue(), style: .default, handler: { (action) in
                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                }))
                
                alert.addAction(UIAlertAction(title: "a_address_use_default".getLocalizedValue(), style: .default, handler: { (action) in
                    return
                }))
                
                let popPresenter = alert.popoverPresentationController
                popPresenter?.sourceView = self.view
                popPresenter?.sourceRect = (self.view.bounds)
                self.present(alert, animated: true, completion: nil)
                
                return
            case .authorizedAlways, .authorizedWhenInUse:
                UserDefaults.standard.set(true, forKey: "locationStatus")
                print("Access")
            }
        } else {
            UserDefaults.standard.set(false, forKey: "locationStatus")
            let alert = UIAlertController(title: "a_address_title".getLocalizedValue(), message: "a_address_desc".getLocalizedValue(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "a_address_title".getLocalizedValue(), style: .default, handler: { (action) in
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "a_address_use_default".getLocalizedValue(), style: .default, handler: { (action) in
               return
            }))
            
            let popPresenter = alert.popoverPresentationController
            popPresenter?.sourceView = self.view
            popPresenter?.sourceRect = (self.view.bounds)
            self.present(alert, animated: true, completion: nil)
            print("Location services are not enabled")
            
        }
        CLLocationManager.init().startUpdatingHeading()
        
        
         self.serverErrorView.isHidden = true
        self.tableView.isHidden = true
       
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.googleMapiew?.isMyLocationEnabled = true
        //Location Manager code to fetch current location
         
        var currentPosition:CLLocationCoordinate2D!
        print(isForAddressEditing)
        DispatchQueue.main.async {
            self.workButton.layer.borderWidth = 1
            self.workButton.layer.borderColor = MAIN_COLOR.cgColor
            self.otherButton.layer.borderWidth = 1
            self.otherButton.layer.borderColor = MAIN_COLOR.cgColor
            self.homeButton.layer.borderWidth = 1
            self.homeButton.layer.borderColor = MAIN_COLOR.cgColor
        }
       
        if isForAddressEditing {
            let old_latitude = Double(addressDataDictionary.latitude)
            let old_longitude = Double(addressDataDictionary.longitude)
            address_latitude = String(old_latitude!)
            address_longitude = String(old_longitude!)
             currentPosition = CLLocationCoordinate2D(latitude: old_latitude!, longitude: old_longitude!)
        }
        else
        {
            if latitude.isNotEmpty && longitude.isNotEmpty
            {
                currentPosition = CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!)
            }
            else
            {
               currentPosition = CLLocationCoordinate2D(latitude: Double(appDefaultLati)!, longitude: Double(appDefaultLong)!)
            }
            
            
            
            DispatchQueue.main.async {
                self.workButton.backgroundColor = .white
                self.otherButton.backgroundColor = .white
                self.otherButton.setTitleColor(MAIN_COLOR, for: .normal)
                self.workButton.setTitleColor(MAIN_COLOR, for: .normal)
                self.homeButton.backgroundColor = MAIN_COLOR
                self.homeButton.setTitleColor(.white, for: .normal)
            }
        }
        
       
        var googleMapCamera = GMSCameraPosition.camera(withTarget: currentPosition, zoom: 20)
        googleMapiew.camera = googleMapCamera
        
        googleMapiew.settings.myLocationButton = true
        
        googleMapiew.isMyLocationEnabled = true
        googleMapiew.delegate = self
        googleMapiew.mapType = .normal
        googleMapCamera = GMSCameraPosition(target: currentPosition, zoom: 14, bearing: 0.0, viewingAngle: 0.0)
        
        googleMapiew.animate(to: googleMapCamera)
        //self.locationManager.startUpdatingLocation()
        
        self.googleMapiew.bringSubview(toFront: markerImageView)
        self.locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        
       
        self.navigationController?.isNavigationBarHidden = true
        let userDefaults = UserDefaults.standard
        let decoded  = userDefaults.object(forKey: "user_data") as! Data
          NSKeyedUnarchiver.setClass(UserDataClass.self, forClassName: "UserDataClass")
        user_data = (NSKeyedUnarchiver.unarchiveObject(with: decoded) as! UserDataClass)
        user_full_name = user_data.user_first_name + " " + user_data.user_last_name
        
        if isForAddressEditing {
             self.setTextFieldsValue()
            self.navLbl.text = "z_update_address".getLocalizedValue()
        //self.navigationItem.title = "Update an Address"
        }
        else
        {
            mobileNumberTxtField.text = user_data.user_mobile_number!
            self.isDataSet = true
        self.navLbl.text = "z_add_address".getLocalizedValue()
        }
        self.homeButton.layer.borderWidth = 1
        self.homeButton.layer.borderColor = MAIN_COLOR.cgColor
        
        
        self.workButton.layer.borderWidth = 1
        self.workButton.layer.borderColor = MAIN_COLOR.cgColor
        
        self.otherButton.layer.borderWidth = 1
        self.otherButton.layer.borderColor = MAIN_COLOR.cgColor
       
    }
    
    
    @objc func locationUpdateNotification(_ notification: Notification)
    {
        if notification.userInfo != nil {
            let alert = UIAlertController(title: "a_address_title".getLocalizedValue(), message: "a_address_desc".getLocalizedValue(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "a_address_title".getLocalizedValue(), style: .default, handler: { (action) in
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "a_address_use_default".getLocalizedValue(), style: .default, handler: { (action) in
                 return
            }))
            
            let popPresenter = alert.popoverPresentationController
            popPresenter?.sourceView = self.view
            popPresenter?.sourceRect = (self.view.bounds)
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            viewDidLoad()
        }
        
    }
    
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        if !isDataSet {
            return
        }
        
        mapView.clear()
        
        
        print("Position = \(position)")
        
        let point = mapView.center
         print("point = \(point)")
        let mapCoordinate = mapView.projection.coordinate(for: point)
        
        let clGeocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
        address_latitude = String(mapCoordinate.latitude)
        address_longitude = String(mapCoordinate.longitude)
        clGeocoder.reverseGeocodeLocation(clLocation) { (placemark, error) in
            if error == nil && (placemark?.count)! > 0
            {
                let placemark1 = placemark?.last
                
                print("Placemark = \(placemark1!)")
                print("Street Address = \(placemark1?.thoroughfare ?? "error")")
             
                print("Address Dictionary = \(String(describing: placemark1?.description))")
                print("Address Dictionary = \(String(describing: placemark1?.addressDictionary))")
                var address1 = "   placemark1?.addressDictionary"
                
                
                    if let name = placemark1?.name
                    {
                         print("\n name \(name)\n")
                         address1 = name
                    }
                
                    if let subLocality = placemark1?.subLocality
                    {
                        print("\n subLocality \(subLocality)\n")
                        address1 +=  " "  + subLocality
                        self.addressLine1TxtField.text = address1
                    }
                    else
                    {
                      self.addressLine1TxtField.text = address1
                    }
                
                    
                    if let locality = placemark1?.locality
                    {
                         print("\n locality \(locality)\n")
                        self.cityTownTxtField.text = locality
                    }
                else
                    {
                        self.cityTownTxtField.text = ""
                }
                    if let administrativeArea = placemark1?.administrativeArea
                    {
                           print("\n administrativeArea \(administrativeArea)\n")
                        self.stateTxtField.text = administrativeArea
                    }
                else
                    {
                     self.stateTxtField.text = ""
                }
                    if let country = placemark1?.country
                    {
                          print("\n country \(country)\n")
                        self.country = country
                    }
                
            }
            else
            {
                print(error!)
            }
        }
    }
    
  
    
    
    
    //MARK: - Selector Methods//////////
    
    @objc func popVC(_ sender: UIBarButtonItem)
    {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Selector
    
    @objc func updateVersionAction()
    {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "VersionVC") as! VersionVC
        self.present(viewController, animated: true, completion: nil)
        return
    }
    
   
    //MARK: -Get TextFields Values
    
    func getTextFieldsValues() {
        address_line1 = addressLine1TxtField.text!
        address_line2 = addressLine2TxtField.text!
        state = stateTxtField.text!
        city = cityTownTxtField.text!
        
        mobile_number = mobileNumberTxtField.text!
        
    }
    
    
    //MARK: -Set TextFields Value
    func setTextFieldsValue() {
        addressLine1TxtField.text = (addressDataDictionary.line1)
         addressLine2TxtField.text = (addressDataDictionary.line2)
         stateTxtField.text = (addressDataDictionary.state)
         cityTownTxtField.text = (addressDataDictionary.city)
        mobileNumberTxtField.text = (addressDataDictionary.phone)
         default_address = (addressDataDictionary.address_default)
        address_title  = (addressDataDictionary.title).uppercased()
        
        DispatchQueue.main.async {
            if self.address_title == "z_home".getLocalizedValue().uppercased() {
                self.workButton.backgroundColor = .white
                self.otherButton.backgroundColor = .white
                self.otherButton.setTitleColor(MAIN_COLOR, for: .normal)
                self.workButton.setTitleColor(MAIN_COLOR, for: .normal)
                self.homeButton.backgroundColor = MAIN_COLOR
                self.homeButton.setTitleColor(.white, for: .normal)
            }
            
            if self.address_title == "z_work".getLocalizedValue().uppercased() {
                self.homeButton.backgroundColor = .white
                self.otherButton.backgroundColor = .white
                self.otherButton.setTitleColor(MAIN_COLOR, for: .normal)
                self.homeButton.setTitleColor(MAIN_COLOR, for: .normal)
                self.workButton.backgroundColor = MAIN_COLOR
                self.workButton.setTitleColor(.white, for: .normal)
            }
            if self.address_title == "z_other".getLocalizedValue().uppercased() {
                self.homeButton.backgroundColor = .white
                self.workButton.backgroundColor = .white
                self.workButton.setTitleColor(MAIN_COLOR, for: .normal)
                self.homeButton.setTitleColor(MAIN_COLOR, for: .normal)
                self.otherButton.backgroundColor = MAIN_COLOR
                self.otherButton.setTitleColor(.white, for: .normal)
            }
        }
        
       
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        if isForAddressEditing {
            isDataSet = true
        }
        
    }
    
    //MARK: -Check For Validation
    
    func isValid() -> (isValid: Bool,title: String) {
        
        if address_line1.isEmpty == true
        {
            return (false,"a_address_l1".getLocalizedValue())
        }
        
        if state.isEmpty == true {
            return (false,"a_address_state".getLocalizedValue())
        }
        
        
        if city.isEmpty == true {
            return (false,"a_address_city".getLocalizedValue())
        }
        
        if mobile_number.isEmpty == true {
            return (false,"h_mobile".getLocalizedValue())
        }
       
        return (true,"Congratulations!")
    }
    
    //MARK: - Add New Address API
    
    func addNewAddressAPI()  {
        
        let params = ["address_type":"customer","address_title":address_title,"address_line1":address_line1,"address_line2":address_line2,"address_phone":mobile_number,"latitude":address_latitude,"longitude":address_longitude,"city":city,"state":state,"country":country,"linked_id":user_data.user_id!,"default":default_address]
        
        print(params)
        let api_name = APINAME()
        var url = ""
        if isForAddressEditing
        {
            let address_id = (addressDataDictionary.id)
            
           url = api_name.ADDRESS_API + "/\(address_id)"
            WebService.requestPUTUrlWithJSONDictionaryParameters(strURL: url , is_loader_required: true, params: params, success: { (response) in
               if !self.serverErrorView.isHidden
               {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
                }
                
                
                
                if response["status_code"] as! NSNumber == 1
                {
                    print(response)
                    
                    self.view.makeToast((response["message"] as! String), duration: 1, position: .center, title: "", image: nil, style: .init(), completion: { (result) in
                         self.navigationController?.popViewController(animated: true)
                    })
                 
                }
                else
                {
                     COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
                    return
                }
            }) { (failure) in
                self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
            }
        }
        else
        {
            url = api_name.ADDRESS_API + "?timezone=\(localTimeZoneName)"
            WebService.requestPostUrlWithJSONDictionaryParameters(strURL: url , is_loader_required: true, params: params, success: { (response) in
                if !self.serverErrorView.isHidden
                {
                    COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
                }
                if response["status_code"] as! NSNumber == 1
                {
                  
                    print(response)
                    
                    self.view.makeToast((response["message"] as! String), duration: 1, position: .center, title: "", image: nil, style: .init(), completion: { (result) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                }
                else
                {
                     COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
                    return
                }
            }) { (failure) in
               self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
            }
        }
        
 
    }
    
   
}


extension AddNewAddressVC : UITableViewDelegate,UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return googlePlacesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if cell.isEqual(nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
      
        return cell
    }
   
    
}
