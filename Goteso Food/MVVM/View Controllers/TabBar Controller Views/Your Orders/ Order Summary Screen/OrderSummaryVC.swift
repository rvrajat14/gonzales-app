////
////  OrderSummaryVC.swift
////  FoodApplication



//
//  OrderSummaryVC.swift
//  FoodApplication
//
//  Created by Kishore on 07/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import IQKeyboardManager
import MapKit
import CoreLocation
import MaterialComponents.MaterialBottomSheet
import NotificationCenter

let LABEL_H_MARGIN:CGFloat = 80
let PRICE_LABEL_WIDTH:CGFloat = 180
let SMALL_SIZE = 13
let BIG_SIZE = 15


class OrderSummaryVC: UIViewController {
    
    
    @IBOutlet weak var extraPaymentLbl: UILabel!
    
    
    
    
    
//    var payPalConfig = PayPalConfiguration()
//    var payment : PayPalPayment!
    var selected_payment_gateway = ""
    var paypalCurrencySymbol = ""
    var extraPaymentDict = NSDictionary()
    var extraPaymentAmount = ""
    var destinationCoordinates = (lat: "", long : "")

    let extraViewHeight : CGFloat = 120
    
      var user_data:UserDataClass!
     var window:UIWindow!
    var order_action = ""
    var storeId = ""
    var order_id = ""
    var rating_value = ""
    var orderButtonTitle = ""
    var store_long = "",store_lati = ""
    var isFromCheckOut = false
    var isFromOrderPlace = false
    var appType = ""
    var driverDetailsDic = NSDictionary.init()
    var cancelReasonDataArray = NSMutableArray.init()
    var store_phone_number = ""
    var isFromPushNotification = false
    var orderCancelReasonStr = ""
    
    
    @IBOutlet weak var extraPaymentButton: UIButton!
    @IBOutlet weak var extraPaymentStatusLbl: UILabel!
    @IBOutlet weak var extraPaymentPriceLbl: UILabel!
    @IBOutlet weak var extraPaymentDateLbl: UILabel!
    @IBOutlet weak var extraPaymentView: UIView!
     @IBOutlet weak var extraViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var serverErrorView: UIView!
    
    @IBOutlet weak var blurV: UIView!
    @IBOutlet weak var homeButtonWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var homeButtonImg: UIImageView!
    
    @IBAction func homeButton(_ sender: UIButton) {
        if (sender.currentTitle?.isEmpty)! {
            let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
//            self.window = UIWindow(frame: UIScreen.main.bounds)
//            let yourVc = storyBoard.instantiateViewController(withIdentifier: "TabBarVC") as? UITabBarController
//            if let window = self.window {
//                window.rootViewController = yourVc
//            }
//            self.window?.makeKeyAndVisible()
            
            COMMON_FUNCTIONS.addCustomTabBar()
//            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
//            self.navigationController?.pushViewController(viewController, animated: true)
        }
       else
        {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
            viewController.isForReorder = true
              app_type = appType
            viewController.order_id = self.order_id
            self.navigationController?.pushViewController(viewController, animated: true)
        }
       
    }
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var navLbl: UILabel!
    @IBAction func backButton(_ sender: UIButton) {
        let userDefaults = UserDefaults.standard
        
        if isFromPushNotification {
            storeTypeCode = userDefaults.value(forKey: "storeTypeCode") as! String
            store_id = userDefaults.value(forKey: "store_id") as! String
            if userDefaults.value(forKey: "store_name") != nil
            {
                store_name = userDefaults.value(forKey: "store_name") as! String
            }
            app_type = userDefaults.value(forKey: "app_type") as! String
            super_app_type = userDefaults.value(forKey: "super_app_type") as! String
//            let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
//            self.window = UIWindow(frame: UIScreen.main.bounds)
//            let yourVc = storyBoard.instantiateViewController(withIdentifier: "TabBarVC") as? UITabBarController
//            if let window = self.window {
//                window.rootViewController = yourVc
//            }
//            self.window?.makeKeyAndVisible()
            COMMON_FUNCTIONS.addCustomTabBar()
          self.tabBarController?.selectedIndex = 0
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func extraPaymentButton(_ sender: UIButton) {
        
        if (extraPaymentDict["options"]as! NSArray).count > 1 {
            openActionSheet()
        }
        else if (extraPaymentDict["options"]as! NSArray).count == 1
        {
            
            let dataDic = ((extraPaymentDict["options"]as! NSArray)[0] as! NSDictionary)
            selected_payment_gateway = dataDic["identifier"] as! String
            if dataDic["identifier"] as! String == "paypal"
            {
//                setPayPalEnvirontment(dataDic: dataDic["data"] as! NSDictionary)
                
            }
        }
    }
    
    @IBAction func orderButton(_ sender: UIButton) {
     
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderActionVC") as! OrderActionVC
        
        if order_action == "cancel" {
            self.blurV.isHidden = false
            viewController.orderActionType = "cancel"
            viewController.order_id = order_id
             self.present(viewController, animated: true, completion: nil)
            return
        }
        
        if order_action == "track" {
            let viewTrackController = self.storyboard?.instantiateViewController(withIdentifier: "OrderTrackVC") as! OrderTrackVC
            viewTrackController.destinationCoordinates = self.destinationCoordinates

            viewTrackController.order_id = order_id
            viewTrackController.driverDetailsDic = driverDetailsDic
            let bottomSheet = MDCBottomSheetController(contentViewController: viewTrackController)
            bottomSheet.contentViewController.preferredContentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height - 200)
             self.present(bottomSheet, animated: true, completion: nil)
            return
        }
        if order_action == "feedback" {
             self.blurV.isHidden = false
            viewController.orderActionType = "feedback"
            viewController.order_id = order_id
            self.present(viewController, animated: true, completion: nil)
            return
        }
    
    }
    
    
    
    @IBOutlet weak var orderButton: UIButton!
   
    var allDataArray:NSMutableArray!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navLbl.text = "y_order_details".getLocalizedValue()
        extraPaymentLbl.text = ""
         self.serverErrorView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(BlurVHideNotification(notification:)), name: NSNotification.Name?.init(NSNotification.Name.init("BlurVHideNotification")), object: nil)
        
        allDataArray = NSMutableArray.init()
      
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.estimatedRowHeight = 50
 
        if isFromOrderPlace {
            self.homeButton.isHidden = false
            self.homeButtonImg.isHidden = false
            self.homeButton.setTitle("", for: .normal)
            self.homeButtonWidth.constant = 40
        }
        else
        {
            self.homeButton.setImage(nil, for: .normal)
            self.homeButton.setTitle("Reorder", for: .normal)
            self.homeButton.isHidden = true
            self.homeButtonWidth.constant = 90
            self.homeButtonImg.isHidden = true
        }
        
        let userDefaults = UserDefaults.standard
        let decoded  = userDefaults.object(forKey: "user_data") as! Data
          NSKeyedUnarchiver.setClass(UserDataClass.self, forClassName: "UserDataClass")
        user_data = (NSKeyedUnarchiver.unarchiveObject(with: decoded) as! UserDataClass)
      
        //getLocalJSON()
        
        self.CallApi(loader: true)
     
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if isFromOrderPlace {
            backButton.isHidden = true
        }
        else
        {
            backButton.isHidden = false
        }
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Add Right Button On NavigationBar
    
    func setNavigationRightButton(button_title:String)  {
        let rightNavButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 90, y: 0, width: 70, height: 40))
        rightNavButton.setTitle(button_title, for: .normal)
        rightNavButton.setTitleColor(MAIN_COLOR, for: .normal)
        rightNavButton.addTarget(self, action: #selector(rightNavButton(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightNavButton)
        
    }
    
    
    
    //MARK: Local Json
    func getLocalJSON()  {
        if let path = Bundle.main.path(forResource: "OrderDetailsLocalJSON", ofType: "json")
        {
            do
            {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Array<AnyObject>
                {
                    
                    let tempArray = (jsonResult as NSArray)
                    DispatchQueue.main.async {
                        
                        for dic in tempArray
                        {
                            let dic1 =  (dic as! NSDictionary).mutableCopy() as! NSMutableDictionary
                            
                            //                     if dic1.object(forKey: "type") as! String == "order_basic_details"
                            //                     {
                            //                        let orderBasicDataDic = (dic1.object(forKey: "data") as! NSArray).object(at: 0) as! NSDictionary
                            //                        let orderNumber = (orderBasicDataDic.object(forKey: "order_id") as! NSNumber).stringValue
                            //                        let ordertype = (orderBasicDataDic.object(forKey: "type") as! String)
                            //
                            //                        self.getTableHeaderView(order_number: orderNumber, order_type: ordertype)
                            //
                            //                    }
                            
                            
                            if dic1.object(forKey: "type") as! String == "order_meta"
                            {
                                self.allDataArray.add(dic1)
                            }
                            if dic1.object(forKey: "type") as! String == "store_details"
                            {
                                self.allDataArray.add(dic1)
                            }
                            if dic1.object(forKey: "type") as! String == "delivery_address"
                            {
                                self.allDataArray.add(dic1)
                            }
                            if dic1.object(forKey: "type") as! String == "items"
                            {
                                self.allDataArray.add(dic1)
                            }
                            if dic1.object(forKey: "type") as! String == "payment_details"
                            {
                                self.allDataArray.add(dic1)
                            }
                            if dic1.object(forKey: "type") as! String == "customer_buttons"
                            {
                                print(dic1)
                                let buttonDataDic = (dic1.object(forKey: "data") as! NSArray).object(at: 0) as! NSDictionary
                                self.order_action = (buttonDataDic.object(forKey: "action") as! String)
                                self.orderButton.setTitle((buttonDataDic.object(forKey: "title") as! String), for: .normal)
                                if (buttonDataDic.object(forKey: "enabled") as! String) == "1"
                                {
                                    self.orderButton.backgroundColor = MAIN_COLOR
                                    self.orderButton.isEnabled = true
                                }
                                else
                                {
                                    self.orderButton.backgroundColor = UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1)
                                    self.orderButton.isEnabled = false
                                }
                                
                            }
                            if dic1.object(forKey: "type") as! String == "loyalty_points"
                            {
                                self.allDataArray.add(dic1)
                            }
                            
                            if dic1.object(forKey: "type") as! String == "order_cancel_reasons"
                            {
                                self.allDataArray.add(dic1)
                            }
                            
                        }
                        
                        self.tableView.reloadData()
                    }
                }
            }
            catch
            {
                
            }
        }
        
    }
    
    
    
    
    //MARK: - Call API
    
    func CallApi(loader:Bool) -> Void{
         
      
        let api_name = APINAME()
        let url = api_name.ORDERS_API + "/\(order_id)?customer_id=\(user_data.user_id!)&timezone=\(localTimeZoneName)"
        
        print(url)
        WebService.requestGetUrl(strURL: url, params: NSDictionary.init(), is_loader_required: loader, success: { (response) in
            print(response)
            
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
             if response["status_code"] as! NSNumber == 1
             {
            
            let tempArray = (response["data"] as! NSArray)
            DispatchQueue.main.async {
                
                if let extraPaymentDict = response["pending_payment"] as? NSDictionary
                {
                    self.extraPaymentDict = extraPaymentDict
                    self.extraViewHeightConstraint.constant = self.extraViewHeight
                    self.extraPaymentPriceLbl.text = currency_type + " " + COMMON_FUNCTIONS.getCorrectPriceFormat(price: COMMON_FUNCTIONS.checkForNull(string: (self.extraPaymentDict["data"] as! NSDictionary)["amount"] as AnyObject).1)
                    self.extraPaymentDateLbl.text = "Pending since: " + COMMON_FUNCTIONS.checkForNull(string: (self.extraPaymentDict["data"] as! NSDictionary)["created_at_formatted"] as AnyObject).1
                    self.extraPaymentStatusLbl.text = COMMON_FUNCTIONS.checkForNull(string: (self.extraPaymentDict["data"] as! NSDictionary)["status"] as AnyObject).1.uppercased()
                    self.extraPaymentAmount = COMMON_FUNCTIONS.getCorrectPriceFormat(price: COMMON_FUNCTIONS.checkForNull(string: (self.extraPaymentDict["data"] as! NSDictionary)["amount"] as AnyObject).1)
                    self.extraPaymentView.isHidden = false
                }
                else
                {
                    self.extraPaymentView.isHidden = true
                    self.extraViewHeightConstraint.constant = 0
                }
                
                let buttonDetails = response["button"] as! NSDictionary
                
                    self.order_action = (buttonDetails.object(forKey: "action") as! String)
                    self.orderButton.setTitle((buttonDetails.object(forKey: "title") as! String), for: .normal)
                    if (buttonDetails.object(forKey: "enabled") as! NSNumber) == 1
                    {
                        self.orderButton.isEnabled = true
                        
                        if self.order_action == "cancel"
                        {
                            let tmpArray = (buttonDetails["reason"] as! NSArray) as! [String]
                            self.cancelReasonDataArray.removeAllObjects()
                            for value in tmpArray
                            {
                               self.cancelReasonDataArray.add(NSDictionary(dictionaryLiteral: ("title",value),("isSelected","0")))
                            }
                        }
                     
                    }
                    else
                    {
                       
                        self.orderButton.isEnabled = false
                    }
                
               self.orderButton.backgroundColor = self.hexStringToUIColor(hex: (buttonDetails.object(forKey: "color") as! String))
                
                for dic in tempArray
                {
                    let dic1 =  (dic as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    
 
                    
                    if dic1.object(forKey: "type") as! String == "order_status"
                    {
                        self.allDataArray.add(dic1)
                        if dic1["cancel_reason"] != nil
                        {
                            self.orderCancelReasonStr = COMMON_FUNCTIONS.checkForNull(string: dic1["cancel_reason"] as AnyObject).1
                        }
                    }
                    
                    if dic1.object(forKey: "type") as! String == "driver"
                    {
                        self.allDataArray.add(dic1)
                        if self.order_action == "track"
                        {
                            self.driverDetailsDic = ((dic1.object(forKey: "data") as! NSArray).object(at: 0) as! NSDictionary)
                        }
                    }
                    
                    if dic1.object(forKey: "type") as! String == "order_info"
                    {
                        self.allDataArray.add(dic1)
                    }
                    if dic1.object(forKey: "type") as! String == "store"
                    {
                        self.allDataArray.add(dic1)
                    }
                     if dic1.object(forKey: "type") as! String == "delivery_address"
                     {
                        self.allDataArray.add(dic1)
                         self.destinationCoordinates = (COMMON_FUNCTIONS.checkForNull(string: ((dic1["data"] as! NSDictionary)["data"] as! NSDictionary)["latitude"] as AnyObject).1,COMMON_FUNCTIONS.checkForNull(string: ((dic1["data"] as! NSDictionary)["data"] as! NSDictionary)["longitude"] as AnyObject).1)
                   }
                    if dic1.object(forKey: "type") as! String == "items"
                    {
                        self.allDataArray.add(dic1)
                    }
                    if dic1.object(forKey: "type") as! String == "payment_summary"
                    {
                        self.allDataArray.add(dic1)
                    }
                    
                    if dic1.object(forKey: "type") as! String == "pickup_address"
                    {
                        self.allDataArray.add(dic1)
                    }
                    
                    
                    
                }
                
                self.tableView.reloadData()
            }
            }
            else
             {
                self.view.makeToast((response["message"] as! String))
            }
        }) { (failure) in
             self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
    }
 
    
    //MARK: Extra Payment Gateways
    
    
    func openActionSheet()  {
        
        let tempArray =  (extraPaymentDict["options"]as! NSArray)
        
        let alertController = UIAlertController(title: "y_payment_method".getLocalizedValue(), message: nil, preferredStyle: .actionSheet)
        
        for  value in (tempArray as! [NSDictionary])  {
            
            alertController.addAction(UIAlertAction(title: value["title"]as? String, style: .default, handler: { (action) in
                print(value)
              
                self.selected_payment_gateway = value["identifier"] as! String
                if value["identifier"] as! String == "paypal"
                {
//                    self.setPayPalEnvirontment(dataDic: value["data"] as! NSDictionary)
                    
                }
                
                return
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "z_cancel".getLocalizedValue(), style: .destructive, handler: { (action) in
            print("Cancel")
        }))
        
        if UIDevice().userInterfaceIdiom == .pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                 
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: Paypal Payment
//    func paypalPayment()  {
//
//        let amount = NSDecimalNumber(string: COMMON_FUNCTIONS.getCorrectPriceFormat(price: extraPaymentAmount))
//
//        payment = PayPalPayment(amount: amount , currencyCode: paypalCurrencySymbol, shortDescription: " ", intent: .sale)
//        if (payment.processable) {
//            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
//
//            present(paymentViewController!, animated: true, completion: nil)
//        }
//
//    }
    
    
    //MARK: Set PayPal Environment
    
//    func setPayPalEnvirontment(dataDic:NSDictionary)  {
//        paypalCurrencySymbol = (dataDic["currency_symbol"] as! String)
//        if dataDic["type"] as! String == "LIVE" {
//            PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: "AVKiqR8k5M1Cc6dLI3tCmDoo5b9lV6LXiY_X4I-2QA-3I8IM-36ijhxrmPN-LPFl3DfIrnqELgLUl4UR"])
//            PayPalMobile.preconnect(withEnvironment: PayPalEnvironmentProduction)
//
//        }
//        else if dataDic["type"] as! String == "NONETWORK"
//        {
//
//
//        }
//        else
//        {
//            PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentSandbox:"AQ_5GqxMO770tKvkDZF40ygXprnAsy6O5pI-sC8cbJgsSLhf_35d2oP62-COCW4CeJSAlNvcL0_oiDjm"])
//            PayPalMobile.preconnect(withEnvironment: PayPalEnvironmentSandbox)
//
//        }
//        self.paypalPayment()
//    }
    
    
    
}



extension OrderSummaryVC: UITableViewDataSource,UITableViewDelegate
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if allDataArray.count > 0 {
            
            let mainDictionary = allDataArray.object(at: indexPath.section) as! NSMutableDictionary
            
            
            if mainDictionary.object(forKey: "type") as! String == "order_status" {
                
                let orderDatadic = mainDictionary.object(forKey: "data") as! NSDictionary
                
                let nib:UINib = UINib(nibName: "OrderStatusTableCell", bundle: nil)
                
                tableView.register(nib, forCellReuseIdentifier: "OrderStatusTableCell")
                
                let cell  = tableView.dequeueReusableCell(withIdentifier: "OrderStatusTableCell", for: indexPath) as! OrderStatusTableCell
                
                cell.orderStatusLbl.layer.cornerRadius = cell.orderStatusLbl.frame.size.height / 2
                cell.orderStatusLbl.text = (orderDatadic["order_status"] as! String).uppercased()
                cell.statusWidthConstraints.constant = cell.orderStatusLbl.optimalWidth + 30
                if self.orderCancelReasonStr.isNotEmpty
                {
                    cell.cancelReasonLbl.isHidden = false
                    cell.cancelReasonLbl.text = self.orderCancelReasonStr
                }
                else
                {
                     cell.cancelReasonLbl.isHidden = true
                    cell.cancelReasonLbl.text = ""
                }
                cell.orderIdLbl.text = "#\(order_id)"
                cell.orderTimeLbl.text =  orderDatadic["created_at"] as? String
                 cell.orderStatusLbl.backgroundColor = self.hexStringToUIColor(hex: (orderDatadic.object(forKey: "label_color") as! String))
                cell.selectionStyle = .none
                
                return cell
            }
            
            if mainDictionary.object(forKey: "type") as! String == "order_info" {
                
                let orderDatadic = (mainDictionary.object(forKey: "data") as! NSArray).object(at: indexPath.row) as! NSDictionary
                
                let nib:UINib = UINib(nibName: "OrderSummaryTableCell", bundle: nil)
                
                tableView.register(nib, forCellReuseIdentifier: "OrderSummaryTableCell")
                
                let cell:OrderSummaryTableCell = tableView.dequeueReusableCell(withIdentifier: "OrderSummaryTableCell", for: indexPath) as! OrderSummaryTableCell
                let titleString = orderDatadic.object(forKey: "title") as? String
                var valueString = orderDatadic.object(forKey: "display_value") as? String
                if (valueString?.isEmpty)!
                {
                   valueString = orderDatadic.object(forKey: "value") as? String
                }
               cell.titleLbl.text = (mainDictionary.object(forKey: "title") as! String)
                let formattedString = NSMutableAttributedString()
                
                if Language.isRTL
                {
                formattedString
                     .normal(valueString!  + "  :")
                    .bold(titleString!)
                   
                }
                else
                {
                formattedString
                    .bold(titleString! + ":   ")
                        .normal(valueString!)
                }
                cell.value1Lbl.attributedText = formattedString
                
                 cell.selectionStyle = .none
                if indexPath.row == 0
                {
                    cell.titleLblHeightConstraints.constant = 44
                    cell.titleLbl.isHidden = false
                }
                else
                {
                    cell.titleLbl.isHidden = true
                    cell.titleLbl.text = ""
                    cell.titleLblHeightConstraints.constant = 0
                }
                return cell
            }
            
            if mainDictionary.object(forKey: "type") as! String == "store" {
                
                
                let nib:UINib = UINib(nibName: "OrderInformationTableCell", bundle: nil)
                
                tableView.register(nib, forCellReuseIdentifier: "OrderInformationTableCell")
                let cell:OrderInformationTableCell = tableView.dequeueReusableCell(withIdentifier: "OrderInformationTableCell", for: indexPath) as! OrderInformationTableCell
                cell.titleLbl.text  = (mainDictionary.object(forKey: "title") as! String)
                if (mainDictionary.object(forKey: "data") as! NSArray).count > 0
                {
                let userInfoDataDictionary = ((mainDictionary.object(forKey: "data") as! NSArray).object(at: 0) as! NSDictionary)
//                if let storeId = userInfoDataDictionary.object(forKey: "store_id") as? NSNumber
//                {
//                    store_id = storeId.stringValue
//                    
//                    }
//                else  if let storeId = userInfoDataDictionary.object(forKey: "store_id") as? String
//                {
//                    store_id = storeId
//                    
//                    }
                    
                    
                    var imageUrl : URL!
                    if let image = userInfoDataDictionary.object(forKey: "store_photo") as? String
                    {
                       
                        imageUrl = URL(string: IMAGE_BASE_URL + "store/" +  image)
                    }
                    
                        cell.storeImgV.sd_setImage(with: imageUrl, placeholderImage:#imageLiteral(resourceName: "user_placeholder"))
                    
                    self.store_phone_number = (userInfoDataDictionary.object(forKey: "store_phone") as! String)
                cell.nameLbl.text = (userInfoDataDictionary.object(forKey: "store_title") as! String)
                cell.addressLbl.text = (userInfoDataDictionary.object(forKey: "address") as! String)
                    store_lati = (userInfoDataDictionary.object(forKey: "latitude") as! String)
                    store_long = (userInfoDataDictionary.object(forKey: "longitude") as! String)
                }
                cell.customOrderNotificationButton.addTarget(self, action: #selector(actionButtonAction(sender:)), for: .touchUpInside)
                cell.callButton.addTarget(self, action: #selector(storeCallButtonAction(sender:)), for: .touchUpInside)
                
                cell.selectionStyle = .none
                return cell
            }
            
            
            if mainDictionary.object(forKey: "type") as! String == "order_cancel_reasons" {
                
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OrderCancelTableCell")
                var cell  = tableView.dequeueReusableCell(withIdentifier: "OrderCancelTableCell", for: indexPath)
                
                if cell.isEqual(nil)
                {
                    cell = UITableViewCell(style: .default, reuseIdentifier: "OrderCancelTableCell")
                }
                
                if (mainDictionary.object(forKey: "data") as! NSArray).count > 0
                {
                    let orderCancelReasonDic = ((mainDictionary.object(forKey: "data") as! NSArray).object(at: 0) as! NSDictionary)
                    cell.textLabel?.numberOfLines = 0
                    cell.textLabel?.font = UIFont(name: REGULAR_FONT, size: 14)
                    cell.textLabel?.text = "\(orderCancelReasonDic.object(forKey: "label") as! String) : \(orderCancelReasonDic.object(forKey: "value") as! String)"
                }
               
                cell.selectionStyle = .none
                return cell
            }
            
            
            if mainDictionary.object(forKey: "type") as! String == "driver" {
                
                let driverInfoDataDictionary = ((mainDictionary.object(forKey: "data") as! NSArray).object(at: 0) as! NSDictionary)
               
                let nib:UINib = UINib(nibName: "UserInfoTableCell", bundle: nil)
                
                tableView.register(nib, forCellReuseIdentifier: "UserInfoTableCell")
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoTableCell", for: indexPath) as! UserInfoTableCell
                  cell.titleLbl.text = (mainDictionary.object(forKey: "title") as! String)
                let first_name = driverInfoDataDictionary["first_name"] as! String
                let last_name = driverInfoDataDictionary["last_name"] as! String
                cell.nameLbl.text = first_name + " " + last_name
                var imageUrl : URL!
                var imgName = ""
                if let image = driverInfoDataDictionary.object(forKey: "photo") as? String
                {
                    imgName = image
                    imageUrl = URL(string: IMAGE_BASE_URL + "user/" +  image)
                }
                
                if imageUrl == nil || imgName.isEmpty
                {
                    cell.imageView1.setImage(string:  cell.nameLbl.text)
                }
                else
                {
                    cell.imageView1.sd_setImage(with: imageUrl, placeholderImage:#imageLiteral(resourceName: "user_placeholder"))
                }
                cell.imageView1.layer.cornerRadius = cell.imageView1.frame.size.width/2
                cell.addressLbl.text =  (driverInfoDataDictionary["email"] as! String)
                cell.callButton.tag = indexPath.section
                cell.callButton.addTarget(self, action: #selector(driverCallButtonAction(_:)), for: .touchUpInside)
                cell.selectionStyle = .none
                return cell
            }
            
            
            
            if mainDictionary.object(forKey: "type") as! String == "items" {
                
                let orderItemsDataArray = mainDictionary.object(forKey: "data") as! NSArray
                
                let nib:UINib = UINib(nibName: "OrderItemsTableCell", bundle: nil)
                
                tableView.register(nib, forCellReuseIdentifier: "OrderItemsTableCell")
                
                let cell:OrderItemsTableCell = tableView.dequeueReusableCell(withIdentifier: "OrderItemsTableCell", for: indexPath) as! OrderItemsTableCell
                if tableView.numberOfRows(inSection: indexPath.section) > 1
                {
                   cell.mainTitleLbl.text  = "\(tableView.numberOfRows(inSection: indexPath.section))  " + "z_items".getLocalizedValue()
                }
                else
                {
                    cell.mainTitleLbl.text  = "\(tableView.numberOfRows(inSection: indexPath.section))  " + "z_item".getLocalizedValue()
                }
               
                if indexPath.row == 0
                {
                    cell.titleLblHeightConstraints.constant = 20
                    cell.amountLblHeightConstraints.constant = 20
                    cell.titleLbl.isHidden = false
                    cell.amountLbl.isHidden = false
                    cell.mainTitleLbl.isHidden = false
                    cell.mainTitleLblHeightConstraints.constant = 24
                    cell.titleLbl.text = "Title"
                    cell.titleLbl.text = "z_title".getLocalizedValue()
                    cell.amountLbl.text = "z_amount".getLocalizedValue()
                }
                else
                {
                    cell.titleLbl.isHidden = true
                    cell.mainTitleLbl.isHidden = true
                    cell.mainTitleLblHeightConstraints.constant = 0
                    cell.titleLblHeightConstraints.constant = 0
                    cell.amountLblHeightConstraints.constant = 0
                    cell.amountLbl.isHidden = true
                }
                
 
                let tempDictionary = orderItemsDataArray.object(at: indexPath.row) as! NSDictionary
                let quantity = (tempDictionary.object(forKey: "quantity") as! String)
                
                cell.numberOfItemsLbl.text =  "\(quantity) x "
                
                if let image = tempDictionary.object(forKey: "item_thumb_photo") as? String
                {
                    let imageUrl = URL(string: IMAGE_BASE_URL + "item/" +  image)
                    cell.itemImageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "empty_item"), options: .refreshCached, completed: nil)
                }
                let total_price = COMMON_FUNCTIONS.priceFormatWithCommaSeparator(price: COMMON_FUNCTIONS.checkForNull(string: tempDictionary.object(forKey: "total_item_display_price") as AnyObject).1)
                
                cell.totalPriceLbl.text = currency_type + total_price
                cell.priceLblWidthConstraints.constant = cell.totalPriceLbl.optimalWidth + 10
                cell.itemNameLbl.text = (tempDictionary.object(forKey: "item_title") as! String)
                var unit = COMMON_FUNCTIONS.checkForNull(string: tempDictionary["unit"] as AnyObject).1
                
                if unit.isEmpty
                {
                    unit = "z_per_item".getLocalizedValue()
                }
                else
                {
                    unit = "z_per".getLocalizedValue() + " \(unit)"
                }
                
                let servicesDataArray = (tempDictionary["variants"] as! NSArray) as! [NSDictionary]
                var servicesList = ""
                
                if servicesDataArray.count > 0
                {
                    for value in servicesDataArray
                    {
                        if !servicesList.isEmpty
                        {
                            servicesList += ", "
                        }
                        servicesList += value["order_item_variant_value"] as! String
                    }
                }
                let unitStr = NSAttributedString(string: servicesList.isEmpty ? unit : "\n" + unit , attributes: [NSAttributedStringKey.foregroundColor : UIColor.lightGray,.font:UIFont(name: REGULAR_FONT, size: 13)!])
              
                let serviceStr = NSAttributedString(string:  servicesList, attributes: [NSAttributedStringKey.foregroundColor : UIColor.black,.font:UIFont(name: REGULAR_FONT, size: 13)!])
                let finalStr = NSMutableAttributedString()
               
                finalStr.append(serviceStr)
                 finalStr.append(unitStr)
                if servicesList.isEmpty
                {
                     cell.categoryTitleLbl.isHidden = false
                    cell.categoryTitleLbl.attributedText = unitStr
                }
                else
                {
                    cell.categoryTitleLbl.isHidden = false
                    cell.categoryTitleLbl.attributedText = finalStr
                }
              
                cell.selectionStyle = .none
                
                if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
                {
                    cell.separatorV.isHidden = true
                }
                else
                {
                    cell.separatorV.isHidden = false
                }
                
               cell.setLableHeight(string: (tempDictionary.object(forKey: "item_title") as! String))
                return cell
            }
            if mainDictionary.object(forKey: "type") as! String == "payment_summary"  {
                
                let orderPaymentSummaryDataDic = (mainDictionary.object(forKey: "data")  as! NSArray).object(at: indexPath.row) as! NSDictionary
                
                let pam_title = orderPaymentSummaryDataDic.object(forKey: "title") as! String
                let value =  COMMON_FUNCTIONS.priceFormatWithCommaSeparator(price: COMMON_FUNCTIONS.checkForNull(string: orderPaymentSummaryDataDic.value(forKey: "value")as AnyObject).1 )
                if pam_title == "line"
                {
                    let nib  = UINib(nibName: "LineVTableCell", bundle: nil)
                    tableView.register(nib, forCellReuseIdentifier: "LineVTableCell")
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LineVTableCell", for: indexPath) as! LineVTableCell
                    
                    cell.selectionStyle = .none
                    return cell
                }
                
                let nib:UINib = UINib(nibName: "PaymentSummaryTableCell", bundle: nil)
                
                tableView.register(nib, forCellReuseIdentifier: "PaymentSummaryTableCell")
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentSummaryTableCell", for: indexPath) as! PaymentSummaryTableCell
                
                cell.valueLbl.text = currency_type + value
                
                cell.titleLbl.text = pam_title
                
                if indexPath.row == self.tableView.numberOfRows(inSection: indexPath.section) - 1
                {
                    cell.separatorView.isHidden = false
                }
                else
                {
                    cell.separatorView.isHidden = true
                }
                
                cell.selectionStyle = .none
                return cell
            }
            
          if mainDictionary.object(forKey: "type") as! String == "delivery_address"    {
            
            
                let orderAddressDatadictionary = ((mainDictionary.object(forKey: "data") as! NSDictionary)["data"] as! NSDictionary)
                
                let nib:UINib = UINib(nibName: "OrderDeliveryAddressTableViewCell", bundle: nil)
                
                
                tableView.register(nib, forCellReuseIdentifier: "OrderDeliveryAddressTableViewCell")
                
                let cell:OrderDeliveryAddressTableViewCell = tableView.dequeueReusableCell(withIdentifier: "OrderDeliveryAddressTableViewCell", for: indexPath) as! OrderDeliveryAddressTableViewCell
                print(orderAddressDatadictionary)
            cell.titleLbl.text = (mainDictionary["title"] as! String)
                var addressString = ""
                 addressString  = (orderAddressDatadictionary.object(forKey: "address_title") as! String)
            
                    addressString += "\n" + COMMON_FUNCTIONS.checkForNull(string: (orderAddressDatadictionary.object(forKey: "address_line1") as AnyObject)).1
            
            
                    addressString += ", " + COMMON_FUNCTIONS.checkForNull(string: (orderAddressDatadictionary.object(forKey: "address_line2") as AnyObject)).1
            
                    addressString += "\n" + COMMON_FUNCTIONS.checkForNull(string: (orderAddressDatadictionary.object(forKey: "city") as AnyObject)).1
            
                    addressString += ", " + COMMON_FUNCTIONS.checkForNull(string: (orderAddressDatadictionary.object(forKey: "state") as AnyObject)).1
            
                    addressString += ", " + COMMON_FUNCTIONS.checkForNull(string: (orderAddressDatadictionary.object(forKey: "country") as AnyObject)).1
            cell.mapButton.tag = indexPath.section
            cell.mapButton.addTarget(self, action: #selector(mapButton(_:)), for:.touchUpInside)
                cell.deliveryAddressLbl.text = addressString
                cell.selectionStyle = .none
                
                return cell
            }
            
            if mainDictionary.object(forKey: "type") as! String == "pickup_address"    {
                
                let orderPickupAddress = ((mainDictionary.object(forKey: "data") as! NSDictionary)["data"] as! NSDictionary)
                
                let nib:UINib = UINib(nibName: "OrderDeliveryAddressTableViewCell", bundle: nil)
                
                
                tableView.register(nib, forCellReuseIdentifier: "OrderDeliveryAddressTableViewCell")
                
                let cell:OrderDeliveryAddressTableViewCell = tableView.dequeueReusableCell(withIdentifier: "OrderDeliveryAddressTableViewCell", for: indexPath) as! OrderDeliveryAddressTableViewCell
                print(orderPickupAddress)
                cell.titleLbl.text = (mainDictionary["title"] as! String)
                var addressString = ""
                addressString  = (orderPickupAddress.object(forKey: "address_title") as! String)
                
                addressString += "\n" + COMMON_FUNCTIONS.checkForNull(string: (orderPickupAddress.object(forKey: "address_line1") as AnyObject)).1
                
                
                addressString += "," + COMMON_FUNCTIONS.checkForNull(string: (orderPickupAddress.object(forKey: "address_line2") as AnyObject)).1
                
                addressString += "\n" + COMMON_FUNCTIONS.checkForNull(string: (orderPickupAddress.object(forKey: "city") as AnyObject)).1
                
                addressString += ", " + COMMON_FUNCTIONS.checkForNull(string: (orderPickupAddress.object(forKey: "state") as AnyObject)).1
                
                addressString += ", " + COMMON_FUNCTIONS.checkForNull(string: (orderPickupAddress.object(forKey: "country") as AnyObject)).1
                
                cell.deliveryAddressLbl.text = addressString
                cell.mapButton.tag = indexPath.section
                cell.mapButton.addTarget(self, action: #selector(mapButton1(_:)), for:.touchUpInside)
                cell.selectionStyle = .none
                
                return cell
            }
          
        }
        return UITableViewCell(frame: CGRect.zero)
    }
  
    func numberOfSections(in tableView: UITableView) -> Int {
        if allDataArray.count > 0 {
            return allDataArray.count
        }
        else
        {
            return 0
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if allDataArray.count > 0 {
            let mainDictionary = allDataArray.object(at: section) as! NSMutableDictionary
            
            if mainDictionary.object(forKey: "type") as! String == "items"
            {
                return (mainDictionary.object(forKey: "data") as! NSArray).count
            }
            else if mainDictionary.object(forKey: "type") as! String == "order_info"
            {
                return (mainDictionary.object(forKey: "data") as! NSArray).count
            }
            else if mainDictionary.object(forKey: "type") as! String == "payment_summary"
            {
                return (mainDictionary.object(forKey: "data") as! NSArray).count
            }
            else
            {
                return 1
            }
        }
        else
        {
            return 0
        }
    }
    
   
    
    //MARK: - Set Height For Footer and Header Of Sections////////////
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if allDataArray.count > 0 {
            let mainDictionary = allDataArray.object(at: section) as! NSMutableDictionary
            
            if mainDictionary.object(forKey: "type") as! String == "payment_summary"
            {
                return 80
            }
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if allDataArray.count > 0 {
            let mainDictionary = allDataArray.object(at: section) as! NSMutableDictionary
            
            if mainDictionary.object(forKey: "type") as! String == "payment_summary"
            {
                return 64
            }
        }
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && orderCancelReasonStr.isEmpty {
            return 80
        }
          return UITableViewAutomaticDimension
       
    }
    
    
    
    //MARK: - Set Section Footer View ////////
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let v = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
        if section == 0 {
            v.backgroundColor = UIColor.groupTableViewBackground
            return v
        }
        
        v.backgroundColor = .white
        
        if allDataArray.count > 0 {
            let mainDictionary = allDataArray.object(at: section) as! NSMutableDictionary
            
            if mainDictionary.object(forKey: "type") as! String == "payment_summary"
            {
                print(mainDictionary)
                let total = String(format: "%@", ((mainDictionary.object(forKey: "total")) as! CVarArg ))
                let payment_gateway =  COMMON_FUNCTIONS.checkForNull(string: (mainDictionary.object(forKey: "payment_gateway")) as AnyObject).1
                
                return COMMON_FUNCTIONS.getFooterView(title: "z_grand_total".getLocalizedValue(), price: total, view: self.view, payment_mode: payment_gateway, isFooterImageRequired: false)
            }
            
            if section == tableView.numberOfSections - 2 {
                 let mainDictionary = allDataArray.object(at: section + 1) as! NSMutableDictionary
                if mainDictionary.object(forKey: "type") as! String == "payment_summary"
                {
                   return v
                }
                else
                {
                    let lbl = UILabel(frame: CGRect(x: 16, y: 5, width: self.view.frame.size.width - 16, height: 0.5))
                    lbl.backgroundColor = UIColor(red: 218/255.0, green: 218/255.0, blue: 218/255.0, alpha: 1)
                    v.addSubview(lbl)
                    return v
                }
                
            }
            
            if mainDictionary.object(forKey: "type") as! String != "payment_summary" && section == tableView.numberOfSections - 1
            {
                return v
            }
            
        }
        
        
        let lbl = UILabel(frame: CGRect(x: 16, y: 5, width: self.view.frame.size.width - 16, height: 0.5))
        lbl.backgroundColor = UIColor(red: 218/255.0, green: 218/255.0, blue: 218/255.0, alpha: 1)
        v.addSubview(lbl)
        return v
        
        
        
    }
    
    //////////////////////////////////////////////////////////
    
    //MARK: - Set Section Header View ////////
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if allDataArray.count > 0 {
            let mainDictionary = allDataArray.object(at: section) as! NSMutableDictionary
 
            if mainDictionary.object(forKey: "type") as! String == "payment_summary"
            {
                return self.getHeaderView(title: (mainDictionary.object(forKey: "title") as! String) )
            }
            

        }

        let v = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 3))
        v.backgroundColor = .white
        return v
    }
    
    
    ///////////////////////////////////
    
    //MARK: Check For Null
    
    
    func checkForNull(string: AnyObject) -> (Bool) {
        
        if string is NSNull {
            return (true)
        }
        let checkStr = String(format: "%@", string as! CVarArg)
        if checkStr.isEmpty
        {
            return true
        }
        return (false)
    }
    
    
    
    //MARK: - Selector Methods/////////////////////
    
    
    @objc func mapButton1(_ sender: UIButton )
    {
        
       // COMMON_FUNCTIONS.showAlert(msg: <#T##String#>)
        
        let mainDictionary = allDataArray.object(at: sender.tag) as! NSMutableDictionary
        let addressDataDict = ((mainDictionary.object(forKey: "data") as! NSDictionary)["data"] as! NSDictionary)
        let lat = addressDataDict["latitude"] as! String
        let long = addressDataDict["longitude"] as! String
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Apple Map", style: .default, handler: { (action) in
            let url = "http://maps.apple.com/maps?saddr=\(lat),\(long)&daddr=\(latitude),\(longitude)"
            UIApplication.shared.open(URL(string:url)!, options: [:], completionHandler: nil)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Google Map", style: .default, handler: { (action) in
            if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
                UIApplication.shared.open(URL(string: "comgooglemaps://?saddr=\(lat),\(long)&daddr=\(latitude),\(longitude)")!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(URL(string: "http://maps.google.com/maps?saddr=\(lat),\(long)&daddr=\(latitude),\(longitude)&zoom=14&views=traffic")!, options: [:], completionHandler: nil)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "z_cancel".getLocalizedValue(), style: .cancel, handler: { (action) in
            return
        }))
        
        let popPresenter = alertController.popoverPresentationController
        popPresenter?.sourceView = self.view
        popPresenter?.sourceRect = self.view.bounds
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    @objc func mapButton(_ sender: UIButton )
    {
        let mainDictionary = allDataArray.object(at: sender.tag) as! NSMutableDictionary
        let addressDataDict = ((mainDictionary.object(forKey: "data") as! NSDictionary)["data"] as! NSDictionary)
        let lat = addressDataDict["latitude"] as! String
         let long = addressDataDict["longitude"] as! String
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Apple Map", style: .default, handler: { (action) in
            let url = "http://maps.apple.com/maps?saddr=\(lat),\(long)&daddr=\(latitude),\(longitude)"
            UIApplication.shared.open(URL(string:url)!, options: [:], completionHandler: nil)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Google Map", style: .default, handler: { (action) in
            if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
                UIApplication.shared.open(URL(string: "comgooglemaps://?saddr=\(lat),\(long)&daddr=\(latitude),\(longitude)")!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(URL(string: "http://maps.google.com/maps?saddr=\(lat),\(long)&daddr=\(latitude),\(longitude)&zoom=14&views=traffic")!, options: [:], completionHandler: nil)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "z_cancel".getLocalizedValue(), style: .cancel, handler: { (action) in
            return
        }))
        
      
        if UIDevice.current.userInterfaceIdiom == .pad {
                         
        let popoverController = alertController.popoverPresentationController
        popoverController?.sourceView = self.view
        popoverController?.sourceRect = self.view.bounds
        popoverController?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated: true, completion: nil)
      
    }
    
    @objc func driverCallButtonAction(_ sender: UIButton )
    {
        let mainDictionary = allDataArray.object(at: sender.tag) as! NSMutableDictionary
        let addressDataDict = ((mainDictionary.object(forKey: "data") as! NSArray).object(at: 0) as! NSDictionary)
        let phoneNumber = (addressDataDict["phone"] as! String)
        if phoneNumber.isEmpty {
            return
        }
        
        if let  url1 = NSURL(string: "tel://\(phoneNumber)"),
            UIApplication.shared.canOpenURL(url1 as URL)
        {
            UIApplication.shared.open(url1 as URL, options: [:], completionHandler: nil)
        }
    }
    
    @objc func customerCallButtonAction(sender: UIButton,event: AnyObject )
    {
        let mainDictionary = allDataArray.object(at: sender.tag) as! NSMutableDictionary
        let addressDataDict = ((mainDictionary.object(forKey: "data") as! NSArray).object(at: 0) as! NSDictionary)
        let phoneNumber = (addressDataDict["phone"] as! String)
        if phoneNumber.isEmpty {
            return
        }
        
        if let  url1 = NSURL(string: "tel://\(phoneNumber)"),
            UIApplication.shared.canOpenURL(url1 as URL)
        {
            UIApplication.shared.open(url1 as URL, options: [:], completionHandler: nil)
        }
    }
    
    @objc func BlurVHideNotification(notification: Notification)
    {
        if let userInfo = notification.userInfo {
            if (userInfo["actionResponse"] as? String) != nil
            {
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderCancelReasonVC") as! OrderCancelReasonVC
                viewController.user_id = user_data.user_id
                viewController.order_id = order_id
                viewController.cancelReasonDataArray = cancelReasonDataArray
                self.present(viewController, animated: true, completion: nil)
            }
            if let msg = userInfo["toastMsg"] as? String
            {
                self.view.makeToast(msg, duration: 2, position: .bottom, title: "", image: nil, style: .init(), completion: nil)
                self.blurV.isHidden = true
                self.allDataArray.removeAllObjects()
                self.CallApi(loader: false)
            }
         }
        else
        {
            self.blurV.isHidden = true
            self.allDataArray.removeAllObjects()
            self.CallApi(loader: false)
        }
        
        
        
    }
    @objc func storeCallButtonAction(sender: UIButton)
    {
        if let  url1 = NSURL(string: "tel://\(self.store_phone_number)"),
            UIApplication.shared.canOpenURL(url1 as URL)
        {
            UIApplication.shared.open(url1 as URL, options: [:], completionHandler: nil)
        }
    }
    
   
    
    @objc func actionButtonAction(sender: UIButton)
    {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomOrderNotificationVC") as! CustomOrderNotificationVC
            viewController.order_id = order_id
            self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func rightNavButton(sender:UIButton)
    {
        
     if sender.currentTitle == "Home"
        {
            productCartArray.removeAllObjects()
//            let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
//            self.window = UIWindow(frame: UIScreen.main.bounds)
//            let yourVc = storyBoard.instantiateViewController(withIdentifier: "TabBarVC") as? UITabBarController
//            if let window = self.window {
//                window.rootViewController = yourVc
//            }
//            self.window?.makeKeyAndVisible()
            COMMON_FUNCTIONS.addCustomTabBar()
        }
        else
        {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
            viewController.isForReorder = true
            viewController.order_id = self.order_id
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    @objc func popVC(_ sender: UIBarButtonItem)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Order Action Api
    
    func orderActionAPI(loader:Bool) {
        let params = ["order_status":order_action]
        
        let api_name = APINAME().ORDERS_API + "/\(order_id)/"
        WebService.requestPUTUrlWithJSONDictionaryParameters(strURL: api_name , is_loader_required: loader, params: params, success: { (response) in
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
             
            
            if response["status_code"] as! NSNumber == 1
            {
                if self.isFromCheckOut
                {
                    productCartArray.removeAllObjects()
//                    let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
//                    self.window = UIWindow(frame: UIScreen.main.bounds)
//                    let yourVc = storyBoard.instantiateViewController(withIdentifier: "TabBarVC") as? UITabBarController
//                    if let window = self.window {
//                        window.rootViewController = yourVc
//                    }
//                    self.window?.makeKeyAndVisible()
                    COMMON_FUNCTIONS.addCustomTabBar()
                }
                else
                {
                self.navigationController?.popViewController(animated: true)
                }
            }
            
        }) { (failure) in
            self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
    }
    
    /////////////////////////////////////////////
    
    
    //MARK: - HeaderView For Section
    
    func getHeaderView(title: String) -> UIView {
        
        
        
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 56))
        let backV = UIView(frame: CGRect(x: 0, y: 12, width: self.view.frame.size.width, height: 56))
        
        headerView.backgroundColor = UIColor.groupTableViewBackground
        backV.backgroundColor = UIColor.white
        let infoLabel:UILabel = UILabel(frame: CGRect(x: 25, y: 20, width: self.view.frame.size.width - 50, height: 24))
   
        infoLabel.text = title
        //infoLabel.alpha = 0.80
        
        infoLabel.font = UIFont(name: ITALIC_SEMIBOLD, size: 17)
         backV.addSubview(infoLabel)
         headerView.addSubview(backV)
        
        return headerView
        
    }
 
}

//extension OrderSummaryVC : PayPalPaymentDelegate
//{
//    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
//        // COMMON_ALERT.showAlert(msg: "PayPal Payment Cancelled")
//        paymentViewController.dismiss(animated: true, completion: nil)
//        return
//    }
//
//    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
//        paymentViewController.dismiss(animated: true, completion: nil)
//        print(completedPayment)
//        print("\nConfirmation \((completedPayment.confirmation["response"] as! NSDictionary))")
//        print("Transaction Id = \(((completedPayment.confirmation["response"] as! NSDictionary)["id"] as! String))")
//        updatePaymentAPI(transaction_id: ((completedPayment.confirmation["response"] as! Dictionary<String, Any>)["id"] as! String))
//    }
//
//
//    //MARK: Update Amount API
//
//    func updatePaymentAPI(transaction_id:String) {
//
//        let api_name = APINAME().PENDING_PAYMENT + "?timezone=\(localTimeZoneName)"
//        let param:[String:Any] = ["id":(extraPaymentDict["data"] as! NSDictionary)["id"]!,"payment_gateway":selected_payment_gateway,"transaction_id":transaction_id,"amount":(extraPaymentDict["data"] as! NSDictionary)["amount"]!]
//
//        print(param)
//        WebService.requestPUTUrlWithJSONDictionaryParameters(strURL: api_name, is_loader_required: true, params: param, success: { (response) in
//            print(response)
//            if !self.serverErrorView.isHidden
//            {
//                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
//            }
//
//            if response["status_code"] as! NSNumber == 1
//            {
//                self.allDataArray.removeAllObjects()
//                self.CallApi(loader: true)
//            }
//            else
//            {
//                COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
//                return
//            }
//
//        }) { (error) in
//            COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: false, option: .transitionCurlDown)
//        }
//
//    }
//
//}






