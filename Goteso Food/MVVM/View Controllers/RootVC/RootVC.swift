//
//  RootVC.swift
//  Food
//
//  Created by Apple on 11/09/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class RootVC: UIViewController {
    
    @IBOutlet weak var bottomLbl: UILabel!
    
    var statusBarColor : UIColor!
    @IBAction func reloadButton(_ sender: UIButton) {
        updateUI()
        self.reloadButton.isHidden = true
    }
    @IBOutlet weak var reloadButton: UIButton!
    let userDefaults = UserDefaults.standard
    var window: UIWindow?
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomLbl.text = "b_powered_by".getLocalizedValue()
        reloadButton.setTitle("z_reload".getLocalizedValue(), for: .normal)
        reloadButton.layer.cornerRadius = 5
        updateUI()
        statusBarColor = UIApplication.shared.statusBarView?.backgroundColor
        UIApplication.shared.statusBarView?.backgroundColor = view.backgroundColor
    }
    
    
    
    func updateUI()  {
        if Connectivity.isConnectedToInternet {
            
            let api_name = APINAME().SETTINGS_API
            let currentVersionNumber = getVersionNumber(version: COMMON_FUNCTIONS.checkForNull(string: Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject).1)
            
            WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init() , is_loader_required: false, success: { (response) in
                print(response)
                if response["status_code"] as! NSNumber == 1
                {
                    let tempArray = response["data"] as! NSArray
                     var appDataDict = [String:Any]()
                    for value in tempArray
                    {
                        let value1 = value as! NSDictionary
                        
                        
                        if value1.object(forKey: "key") as! String == "product"
                        {
                            appDataDict["product"] = COMMON_FUNCTIONS.checkForNull(string: value1["value"] as AnyObject).1
                            
                        }
                        
                        if value1.object(forKey: "key") as! String == "multi_store"
                        {
                            appDataDict["multi_store"] = COMMON_FUNCTIONS.checkForNull(string: value1["value"] as AnyObject).1
                            
                        }
                        
                        if value1.object(forKey: "key") as! String == "store_default_id"
                        {
                            appDataDict["store_default_id"] = COMMON_FUNCTIONS.checkForNull(string: value1["value"] as AnyObject).1
                            
                        }
                        
                        
                        if value1.object(forKey: "key") as! String == "currency_symbol"
                        {
                            currency_type = value1.object(forKey: "value") as! String
                        }
                        if value1.object(forKey: "key") as! String == "terms_and_conditions"
                        {
                            terms_and_condition = value1.object(forKey: "value") as! String
                        }
                        if value1.object(forKey: "key") as! String == "support_email"
                        {
                            self.userDefaults.set(value1.object(forKey: "value") as! String, forKey: "app_email")
                        }
                        if value1.object(forKey: "key") as! String == "support_phone"
                        {
                            self.userDefaults.set(value1.object(forKey: "value") as! String, forKey: "app_phone")
                        }
                        if value1.object(forKey: "key") as! String == "vu_text"
                        {
                            versionMsg = value1.object(forKey: "value") as! String
                        }
                        if value1.object(forKey: "key") as! String == "i_c_version"
                        {
                            let version = self.getVersionNumber(version: value1.object(forKey: "value") as! String)
                            
                            if version > currentVersionNumber
                            {
                                NotificationCenter.default.post(name: NSNotification.Name("NewVersionUpdatedNotification"), object: nil)
                                isAppVersionOutDated = true
                            }
                            
                        }
                        
                        if value1["key"] as! String == "default_location"
                        {
                            let locationDic = (value1["value"] as! NSDictionary)
                            
                            appDefaultLati = COMMON_FUNCTIONS.checkForNull(string: locationDic["lat"] as AnyObject).1
                            appDefaultLong = COMMON_FUNCTIONS.checkForNull(string: locationDic["lng"] as AnyObject).1
                            appDefaultLocation = COMMON_FUNCTIONS.checkForNull(string: locationDic["title"] as AnyObject).1
                            // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "defaultLocationNotification"), object: nil)
                        }
                        
                        
                        if self.userDefaults.value(forKey: "userDefaultLong") != nil &&  self.userDefaults.value(forKey: "userDefaultLati") != nil &&  self.userDefaults.value(forKey: "userDefaultLocation") != nil {
                            
                            appDefaultLong =  self.userDefaults.value(forKey: "userDefaultLong") as! String
                            appDefaultLati =  self.userDefaults.value(forKey: "userDefaultLati") as! String
                            appDefaultLocation =  self.userDefaults.value(forKey: "userDefaultLocation") as! String
                            
                        }
                        
                        
                    }
                    
                    
                      COMMON_FUNCTIONS.getAppDetails(data: appDataDict as NSDictionary)
                    
                    UIApplication.shared.statusBarView?.backgroundColor = self.statusBarColor
                    
                    DispatchQueue.main.async {
                        if self.userDefaults.value(forKey: "firstTimeAppOpen") == nil {
                            // userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                            let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
                            self.window = UIWindow(frame: UIScreen.main.bounds)
                            let yourVc = storyBoard.instantiateViewController(withIdentifier: "OnBoardingVC") as? OnBoardingVC
                            if let window = self.window {
                                window.rootViewController = yourVc
                            }
                            self.window?.makeKeyAndVisible()
                            
                            
                        }
                        else
                        {
                            if self.userDefaults.object(forKey: "user_data") == nil  {
                                let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
                                self.window = UIWindow(frame: UIScreen.main.bounds)
                                let yourVc = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as? UINavigationController
                                if let window = self.window {
                                    window.rootViewController = yourVc
                                }
                                self.window?.makeKeyAndVisible()
                                
                            }
                            else
                                
                            {
                                
                                storeTypeCode = self.userDefaults.value(forKey: "storeTypeCode") as! String
                                store_id = self.userDefaults.value(forKey: "store_id") as! String
                                if self.userDefaults.value(forKey: "store_name") != nil
                                {
                                    store_name = self.userDefaults.value(forKey: "store_name") as! String
                                }
                                app_type = self.userDefaults.value(forKey: "app_type") as! String
                                super_app_type = self.userDefaults.value(forKey: "super_app_type") as! String
                                
                                COMMON_FUNCTIONS.addCustomTabBar()
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                
            }) { (failure) in
                
                
                
                self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
                     self.reloadButton.isHidden = false
                })
               
                
            }
        }
        else
        {
            self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
                self.reloadButton.isHidden = false
            })
            
            
        }
    }
    
    func getVersionNumber(version:String) -> Int {
        
        var tmpString = ""
        
        for value in version.components(separatedBy: ".") {
            tmpString += value
        }
        
        if tmpString.isNotEmpty {
            return Int(tmpString)!
        }
        else
        {
            return -1
        }
        
    }
    
 
}
