//
//  AppDelegate.swift
//  My MM
//
//  Created by Kishore on 15/10/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import OneSignal
import Fabric
import Crashlytics
import Stripe
import LanguageManager_iOS
import L10n_swift
import GoogleSignIn



var appDataDic = NSDictionary.init()
var loyaltyPoints = ""
var isSearchForCity = true
var isFromFrontPage = false
var order_by_using_front_page = ""
var filter_by_using_front_page = ""
var productCartArray = NSMutableArray.init()
var user_city_location = ""
var selectedCuisineType = ""
var url_type = "url"
var projectId = "food"
var selectedLongitudeForFrontPage = ""
var selectedLatitudeForFrontPage = ""
var user_selected_location_address = ""

var currency_type = ""
var filterURL = ""
var itemFilterURL = ""
var sideMenuDataArray = NSMutableArray.init()
var selectedAddressDictionary = AddressModel()
var selectedPickUpAddressDictionary = AddressModel()
var indexPathForSelectedFoodCategory:IndexPath?
let MAIN_COLOR:UIColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
//let BASE_URL = "http://139.59.86.194:4105/"   /*"api/v1/"*/
var BASE_URL = ""
var location_id = ""
var parent_location_id = ""
var selectedCountry = "Select State"
var selectedCity = "Select City"
var notification_token = ""
var terms_and_condition = ""
var IMAGE_BASE_URL = ""
var selectedTimeForDelivery = ""
var selectedDeliveryDate = ""
var selectedPickupDateForJSON = ""
var selectedPickupDate = ""
var app_type = "", super_app_type = ""
var store_id = ""
var area_id = ""
var store_name = ""
var couponCode = ""
var storeTypeCode = ""
var prefix = "c/"
var isAppVersionOutDated = false
var access_token = "", refresh_token = "",token_type = ""
var localTimeZoneName: String { return TimeZone.current.identifier }
var hasTopNotch: Bool {
    if #available(iOS 11.0,  *) {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }
    return false
}
var versionMsg = ""
var isFromAppdelegate = true
var ITUNESLINK = "https://apps.apple.com/us/app/e-food-ondemand-restaurants/id1470359323?ls=1"
let REGULAR_FONT = "Open Sans"
let ITALIC = "OpenSans-Italic"
let SEMIBOLD = "OpenSans-Semibold"
let ITALIC_SEMIBOLD = "OpenSans-SemiboldItalic"
let BOLD = "OpenSans-Bold"
let stripe_api_version = "2020-03-02"
var paymentContext1 : STPPaymentContext?
var change_lang_internally = false

let CLIENT_SECRET = "f36F4ZZN84kWE9cwYbFj2Y6er5geY9OBXF3hEQO4"

//Online Address = http://139.59.86.194:4105/
// Local Address = http://192.168.1.38/my_mm/public/
var currentLanguage = "en"

var (latitude,longitude) = ("","")
var (appDefaultLong,appDefaultLati,appDefaultLocation) = ("","","") // All these will come from back-end.
var user_current_location = "", selectedLocation = ""

//One Signal APP ID = fa243ba0-f64a-4638-939b-7dcd5f142297
//One SignalRest API = ZDYwNTI0NzgtNThlYy00YWEyLWFmMzctZjhiYTUzOGZmZDFk

//p12 Password = rmudxrebaq

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate,OSSubscriptionObserver,OSPermissionObserver,CrashlyticsDelegate {
    
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
        print(stateChanges)
    }
    
    var window: UIWindow?
    var currentLocation: CLLocation!
    let locationManager = CLLocationManager()
    var geocoder = CLGeocoder()
    var placemark = CLPlacemark()
    let userDefaults = UserDefaults.standard
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        if let currentLang = userDefaults.value(forKey: "currentLanguage") as? String {
            if currentLang == "bs"
                
            {
                LanguageManager.shared.defaultLanguage = .bs
                LanguageManager.shared.setLanguage(language: Languages(rawValue: "bs")!)
            }
            else
            {
                LanguageManager.shared.defaultLanguage = .en
                LanguageManager.shared.setLanguage(language: Languages(rawValue: "en")!)
            }
            currentLanguage = currentLang
            L10n.shared.language = currentLang
            
        }
        
        if  userDefaults.value(forKey: "productCartArray")  != nil{
            let unarchiveData = NSKeyedUnarchiver.unarchiveObject(with: (userDefaults.value(forKey: "productCartArray") as! Data))
            let array = (unarchiveData as! NSArray)
            print(array)
            productCartArray = ((unarchiveData as! NSArray).mutableCopy() as! NSMutableArray)
            if userDefaults.value(forKey: "selectedStoreId")  != nil
            {
                store_id = (userDefaults.value(forKey: "selectedStoreId") as! String)
            }
        }
        else
        {
            store_id = ""
           productCartArray = NSMutableArray.init()
        }
        
        if Language.isRTL
        {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            UINavigationBar.appearance().semanticContentAttribute = .forceRightToLeft
        }
     
        UITabBar.appearance().unselectedItemTintColor = UIColor.darkGray
        UIApplication.shared.statusBarView?.backgroundColor = .white
         Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self])
       
        //getAppData()
        
        if userDefaults.value(forKey: "locationStatus") == nil {
            userDefaults.set(false, forKey: "locationStatus")
        }
        if userDefaults.value(forKey: "refresh_token") != nil {
            refresh_token = (userDefaults.value(forKey: "refresh_token") as! String)
        }
        if userDefaults.value(forKey: "access_token") != nil {
            access_token = (userDefaults.value(forKey: "access_token") as! String)
        }
        if userDefaults.value(forKey: "token_type") != nil {
            token_type = (userDefaults.value(forKey: "token_type") as! String)
        }
       
        if url_type == "url"
        {
            // https://www.ordefy.com/api/%7Bteam-id%7D/m/orders
//            BASE_URL = "https://www.ordefy.com/api/\(projectId)/"
//            IMAGE_BASE_URL = "https://www.ordefy.com/api/goteso-assets/\(projectId)/"
           
//            BASE_URL = "http://52.66.107.213:5017/api/"
//            IMAGE_BASE_URL = "http://52.66.107.213:5017/api/goteso-assets/"
            
            BASE_URL = "https://www.gonzales.ba/api/"
            IMAGE_BASE_URL = "https://www.gonzales.ba/api/goteso-assets/"
        }
        else
        {
            
            BASE_URL = "http://192.168.1.17:8888/ordefy-api/public/"
            IMAGE_BASE_URL = "\(BASE_URL)goteso-assets/8888/"
            
            //                    BASE_URL = "http://139.59.86.194:\(projectId)"
            //                    IMAGE_BASE_URL = "\(BASE_URL)goteso-assets/\(projectId)/"
        }
         //getSettingsDataAPI()
        
        
        GIDSignIn.sharedInstance().clientID = "319502078303-ec6hnvj8u5srmii4cnskcgvgt0utc0fd.apps.googleusercontent.com"
        
       // AIzaSyB_JAn55y5LEfzDoADFHsbBMlSNIOF65ik
        
        GMSServices.provideAPIKey("AIzaSyB_JAn55y5LEfzDoADFHsbBMlSNIOF65ik")
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false,
                                     kOSSettingsKeyInAppLaunchURL: true]
        
        
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            
           print("notificationReceivedBlock")
            
        }
        
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
           
            let payload: OSNotificationPayload? = result?.notification.payload
            
            print("Message = \(String(describing: payload!.body))")
            print("badge number = \(payload?.badge ?? 0)")
            print("notification sound = \(payload?.sound ?? "None")")
//            if let userInfo =  payload!.additionalData as NSDictionary?{
//                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//                let vc = storyboard.instantiateViewController(withIdentifier: "OrderSummaryVC") as! OrderSummaryVC
//              vc.appType = "laundry"
//              vc.order_id = "825"
//                vc.isFromPushNotification = true
//               // vc.postId = CommonClass.checkForNull(string: userInfo.value(forKey: "id")as! NSObject)
//
//                let nav = UINavigationController(rootViewController: vc)
//
//                self.window?.rootViewController?.present(nav, animated: true, completion: nil)
//
//            }
        }
        
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: "03f8029e-0533-475a-8c3c-e40c29c86b1e", handleNotificationReceived: notificationReceivedBlock, handleNotificationAction: notificationOpenedBlock, settings: onesignalInitSettings)
        
 
       
        if launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil
        {
//            let alert = UIAlertController(title: "Test", message:"Message", preferredStyle: UIAlertControllerStyle.alert)
//            
//            // add an action (button)
//            alert.addAction(UIAlertAction(title: "z_ok".getLocalizedValue(), style: UIAlertActionStyle.default, handler: nil))
//            
//            // show alert
//            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
//            alertWindow.rootViewController = UIViewController()
//            alertWindow.windowLevel = UIWindowLevelAlert + 1;
//            alertWindow.makeKeyAndVisible()
//            alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
//        OneSignal.initWithLaunchOptions(launchOptions, appId: "fa243ba0-f64a-4638-939b-7dcd5f142297") { (notificationResult) in
//            let payload = notificationResult?.notification.payload!
//            print(payload?.additionalData! as Any)
//        }
        OneSignal.inFocusDisplayType = .notification
        OneSignal.add(self as OSPermissionObserver)
        OneSignal.add(self as OSSubscriptionObserver)
       
      
        
        #if targetEnvironment(simulator)
        latitude = "30.7135"
        longitude = "76.6972"
        #else
       (latitude,longitude) = getLatitudeAndLongitude()
        #endif
        
        
        
//        let api_name = APINAME().SETTINGS_API
//        let currentVersionNumber = getVersionNumber(version: COMMON_FUNCTIONS.checkForNull(string: Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject).1)
//        
//        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init() , is_loader_required: false, success: { (response) in
//            print(response)
//            if response["status_code"] as! NSNumber == 1
//            {
//                let tempArray = response["data"] as! NSArray
//                
//                for value in tempArray
//                {
//                    let value1 = value as! NSDictionary
//                    if value1.object(forKey: "key") as! String == "currency_symbol"
//                    {
//                        currency_type = value1.object(forKey: "value") as! String
//                    }
//                    if value1.object(forKey: "key") as! String == "terms_and_conditions"
//                    {
//                        terms_and_condition = value1.object(forKey: "value") as! String
//                    }
//                    if value1.object(forKey: "key") as! String == "support_email"
//                    {
//                        self.userDefaults.set(value1.object(forKey: "value") as! String, forKey: "app_email")
//                    }
//                    if value1.object(forKey: "key") as! String == "support_phone"
//                    {
//                        self.userDefaults.set(value1.object(forKey: "value") as! String, forKey: "app_phone")
//                    }
//                    if value1.object(forKey: "key") as! String == "vu_text"
//                    {
//                        versionMsg = value1.object(forKey: "value") as! String
//                    }
//                    if value1.object(forKey: "key") as! String == "i_c_version"
//                    {
//                        let version = self.getVersionNumber(version: value1.object(forKey: "value") as! String)
//                        
//                        if version > currentVersionNumber
//                        {
//                            NotificationCenter.default.post(name: NSNotification.Name("NewVersionUpdatedNotification"), object: nil)
//                            isAppVersionOutDated = true
//                        }
//                        
//                    }
//                    
//                    if value1["key"] as! String == "default_location"
//                    {
//                        let locationDic = (value1["value"] as! NSDictionary)
//                        
//                        appDefaultLati = COMMON_FUNCTIONS.checkForNull(string: locationDic["lat"] as AnyObject).1
//                        appDefaultLong = COMMON_FUNCTIONS.checkForNull(string: locationDic["lng"] as AnyObject).1
//                        appDefaultLocation = COMMON_FUNCTIONS.checkForNull(string: locationDic["title"] as AnyObject).1
//                       // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "defaultLocationNotification"), object: nil)
//                    }
//                    
//                    
//                    if self.userDefaults.value(forKey: "userDefaultLong") != nil &&  self.userDefaults.value(forKey: "userDefaultLati") != nil &&  self.userDefaults.value(forKey: "userDefaultLocation") != nil {
//                        
//                        appDefaultLong =  self.userDefaults.value(forKey: "userDefaultLong") as! String
//                        appDefaultLati =  self.userDefaults.value(forKey: "userDefaultLati") as! String
//                        appDefaultLocation =  self.userDefaults.value(forKey: "userDefaultLocation") as! String
//                        
//                    }
//                    
//                    
//                }
//                
//                
//                DispatchQueue.main.async {
//                    if self.userDefaults.value(forKey: "firstTimeAppOpen") == nil {
//                        // userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
//                        let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
//                        self.window = UIWindow(frame: UIScreen.main.bounds)
//                        let yourVc = storyBoard.instantiateViewController(withIdentifier: "OnBoardingVC") as? OnBoardingVC
//                        if let window = self.window {
//                            window.rootViewController = yourVc
//                        }
//                        self.window?.makeKeyAndVisible()
//                        
//                        
//                    }
//                    else
//                    {
//                        if self.userDefaults.object(forKey: "user_data") == nil  {
//                            let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
//                            self.window = UIWindow(frame: UIScreen.main.bounds)
//                            let yourVc = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as? UINavigationController
//                            if let window = self.window {
//                                window.rootViewController = yourVc
//                            }
//                            self.window?.makeKeyAndVisible()
//                            
//                        }
//                        else
//                            
//                        {
//                            
//                            storeTypeCode = self.userDefaults.value(forKey: "storeTypeCode") as! String
//                            store_id = self.userDefaults.value(forKey: "store_id") as! String
//                            if self.userDefaults.value(forKey: "store_name") != nil
//                            {
//                                store_name = self.userDefaults.value(forKey: "store_name") as! String
//                            }
//                            app_type = self.userDefaults.value(forKey: "app_type") as! String
//                            super_app_type = self.userDefaults.value(forKey: "super_app_type") as! String
//                            
//                            COMMON_FUNCTIONS.addCustomTabBar()
//                            
//                        }
//                        
//                    }
//                    
//                }
//                
//            }
//            
//            
//        }) { (failure) in
//            
//         UIApplication.shared.keyWindow?.makeToast("There is an error to connecting with your server. Please check your internet. ", duration: 5, position: .center, title: "", image: nil, style: .init(), completion: nil)
//            
//        }
      
        return true
    }

  
   
    
    //MARK: Open App from Web Site
    private func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?
        ) -> Void) -> Bool {
        
        // 1
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let _ = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return false
        }
        
        
        // 3
        if let webpageUrl = URL(string: "http://139.59.86.194:4107/laundry/index") {
            application.open(webpageUrl)
            return false
        }
        
        return false
    }
    
    
    
    //MARK: Open App From Other APP
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        
        let txt = url.host?.removingPercentEncoding
        
        
        let alert = UIAlertController(title: "URL Scheme Demo", message:txt, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "z_ok".getLocalizedValue(), style: UIAlertActionStyle.default, handler: nil))
        
        // show alert
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        
        
        
        return true
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
    
    
    //MARK: Get One Signal Push Notification Token
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
        print("SubscriptionStateChange: \n\(String(describing: stateChanges))")
        
        //The player id is inside stateChanges. But be careful, this value can be nil if the user has not granted you permission to send notifications.
        if let playerId = stateChanges.to.userId {
            let userDefaults = UserDefaults.standard
            notification_token = playerId
            userDefaults.setValue(notification_token, forKey: "notification_token")
            print("Current playerId \(notification_token)")
        }
    }
    
    
    
    func getLatitudeAndLongitude() -> (latitude: String, longitude: String) {
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways)
        {
            currentLocation = locationManager.location
            if let currentLocation = currentLocation {
                let latitude = Float(currentLocation.coordinate.latitude)
                let longitude = Float(currentLocation.coordinate.longitude)
                
                return (String(format: "%.4f", latitude),String(format: "%.4f", longitude))
            }
        }
        
        return ("","")
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation =  locations.last
        
        DispatchQueue.main.async {
            self.geocoder.reverseGeocodeLocation(newLocation!) { (placemark, error) in
                
                if error == nil && (placemark?.count)! > 0
                {
                    let latitude1 = Float((newLocation?.coordinate.latitude)!)
                    let longitude1 = Float((newLocation?.coordinate.longitude)!)
                    
                    (latitude,longitude) = (String(format: "%.4f", latitude1),String(format: "%.4f", longitude1))
                    let placemark1 = placemark?.last
                    
                    // Send notification for update home url
                    guard let status = self.userDefaults.value(forKey: "locationStatus") as? Bool else { return  }
                    
                    if !status {
                        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "locationUpdateNotification"), object: nil)
                    }
                    if let subLocality = placemark1?.subLocality
                    {
                        // print("\n subLocality \(subLocality)\n")
                        user_current_location = subLocality
                        
                    }
                    
                    if let name = placemark1?.name
                    {
                        //print("\n name \(name)\n")
                        user_current_location += " " + name
                    }
                    
                    if let locality = placemark1?.locality
                    {
                        //print("\n locality \(locality)\n")
                        user_current_location += ", " + locality
                    }
                    if let administrativeArea = placemark1?.administrativeArea
                    {
                        //print("\n administrativeArea \(administrativeArea)\n")
                        user_current_location += ", " + administrativeArea
                    }
                    if let country = placemark1?.country
                    {
                        //  print("\n country \(country)\n")
                        user_current_location += ", " + country
                    }
                    
                    
                    //self.locationManager.stopUpdatingLocation()
                }
                
            }
        }
    }
    
  
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if productCartArray.count > 0 {
            let archiveData = NSKeyedArchiver.archivedData(withRootObject: productCartArray)
               userDefaults.set(store_id, forKey: "selectedStoreId")
            userDefaults.set(archiveData, forKey: "productCartArray")
            userDefaults.synchronize()
        }
        else
        {
            if userDefaults.value(forKey: "productCartArray") != nil
            {
                userDefaults.removeObject(forKey: "productCartArray")
                  userDefaults.removeObject(forKey: "selectedStoreId")
                 userDefaults.synchronize()
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if userDefaults.value(forKey: "refresh_token") != nil {
            refresh_token = (userDefaults.value(forKey: "refresh_token") as! String)
        }
        if userDefaults.value(forKey: "access_token") != nil {
            access_token = (userDefaults.value(forKey: "access_token") as! String)
        }
        if userDefaults.value(forKey: "token_type") != nil {
            token_type = (userDefaults.value(forKey: "token_type") as! String)
        }
        
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "locationUpdateNotification"), object: nil, userInfo: ["status":false])
                return
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingHeading()
                print("Access")
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        if productCartArray.count > 0 {
            let archiveData = NSKeyedArchiver.archivedData(withRootObject: productCartArray)
             userDefaults.set(store_id, forKey: "selectedStoreId")
            userDefaults.set(archiveData, forKey: "productCartArray")
            userDefaults.synchronize()
        }
        else
        {
            if userDefaults.value(forKey: "productCartArray") != nil
            {
                userDefaults.removeObject(forKey: "productCartArray")
                userDefaults.removeObject(forKey: "selectedStoreId")
                 userDefaults.synchronize()
            }
        }
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

