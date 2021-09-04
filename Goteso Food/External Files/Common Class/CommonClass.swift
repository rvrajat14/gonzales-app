//
//  CommonClass.swift
//  Laundrit
//
//  Created by Kishore on 10/09/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import Foundation
import UIKit

class COMMON_FUNCTIONS {
    
    class func cartItemCount (productID: String?) -> Int {
        var count = Int()
        count = 1
        
        for  value in (productCartArray as! [ItemModel]) {
            
            if value.id == productID
            {
                count = Int(value.quantity)!
                break
            }
        }
        return count
    }
    
    
    class func getItemJSONFromItemModel() -> NSMutableArray
    {
        let finalItemsArray = NSMutableArray.init()
        
        for value in productCartArray as! [ItemModel] {
            
            
            
            let itemDataDic = NSDictionary(dictionaryLiteral: ("item_id",value.id),("item_title",value.title),("item_price",value.price),("item_discount",value.discount),("store_id",value.store_id),("item_active_status",value.active_status),("photo",value.photo),("thumb_photo",value.thumb_photo),("variants",value.selectedVariants),("actual_variants",value.variants),("quantity",value.quantity),("item_price_single",value.item_price_single),("item_price_total",value.item_price_total),("unit",value.unit))
             
            finalItemsArray.add(itemDataDic)
        }
        
        return finalItemsArray
        
    }
    
    
  class func setView(view: UIView, hidden: Bool,option: UIViewAnimationOptions) {
        UIView.transition(with: view, duration: 1, options: option, animations: {
            view.isHidden = hidden
        })
    }
    
    class func ifProductAlreadyInCart (productID: String?) -> (isMatched: Bool, count: Int, index: Int) {
        var result: Bool
        var count = 0
        
        
        result = false
        
        for (index,value) in (productCartArray as! [ItemModel]).enumerated(){
            
            if value.id == productID
            {
                result = true
                count = Int(value.quantity)!
                return (result,count,index)
                
            }
            result = false
        }
        return (result,count,-1)
    }
    
    //MARK: Get Payment Summary Footer View
    class func getFooterView(title: String,price: String, view: UIView,payment_mode:String, isFooterImageRequired : Bool) -> UIView {
        
        let footerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 80))
        
        footerView.backgroundColor = UIColor.groupTableViewBackground
        let backfooterView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
        backfooterView.backgroundColor = UIColor.white
          footerView.addSubview(backfooterView)
        
        let totalTitleLbl = UILabel()
        backfooterView.addSubview(totalTitleLbl)
        totalTitleLbl.translatesAutoresizingMaskIntoConstraints = false
        totalTitleLbl.leadingAnchor.constraint(equalTo: backfooterView.leadingAnchor, constant: 25).isActive = true
        totalTitleLbl.topAnchor.constraint(equalTo: backfooterView.topAnchor, constant: 14).isActive = true
           totalTitleLbl.widthAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
       // totalTitleLbl.widthAnchor.constraint(equalToConstant: 120).isActive = true
        totalTitleLbl.heightAnchor.constraint(equalToConstant: 24).isActive = true
        totalTitleLbl.textColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
        if payment_mode.isNotEmpty
        {
            totalTitleLbl.text = title + " (\(payment_mode))"
        }
        else
        {
            totalTitleLbl.text = title
        }
        
        totalTitleLbl.font = UIFont(name: "OpenSans-Semibold", size: 17)
        backfooterView.addSubview(totalTitleLbl)
        
        
        let totalPriceLbl = UILabel()
        backfooterView.addSubview(totalPriceLbl)
        totalPriceLbl.translatesAutoresizingMaskIntoConstraints = false
        totalPriceLbl.leadingAnchor.constraint(equalTo: totalTitleLbl.leadingAnchor, constant: 30).isActive = true
        totalPriceLbl.trailingAnchor.constraint(equalTo: backfooterView.trailingAnchor, constant: -25).isActive = true
        totalPriceLbl.topAnchor.constraint(equalTo: backfooterView.topAnchor, constant: 14).isActive = true
        totalPriceLbl.heightAnchor.constraint(equalToConstant: 24).isActive = true
        totalPriceLbl.text = currency_type + price
        totalPriceLbl.font = UIFont(name: "OpenSans-Semibold", size: 17)
        
        print(NSLocale.preferredLanguages[0] as String)
        if  Language.isRTL {
            totalPriceLbl.textAlignment = .left
        }
        else
        {
            totalPriceLbl.textAlignment = .right
        }
        
        if isFooterImageRequired {
            let footerImgV = UIImageView()
            backfooterView.addSubview(footerImgV)
            footerImgV.translatesAutoresizingMaskIntoConstraints = false
            footerImgV.leadingAnchor.constraint(equalTo: backfooterView.leadingAnchor).isActive = true
            footerImgV.trailingAnchor.constraint(equalTo: backfooterView.trailingAnchor).isActive = true
            footerImgV.topAnchor.constraint(equalTo: totalPriceLbl.topAnchor, constant: 40).isActive = true
            footerImgV.heightAnchor.constraint(equalToConstant: 30).isActive = true
            footerImgV.image = #imageLiteral(resourceName: "base")
        }
        
       
       
        print(totalPriceLbl.frame)
        return footerView
        
    }
    
    
    class func addCustomTabBar()
    {
        
        DispatchQueue.main.async {
            
            UIApplication.shared.statusBarView?.backgroundColor = .white
            let viewController = UIApplication.shared.keyWindow?.rootViewController
            let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
            
            let tabBarVC = storyBoard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
             tabBarVC.tabBar.tintColor = MAIN_COLOR
            let ordersVC = storyBoard.instantiateViewController(withIdentifier: "YourOrdersVC") as! YourOrdersVC
            let orderBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "orders"), selectedImage: #imageLiteral(resourceName: "orders"))
            let orderNav = UINavigationController(rootViewController: ordersVC)
            orderNav.isNavigationBarHidden = true
            orderNav.tabBarItem = orderBarItem
            
            
            let notificationVC = storyBoard.instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
            let notificationBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "notifications"), selectedImage: #imageLiteral(resourceName: "notifications"))
            let notificationNav = UINavigationController(rootViewController: notificationVC)
            notificationNav.tabBarItem = notificationBarItem
            notificationNav.isNavigationBarHidden = true
            
            
            let profileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            let profileBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "user"), selectedImage: #imageLiteral(resourceName: "user"))
            let profileNav = UINavigationController(rootViewController: profileVC)
            profileNav.tabBarItem = profileBarItem
             profileNav.isNavigationBarHidden = true
            
            
            let homeBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "home"), selectedImage: #imageLiteral(resourceName: "home"))
            
            if storeTypeCode == "00" {
                
                if super_app_type == "supermarket" {
                    let viewController = storyBoard.instantiateViewController(withIdentifier: "SuperMarketAllMainCategoriesVC") as! SuperMarketAllMainCategoriesVC
                    let homeNav = UINavigationController(rootViewController: viewController)
                    homeNav.isNavigationBarHidden = true
                    homeNav.tabBarItem = homeBarItem
                    tabBarVC.viewControllers = [homeNav,orderNav,notificationNav,profileNav]
                }
                else
                {
                    if app_type == "laundry"
                    {
                        let viewController = storyBoard.instantiateViewController(withIdentifier: "LaundryNewHomeVC") as! LaundryNewHomeVC
                        let homeNav = UINavigationController(rootViewController: viewController)
                        homeNav.tabBarItem = homeBarItem
                        homeNav.isNavigationBarHidden = true
                        tabBarVC.viewControllers = [homeNav,orderNav,notificationNav,profileNav]
                    }
                    else
                    {
                        let viewController =  storyBoard.instantiateViewController(withIdentifier: "LaundryHomePageVC") as! LaundryHomePageVC
                        let homeNav = UINavigationController(rootViewController: viewController)
                        homeNav.tabBarItem = homeBarItem
                        homeNav.isNavigationBarHidden = true
                        tabBarVC.viewControllers = [homeNav,orderNav,notificationNav,profileNav]
                    }
                }
                
            }
            else
            {
                
                    let viewController = storyBoard.instantiateViewController(withIdentifier: "CommonHomeCategoryVC") as! CommonHomeCategoryVC
                    viewController.isForCarCare = true
                    let homeNav = UINavigationController(rootViewController: viewController)
                    homeNav.tabBarItem = homeBarItem
                    homeNav.isNavigationBarHidden = true
                    homeNav.updateFocusIfNeeded()
                    homeNav.automaticallyAdjustsScrollViewInsets = true
                    tabBarVC.viewControllers = [homeNav,orderNav,notificationNav,profileNav]
              
            }
          
            tabBarVC.tabBarController?.tabBar.isHidden = false
            viewController?.navigationController?.isNavigationBarHidden = true
            
            let window = UIApplication.shared.delegate?.window!
            window?.rootViewController = tabBarVC
            window?.makeKeyAndVisible()
            tabBarVC.selectedIndex = !change_lang_internally ? 0 : 3
            change_lang_internally = false
        }
      
    }
    
    
    class func getAppDetails(data: NSDictionary)  {
        
        let userDefaults = UserDefaults.standard
        
        
        if userDefaults.value(forKey: "storeTypeCode") != nil
        {
            userDefaults.removeObject(forKey: "storeTypeCode")
        }
        
        if userDefaults.value(forKey: "store_id") != nil
        {
            userDefaults.removeObject(forKey: "store_id")
        }
        if userDefaults.value(forKey: "app_type") != nil
        {
            userDefaults.removeObject(forKey: "app_type")
        }
        if userDefaults.value(forKey: "super_app_type") != nil
        {
            userDefaults.removeObject(forKey: "super_app_type")
        }
        
        let productName = COMMON_FUNCTIONS.checkForNull(string: data["product"] as AnyObject).1
        let multi_store_value = COMMON_FUNCTIONS.checkForNull(string: data["multi_store"] as AnyObject).1
        if multi_store_value == "0"
        {
            storeTypeCode = "00"
            store_id = COMMON_FUNCTIONS.checkForNull(string: data["store_default_id"] as AnyObject).1
        }
        else
        {
            storeTypeCode = "01"
        }
        if productName == "food" || productName == "laundry"
        {
            super_app_type = "laundry"
        }
        else
        {
            super_app_type = "supermarket"
        }
        app_type = productName
        
        userDefaults.setValue(store_id, forKey: "store_id")
        userDefaults.setValue(storeTypeCode, forKey: "storeTypeCode")
        userDefaults.setValue(app_type, forKey: "app_type")
        userDefaults.setValue(super_app_type, forKey: "super_app_type")
        
        if storeTypeCode == "00" {
            let api_name = APINAME().STORES_API + "/\(store_id)"
            WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: false, success: { (response) in
                print(response)
                
                if response["status_code"] as! NSNumber == 1
                {
                    store_name = ((response["data"] as! NSDictionary)["store_title"] as! String)
                    UserDefaults.standard.set(store_name, forKey: "store_name")
                    
                }
                
            }) { (failure) in
                
            }
        }
        
    }
    
    
    class func showAlert (msg:String)
    {
        
       
        let viewController = UIApplication.shared.keyWindow?.rootViewController
 
       viewController?.view.makeToast(msg, duration: 4, position: .center, title: "", image: nil, style: .init(), completion: nil)
        viewController?.view.clearToastQueue()
        
    }
    
    class func showAlert (msg:String,title:String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "z_ok".getLocalizedValue(), style: .default, handler: { (action) in
            return
        }))
        let viewController = UIApplication.shared.keyWindow?.rootViewController
        
        let popPresenter = alert.popoverPresentationController
        popPresenter?.sourceView = viewController?.view
        popPresenter?.sourceRect = (viewController?.view.bounds)!
        viewController?.present(alert, animated: true, completion: nil)
    }
    
   class func getCorrectPriceFormat(price: String) -> String {
    if price.isEmpty {
        return ""
    }
    let newPrice = price.replacingOccurrences(of: ",", with: "")
    
        let float_value = Float(newPrice)
        return String(format: "%.2f", (float_value)!)
        
        
    }
    
    class func priceFormatWithCommaSeparator(price: String) -> String{
        if price.isEmpty {
            return ""
        }
        if let myInteger = Float(price) {
            let myNumber = NSNumber(value:myInteger)
            let numberFormatter = NumberFormatter()
            numberFormatter.groupingSeparator = ","
            numberFormatter.groupingSize = 3
            numberFormatter.usesGroupingSeparator = true
            numberFormatter.decimalSeparator = "."
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 2
            return  numberFormatter.string(from: myNumber as NSNumber)!
        }
        return ""
    }
    
    
    //MARK: Get Color Name From Hex Code
    
   class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
   class func checkForNull(string: AnyObject) -> (Bool,String) {
        
        if string is NSNull {
            return (true,"")
        }
    let str = String(format: "%@",string as! CVarArg)
    
    
    if str.isEmpty {
       return (true,"")
    }
        return (false,str)
    }
    
    class func isValidPassword(password:String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{5,15}$"
        print(NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password))
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    class func isValidUserName(name:String) -> Bool {
        let nameRegex = "^[A-Za-z_][A-Za-z0-9_]{3,50}$"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: name)
    }
    
    
    //MARK: Total Number of Items in Cart
    
   class func calculateTotalNumberOfItemsInCart() -> String {
        if productCartArray.count > 0 {
            var total_items = 0
            for data in productCartArray as! [ItemModel] {
                
                let count = Int(data.quantity)!
                total_items = total_items + count
            }
            return String(total_items)
        }
        return "0"
    }
    
  class func getTheTotalQuantityOfProductWithId(p_id: String) -> String {
        
        var count = 0
        
        for dataDic in (productCartArray as! [ItemModel]) {
            
            if dataDic.id ==  (p_id)
            {
                count += Int(dataDic.quantity)!
            }
        }
        
        return String(count)
        
    }
    
}




class SHADOW_EFFECT {
    class func makeBottomShadow(forView view: UIView, shadowHeight: CGFloat = 5,color:UIColor = .lightGray,top_shadow: Bool = false, left:Bool = true, bottom:Bool = true, right:Bool = true ,cornerRadius: CGFloat = 4) {
        
        view.addshadow(top: top_shadow, left: left, bottom: bottom, right: right, shadowRadius:  2, color: color,cornerRadius: cornerRadius)
        
    }
    
    
}

extension UIView{
    func addshadow(top: Bool,
                   left: Bool,
                   bottom: Bool,
                   right: Bool,
                   shadowRadius: CGFloat = 1.0, color: UIColor = .lightGray, cornerRadius: CGFloat = 4) {
        
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = color.cgColor
        self.layer.cornerRadius = cornerRadius
        let path = UIBezierPath()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var viewWidth = self.bounds.width
        var viewHeight = self.bounds.height
        
        // here x, y, viewWidth, and viewHeight can be changed in
        // order to play around with the shadow paths.
        if (!top) {
            y+=(shadowRadius+0)
        }
        if (!bottom) {
            viewHeight-=(shadowRadius+1)
        }
        if (!left) {
            x+=(shadowRadius+1)
        }
        if (!right) {
            viewWidth-=(shadowRadius+1)
        }
        // selecting top most point
        path.move(to: CGPoint(x: x, y: y))
        // Move to the Bottom Left Corner, this will cover left edges
        
        path.addLine(to: CGPoint(x: x, y: viewHeight))
        // Move to the Bottom Right Corner, this will cover bottom edge
        
        path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        // Move to the Top Right Corner, this will cover right edge
        
        path.addLine(to: CGPoint(x: viewWidth, y: y))
        // Move back to the initial point, this will cover the top edge
        
        path.close()
        self.layer.shadowPath = path.cgPath
    }
}

