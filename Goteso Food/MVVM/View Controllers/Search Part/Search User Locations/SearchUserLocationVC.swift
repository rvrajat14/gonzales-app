//
//  SearchUserLocationVC.swift
//  My MM
//
//  Created by Kishore on 07/02/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit
import CRRefresh
import CoreLocation
import NotificationCenter

class SearchUserLocationVC: UIViewController {

    @IBOutlet weak var noDataFoundLbl: UILabel!
    @IBOutlet weak var pageTitleLbl: UILabel!
    var currentPage = 1
    var total_page = 0
    var to_page = 0
    var isGPSLocationOn = false
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var noDataFoundView: UIView!
    @IBOutlet weak var serverErrorView: UIView!
    @IBOutlet weak var tableVeiw: UITableView!
  
    var googlePlacesArray = [AREA]()
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         pageTitleLbl.text = "y_area_title".getLocalizedValue()
        searchTextField.placeholder = "h_location".getLocalizedValue()
        noDataFoundLbl.text = "e_area_title".getLocalizedValue()
        if Language.isRTL {
            searchTextField.textAlignment = .right
        }
        else
        {
            searchTextField.textAlignment = .left
        }
        tableVeiw.tableFooterView = UIView(frame: .zero)
      //  addRefreshFunctionality()
       
       
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        getAreaAPI(search: "", page: 1)
        self.tableVeiw.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdateNotification(_:)), name: NSNotification.Name?.init(NSNotification.Name.init(rawValue: "locationUpdateNotification")), object: nil)
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                self.isGPSLocationOn = false
                UserDefaults.standard.set(false, forKey: "locationStatus")
                
            case .authorizedAlways, .authorizedWhenInUse:
                self.isGPSLocationOn = true
                UserDefaults.standard.set(true, forKey: "locationStatus")
                print("Access")
            }
        } else {
             self.isGPSLocationOn = false
            print("Location services are not enabled")
        }
        CLLocationManager.init().startUpdatingHeading()
      
    }
    
    @objc func locationUpdateNotification(_ notification: Notification)
    {
        if notification.userInfo != nil {
             self.isGPSLocationOn = false
        }
        else
        {
            viewWillAppear(false)
        }
        
    }
    func addRefreshFunctionality()  {
        
                tableVeiw.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
                    self?.tableVeiw.cr.resetNoMore()
                  self?.getAreaAPI(search: "", page: 1)
                    
                }
        
        tableVeiw.cr.addFootRefresh(animator: NormalFooterAnimator()) {
            [weak self] in
           
            if (self?.to_page)! == (self?.total_page)!
            {
                self?.tableVeiw.cr.noticeNoMoreData()
                return
            }
            self?.getAreaAPI(search: "", page: (self?.currentPage)!)
            
            
        }
    }
}

extension SearchUserLocationVC : UITableViewDelegate,UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else
        {
            return googlePlacesArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if  indexPath.section == 0 {
           
            tableView.register(UINib(nibName: "LocalityAreaTableViewCell", bundle: nil), forCellReuseIdentifier: "LocalityAreaTableViewCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocalityAreaTableViewCell", for: indexPath) as! LocalityAreaTableViewCell
            cell.selectionStyle = .none
            
            if !self.isGPSLocationOn
            {
                cell.locationNameLbl.text = "Your GPS is not enabled. Please enabled your GPS in settings."
            }
            else
            {
                 cell.locationNameLbl.text = user_current_location
            }
           
            return cell
            
        }
        else
        {
            self.tableVeiw.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            var cell = tableVeiw.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            if cell.isEqual(nil) {
                cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
           
            cell.textLabel?.text = googlePlacesArray[indexPath.row].title
            if let aSize = UIFont(name: REGULAR_FONT, size: 16) {
                cell.textLabel?.font = aSize
            }
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            if !isGPSLocationOn
            {
                let alert = UIAlertController(title: "Access Denied", message: "You didn't allow to\n access your current location.\n Please enabled your \nlocation.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                }))
                
                alert.addAction(UIAlertAction(title: "z_cancel".getLocalizedValue(), style: .destructive, handler: { (action) in
                    return
                }))
                
                let popPresenter = alert.popoverPresentationController
                popPresenter?.sourceView = self.view
                popPresenter?.sourceRect = (self.view.bounds)
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            else
            {
                if latitude.isNotEmpty && longitude.isNotEmpty
                    
                {
                    userDefaults.setValue(longitude, forKey: "userDefaultLong")
                     userDefaults.setValue(latitude, forKey: "userDefaultLati")
                     userDefaults.setValue(user_current_location, forKey: "userDefaultLocation")
                    
                    appDefaultLati = latitude
                    appDefaultLong = longitude
                    appDefaultLocation = user_current_location
                    
                    userDefaults.synchronize()
                    selectedLocation = ""
                    NotificationCenter.default.post(name: NSNotification.Name.init("UserLocationNotification"), object: nil, userInfo: ["lat":latitude,"long":longitude,"location":user_current_location])
                }
                self.navigationController?.popViewController(animated: true)
            }
            
        }
        
        else
        {
            view.endEditing(true)
            
            let areaData = googlePlacesArray[indexPath.row]
           
            appDefaultLati = areaData.latitude
            appDefaultLong = areaData.longitude
            appDefaultLocation = areaData.title
            
            
            
            userDefaults.setValue(areaData.longitude, forKey: "userDefaultLong")
            userDefaults.setValue(areaData.latitude, forKey: "userDefaultLati")
            userDefaults.setValue(areaData.title, forKey: "userDefaultLocation")
             userDefaults.synchronize()
            
            NotificationCenter.default.post(name: NSNotification.Name.init("UserLocationNotification"), object: nil, userInfo: ["lat":areaData.latitude,"long":areaData.longitude,"location":areaData.title])
                            selectedLocation = ""
                            selectedLocation = areaData.title
                self.navigationController?.popViewController(animated: true)
            }
                        
        self.tableVeiw.isHidden = true
       
    }
    
    
    
    //Area API
    func getAreaAPI(search:String,page:Int)  {
        
        let api_name = APINAME().AREA_API + "?page=\(page)&search=\(search)"
        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: true, success: { (response) in
            print(response)
            
            if response["status_code"] as! NSNumber == 1
            {
                if page == 1
                {
                    
                    self.googlePlacesArray = [AREA]()
                    self.currentPage = 1
                    self.tableVeiw.cr.endHeaderRefresh()
                    self.tableVeiw.cr.endFooterRefresh()
                }
                 let dataArray = ((response["data"] as! NSDictionary).object(forKey: "data") as! NSArray)
                
                if dataArray.count > 0
                {
                    self.total_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "total") as! NSNumber)
                    self.to_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "to") as! NSNumber)
                    if (((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "next_page_url") as? String) != nil
                    {
                        self.currentPage += 1
                    }
                    
                    
                    for areaData in dataArray as! [NSDictionary]
                    {
                        let areaModel = AREA(title: COMMON_FUNCTIONS.checkForNull(string: areaData["title"] as AnyObject).1, longitude: COMMON_FUNCTIONS.checkForNull(string: areaData["longitude"] as AnyObject).1, latitude: COMMON_FUNCTIONS.checkForNull(string: areaData["latitude"] as AnyObject).1)
                       self.googlePlacesArray.append(areaModel)
                    }
                }
                DispatchQueue.main.async {
                    self.tableVeiw.reloadData()
                   
                     self.tableVeiw.cr.endHeaderRefresh()
                    self.tableVeiw.cr.endFooterRefresh()
                    
                }
            }
            else
            {
                self.tableVeiw.cr.endHeaderRefresh()
                self.tableVeiw.cr.endFooterRefresh()
            }
            
        }) { (failure) in
            self.tableVeiw.cr.endHeaderRefresh()
            self.tableVeiw.cr.endFooterRefresh()
        }
        
        
    }
    
}

extension SearchUserLocationVC: UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
       
        if (newString.count) > 1
        {
            print(newString)
            self.getAreaAPI(search: newString, page: 1)
        }
        else
        {
            
        }
        
        
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
}

