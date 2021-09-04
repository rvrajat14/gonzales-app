//
//  PaymentVC.swift
//  My MM
//
//  Created by Kishore on 24/10/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import NotificationCenter
import MaterialComponents.MaterialBottomSheet
//import PaymentSDK
import Alamofire
import SVProgressHUD
import SwiftyJSON
 

class PaymentVC: UIViewController {
    
    
    @IBOutlet weak var pageTitleLbl: UILabel!
   
    let commonPaymentHandlerSharedInstance = CommonPaymentHandler.paymentHandlerSharedInstance
    
    var storeDic = NSDictionary.init()
    var paymentSummaryDic = NSDictionary.init()
    var paymentOptionsArray = NSMutableArray.init()
    var params = NSDictionary.init()
    var totalPrice = "", sub_total = ""
    var payment_gateway_type = "", payment_mode = "", payment_transaction_id = ""
    var TokenDic = NSDictionary.init()
    var Token = ""
    var couponSuccessMsg = "",couponFailMsg = ""
    var oldPaymentSummaryDic = NSDictionary.init()
    var pointsStr = "", pointsAppliedStr = ""
    var points = ""
    var isPointsApplied = false
    var isPointsDisplayed = false
    var order_number = ""
    
    
    @IBOutlet weak var serverErrorView: UIView!
    var isForCOD = true
    var isForCard = false
    var isCouponApplied = false
    
    var payamentSummaryIsHidden = true
    var user_id = ""
    
    var couponAvailable = ""
    var walletAvailable = ""
    
    @IBAction func proceedButton(_ sender: UIButton) {
        
        if payment_gateway_type.isEmpty {
            COMMON_FUNCTIONS.showAlert(msg: "y_payment_method".getLocalizedValue())
            return
        }
       
        if payment_gateway_type == "paypal"
        {
//            commonPaymentHandlerSharedInstance.pushPaypalPaymentVC()
        }
        else if payment_gateway_type == "stripe"
        {
            commonPaymentHandlerSharedInstance.pushStripeVCForPayment()
            
        }
        else if payment_gateway_type == "razorpay"
        {
            commonPaymentHandlerSharedInstance.pushRazorpayPaymentVC()
        }
        else if payment_gateway_type == "paytm"
        {
//            commonPaymentHandlerSharedInstance.pushPaytmPaymentVC()
        }
        else if payment_gateway_type == "paygate"
        {
            if self.TokenDic.count > 0 {
                let data = self.TokenDic.object(forKey: "data") as! NSDictionary
                if COMMON_FUNCTIONS.checkForNull(string: self.TokenDic.object(forKey: "is_web") as AnyObject).1 == "1" {
                    self.callTokenApi(token: data["token_url"] as! String)
                }
            }
        }
       
        else
        {
            placeOrderAPI(transaction_id: "")
        }
        
    }
    
    
    
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(params)
        self.couponAvailable = COMMON_FUNCTIONS.checkForNull(string: storeDic.value(forKey: "coupon_available") as AnyObject).1
        self.walletAvailable = COMMON_FUNCTIONS.checkForNull(string: storeDic.value(forKey: "wallet_available") as AnyObject).1
    
        print(self.couponAvailable)
        print(self.walletAvailable)
        self.isPointsDisplayed =  (self.walletAvailable == "1" && self.couponAvailable == "0") ? true : false
       
        couponCode = ""
        pageTitleLbl.text = "z_payment".getLocalizedValue()
        proceedButton.setTitle("y_payment_place_order".getLocalizedValue(), for: .normal)
        
        
        self.navigationController?.isNavigationBarHidden = true
        self.serverErrorView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(couponNotificationAction(notification:)), name: NSNotification.Name.init("couponNotification"), object: nil)
        
        
        
        let radioNib = UINib(nibName: "RadioButtonTableViewCell", bundle: nil)
        tableView.register(radioNib, forCellReuseIdentifier: "RadioButtonTableViewCell")
        
        let paymentNib = UINib(nibName: "PaymentSummaryTableCell", bundle: nil)
        tableView.register(paymentNib, forCellReuseIdentifier: "PaymentSummaryTableCell")
        self.oldPaymentSummaryDic = paymentSummaryDic
        if self.oldPaymentSummaryDic.count > 0 {
            totalPrice = COMMON_FUNCTIONS.checkForNull(string: self.oldPaymentSummaryDic["total"] as AnyObject).1
        }
        
         commonPaymentHandlerSharedInstance.paytmBasicRequirement = (user_id:user_id,orderId:String(Int.random(in: 1..<1000)),amount:totalPrice,currentlyVC:self)
        commonPaymentHandlerSharedInstance.paymentBasicRequirement = (user_id:user_id, amount: totalPrice , currency: "",currentlyVC:self)
        commonPaymentHandlerSharedInstance.commonPaymentHandlerDelegate = self
        commonPaymentHandlerSharedInstance.patymProtocolDelegate = self
        getPaymentGateways()
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
        getPoints()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Points API
    func getPoints()  {
        let api_name = APINAME().POINTS_API
        
        WebService.requestGetUrl(strURL: api_name + "?user_id=\(user_id)&amount=\(sub_total)&store_id=\(params["store_id"] as! String)", params: NSDictionary.init(), is_loader_required: false, success: { (response) in
            print(response)
           
            if response["status_code"] as! NSNumber == 1
            {
                self.points = COMMON_FUNCTIONS.checkForNull(string: (response["data"] as! NSDictionary)["points"] as AnyObject).1
                self.pointsStr = COMMON_FUNCTIONS.checkForNull(string: (response["data"] as! NSDictionary)["message"] as AnyObject).1
                self.tableView.reloadData()
            }
            else
            {
                self.view.makeToast((response["message"] as! String))
                self.view.clearToastQueue()
            }
        }) { (failure) in
            
        }
    }

    //MARK: Apply Coupon API
    func applyPointsAPI(loader:Bool,isForPoints: Bool)  {
        let api_name = APINAME().COUPON_API + "?timezone=\(localTimeZoneName)"
        var param:[String:Any]!
        let paramMutabaledic = params.mutableCopy() as! NSMutableDictionary
        if isForPoints {
            paramMutabaledic.setObject(points, forKey: "points" as NSCopying)
            paramMutabaledic.setObject("", forKey: "coupon_code" as NSCopying)
        }
        else
        {
            paramMutabaledic.setObject("", forKey: "points" as NSCopying)
            paramMutabaledic.setObject(couponCode, forKey: "coupon_code" as NSCopying)
        }
        
        
        param = (paramMutabaledic as! [String : Any])
        
        WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name , is_loader_required: loader, params: param, success: { (response) in
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
            if response["status_code"] as! NSNumber == 1
            {
                if isForPoints
                {
                    
                    self.pointsAppliedStr = (response["text"] as! String)
                    self.isPointsApplied = true
                }
                else
                {
                    self.isCouponApplied = true
                }
                self.paymentSummaryDic = (response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                self.totalPrice = ( self.paymentSummaryDic["total"] as! String)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                self.view.makeToast((response["message"] as! String))
                self.view.clearToastQueue()
                
            }
            else
            {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                self.view.makeToast((response["message"] as! String))
            }
            
        }) { (error) in
            
            self.tableView.cr.endHeaderRefresh()
            COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: false, option: .transitionCurlDown)
            
        }
    }
    
    
    
    //MARK: Get Payment Gateways
    func getPaymentGateways()  {
        
        let api_name = APINAME().GET_PAYMENT_GATEWAYS
        
        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: true, success: { (response) in
            print(response)
            
            
            
            if response["status_code"] as! NSNumber == 1
            {
                let tmpData = (response["data"] as! NSArray).mutableCopy() as! NSMutableArray
                
                for value in tmpData as! [NSDictionary]
                {
                    let dataDic = value.mutableCopy() as! NSMutableDictionary
                    
                    dataDic.setObject("0", forKey: "isSelected" as NSCopying)
                    
                    self.paymentOptionsArray.add(dataDic)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            
            
        }) { (failure) in
            
        }
        
        
    }
    
    //MARK: -Call Token Api
    
    func callTokenApi(token:String) {
        let params = ["amount":(paymentSummaryDic["total"] as! String)] as NSDictionary
        let headers = [
                      "class_identifier": app_type,
                      "timezone":localTimeZoneName,
                      //"Content-Type": "application/json",
                      "Accept": "application/json",
                      "Authorization": "\(token_type) \(access_token)"
                      
                  ]
        Alamofire.request(URL.init(string: token)!, method: .post, parameters: params as? Parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            print(response.result)

            switch response.result {

            case .success(_):
                if let json = response.value
                {
                   let response = (json as! [String:AnyObject])
                    
                     if response["status_code"] as! NSNumber == 1 {
        
                    self.Token = COMMON_FUNCTIONS.checkForNull(string: (response["data"] as! NSDictionary)["token"] as AnyObject).1
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaygateVC") as! PaygateVC
                        vc.webViewResponseDelegate = self
                        print(response)
                    vc.dataDictionary = response["data"] as! NSDictionary
                    self.present(vc, animated: true, completion: nil)
                    }
                    else {
                    COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
                    return
                }
                    
                }
                break
            case .failure(let error):
                print(error)
                break
            }
        }
     
    }
    
    
    //MARK: -Selector Methods
    
    
    @objc func  couponMainButton(_ sender: UIButton)
    {
        isPointsDisplayed = false
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! ApplyCouponTableCell
        cell.pointsMainButton.setTitleColor(UIColor.lightGray, for: .normal)
        cell.pointsBottomLbl.isHidden = true
        cell.couponMainBackV.isHidden = false
        cell.pointBackV.isHidden = true
        cell.couponMainButton.setTitleColor(MAIN_COLOR, for: .normal)
        cell.couponBottomLbl.isHidden = false
        self.tableView.reloadData()
        
    }
    
    
    @objc func  pointsMainButton(_ sender: UIButton)
    {
        isPointsDisplayed = true
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! ApplyCouponTableCell
        cell.couponMainButton.setTitleColor(UIColor.lightGray, for: .normal)
        cell.couponBottomLbl.isHidden = true
        cell.pointBackV.isHidden = false
        cell.couponMainBackV.isHidden = true
        cell.pointsLbl.text = pointsStr
        if points == "0" || points == "" {
            cell.pointsButton.isHidden = true
        }
        else
        {
            cell.pointsButton.isHidden = false
        }
        // getPoints()
        cell.pointsButton.layer.borderColor = MAIN_COLOR.cgColor
        cell.pointsMainButton.setTitleColor(MAIN_COLOR, for: .normal)
        cell.pointsBottomLbl.isHidden = false
        self.tableView.reloadData()
        
    }
    
    @objc func  pointsButton(_ sender: UIButton)
    {
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! ApplyCouponTableCell
        
        if cell.pointsCrossButton.isHidden {
            cell.pointsButton.isHidden = true
            cell.pointsCrossButton.isHidden = false
            isPointsApplied = true
            applyPointsAPI(loader: true, isForPoints: true)
        }
        else
        {
            
            self.paymentSummaryDic = oldPaymentSummaryDic
            totalPrice = (self.oldPaymentSummaryDic["total"] as! String)
            cell.pointsButton.setTitle("z_use".getLocalizedValue(), for: .normal)
            cell.pointsButton.layer.borderColor = MAIN_COLOR.cgColor
            cell.pointsButton.isHidden = false
            cell.pointsCrossButton.isHidden = true
            cell.pointsButton.setTitleColor(.white, for: .normal)
            cell.pointsMainButton.isUserInteractionEnabled = true
            cell.couponMainButton.isUserInteractionEnabled = true
            self.isPointsApplied = false
            self.isCouponApplied = false
            self.tableView.reloadData()
            
        }
        
        
    }
    
    
    @objc func   pointsCrossButton(_ sender: UIButton)
    {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! ApplyCouponTableCell
        cell.pointsButton.isHidden = false
        cell.pointsCrossButton.isHidden = true
        self.isCouponApplied = false
        self.isPointsApplied = false
        cell.pointsMainButton.isUserInteractionEnabled = true
        cell.couponMainButton.isUserInteractionEnabled = true
        couponCode = ""
        totalPrice = (self.oldPaymentSummaryDic["total"] as! String)
        self.paymentSummaryDic = self.oldPaymentSummaryDic
        self.tableView.reloadData()
        
    }
    
    @objc func  couponCrossButton(_ sender: UIButton)
    {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! ApplyCouponTableCell
        couponCode = ""
        totalPrice = (self.oldPaymentSummaryDic["total"] as! String)
        self.paymentSummaryDic = self.oldPaymentSummaryDic
        cell.couponButton.setTitle("y_payment_couponlist".getLocalizedValue(), for: .normal)
        cell.couponButton.isHidden = false
        cell.couponCrossButton.isHidden = true
        cell.pointsMainButton.isUserInteractionEnabled = true
        cell.couponMainButton.isUserInteractionEnabled = true
        self.isCouponApplied = false
        self.isPointsApplied = false
        self.tableView.reloadData()
        
    }
    
    @objc func  couponButton(_ sender: UIButton)
    {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! ApplyCouponTableCell
        
        if cell.couponButton.currentTitle == "y_payment_couponlist".getLocalizedValue() {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PromoCodesVC") as! PromoCodesVC
            viewController.params =  params
            
            self.present(viewController, animated: true, completion: nil)
            
        }
        else
        {
            applyPointsAPI(loader: true, isForPoints: false)
        }
        
        //For Remove code
        
        
        
    }
    
    
    
    
    @objc func detailsButton(sender:UIButton)
    {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! PaymentSummaryTableCell
        if cell.downImgV.image == #imageLiteral(resourceName: "down_button") {
            self.payamentSummaryIsHidden = false
            cell.downImgV.image = #imageLiteral(resourceName: "up_blue_button")
        }
        else
        {
            self.payamentSummaryIsHidden = true
            cell.downImgV.image = #imageLiteral(resourceName: "down_button")
        }
        self.tableView.reloadData()
    }
    
    @objc func couponNotificationAction(notification : Notification)
    {
        if let userInfo = notification.userInfo {
            if let ccd = userInfo["coupon_code"] as? String {
                print(ccd)
                couponCode = ccd
            }
            if let paymentData = userInfo["payment_data"] as? NSDictionary {
                print(paymentData)
                totalPrice = (paymentData["total"] as! String)
                self.paymentSummaryDic = paymentData
                
            }
            if let responseMsg = userInfo["responseMsg"] as? String
            {
                self.view.makeToast(responseMsg, duration: 2, position: .bottom, title: "", image: nil, style: .init(), completion: nil)
            }
            self.isCouponApplied = true
            self.tableView.reloadData()
        }
        
    }
    
    @objc func checkboxButton(sender:UIButton, event:AnyObject)
    {
        let touches: Set<UITouch>
        touches = (event.allTouches!)!
        let touch:UITouch = (touches.first)!
        let touchPosition:CGPoint = touch.location(in: self.tableView)
        let indexPath:NSIndexPath = self.tableView.indexPathForRow(at: touchPosition)! as NSIndexPath
        let dataDic = paymentOptionsArray[indexPath.row] as! NSDictionary
        
        setSelectedRow(identifier: (dataDic.object(forKey: "identifier") as! String) )
        
        let fieldOptionsDic = (paymentOptionsArray.object(at: indexPath.row) as! NSDictionary)
        let identifier = fieldOptionsDic["identifier"] as! String
        if identifier == "card"
        {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DebitCreditCardVC") as! DebitCreditCardVC
            self.navigationController?.pushViewController(viewController, animated: true)
            return
            
        }
        if fieldOptionsDic.object(forKey: "isSelected") as! String == "1" {
            payment_mode = (fieldOptionsDic["type"] as! String)
            payment_gateway_type = (fieldOptionsDic["identifier"] as! String)
            sender.setImage(#imageLiteral(resourceName: "round-checked"), for: .normal)
            self.tableView.reloadData()
        }
        
    }
    
   
    
    func setSelectedRow(identifier: String)  {
        
        let tmpArray = paymentOptionsArray
        
        for (index,value) in tmpArray.enumerated() {
            let dataDic = (value as! NSDictionary).mutableCopy() as! NSMutableDictionary
            
            if dataDic["identifier"] as! String == identifier
            {
                if identifier == "cash"
                {
                    isForCard = false
                    isForCOD = true
                    
                }
                else
                {
                    isForCard = true
                    isForCOD = false
                    
                }
                
                dataDic.setObject("1", forKey: "isSelected" as NSCopying)
            }
            else
            {
                dataDic.setObject("0", forKey: "isSelected" as NSCopying)
            }
            paymentOptionsArray.replaceObject(at: index, with: dataDic)
        }
        
    }
    
}


extension PaymentVC : UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.walletAvailable == "0" && self.couponAvailable == "0") ? 2 : 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if  (self.walletAvailable == "0" && self.couponAvailable == "0") ? section == 1 : section == 2 {
            
            if paymentSummaryDic.count > 0
            {
                return (paymentSummaryDic.object(forKey: "data") as! NSArray).count
            }
            else
            {
                return 0
            }
            
            
        }
        
        
        else if section == 1 && (self.walletAvailable != "0" || self.couponAvailable != "0") {
            return 1
        }
        
        else
        {
            return 1
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (self.walletAvailable == "0" && self.couponAvailable == "0") ? indexPath.section == 1 : indexPath.section == 2 {
            
            
            let dataDic = (paymentSummaryDic.object(forKey: "data") as! NSArray).object(at: indexPath.row) as! NSDictionary
            let title = COMMON_FUNCTIONS.checkForNull(string: dataDic["title"] as AnyObject).1
            let value =  COMMON_FUNCTIONS.checkForNull(string: dataDic["value"] as AnyObject).1
            if title == "line"
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
            
            cell.titleLbl.text = title
            cell.valueLbl.text = currency_type + COMMON_FUNCTIONS.priceFormatWithCommaSeparator(price: value)
            
            if (tableView.numberOfRows(inSection: indexPath.section) - 1) == indexPath.row
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
        else if indexPath.section == 1 && (self.walletAvailable != "0" || self.couponAvailable != "0")
        {
            let nib1 = UINib(nibName: "ApplyCouponTableCell", bundle: nil)
            tableView.register(nib1, forCellReuseIdentifier: "ApplyCouponTableCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "ApplyCouponTableCell") as! ApplyCouponTableCell
            //cell.offersListButton.layer.borderWidth = 1
            //cell.offersListButton.layer.borderColor = MAIN_COLOR.cgColor
            cell.couponCrossButton.addTarget(self, action: #selector(couponCrossButton(_:)), for: .touchUpInside)
            cell.pointsCrossButton.addTarget(self, action: #selector( pointsCrossButton(_:)), for: .touchUpInside)
            cell.couponButton.addTarget(self, action: #selector(couponButton(_:)), for: .touchUpInside)
            cell.pointsButton.layer.borderWidth = 1
            cell.couponCodeTxtField.delegate = self
            if !isPointsDisplayed
            {
                cell.pointBackV.isHidden = true
                if couponCode.isEmpty
                {
                    cell.couponButton.setTitle("y_payment_couponlist".getLocalizedValue(), for: .normal)
                }
                else
                {
                    cell.couponButton.setTitle("z_apply".getLocalizedValue(), for: .normal)
                }
                cell.couponCodeTxtField.text = couponCode
                if self.isCouponApplied
                {
                    self.isPointsApplied = false
                    cell.pointsMainButton.isUserInteractionEnabled = false
                    cell.couponCrossButton.isHidden = false
                    cell.couponButton.isHidden = true
                    // cell.offersListButton.isHidden = true
                    cell.couponCodeTxtField.text = couponCode
                }
                else
                {
                    cell.couponButton.isHidden = false
                    cell.couponCrossButton.isHidden = true
                    cell.pointsMainButton.isUserInteractionEnabled = true
                    // cell.offersListButton.isHidden = false
                }
            }
            else
            {
                if isPointsApplied
                {
                    self.isCouponApplied = false
                    cell.couponMainButton.isUserInteractionEnabled = false
                    cell.pointsLbl.text = self.pointsAppliedStr
                    cell.pointsCrossButton.isHidden = false
                    
                    cell.pointsButton.isHidden = true
                    
                }
                else if points == "0" || points == "" {
                    cell.pointsButton.isHidden = true
                }
                else
                {
                    cell.pointsButton.isHidden = false
                    cell.pointsLbl.text = pointsStr
                    cell.pointsCrossButton.isHidden = true
                    cell.couponMainButton.isUserInteractionEnabled = true
                    
                }
                cell.pointBackV.isHidden = false
                cell.couponMainBackV.isHidden = true
                
            }
            
          
            if (couponAvailable == "1") && (walletAvailable == "0") {
                cell.couponMainBackV.isHidden = false
                cell.pointBackV.isHidden = true
                cell.pointsMainButton.isHidden = true
                cell.pointsBottomLbl.isHidden = true
                cell.couponMainButton.isHidden = false
                cell.couponBottomLbl.isHidden = false
            }

            if (couponAvailable == "0") && (walletAvailable == "1") {
                cell.couponMainBackV.isHidden = true
                cell.pointBackV.isHidden = false
                cell.pointsMainButton.isHidden = false
                cell.pointsBottomLbl.isHidden = false
                cell.couponMainButton.isHidden = true
                cell.couponBottomLbl.isHidden = true
            }

            if (couponAvailable == "1") && (walletAvailable == "1") {
//                cell.couponMainBackV.isHidden = false
//                cell.pointBackV.isHidden = false
//                cell.pointsMainButton.isHidden = false
//                cell.pointsBottomLbl.isHidden = false
//                cell.couponMainButton.isHidden = false
//                cell.couponBottomLbl.isHidden = false
                cell.pointsButtonLeadingConstraint.constant = 114
            }
            else {
//                cell.couponMainBackV.isHidden = true
//                cell.pointBackV.isHidden = true
//                cell.pointsMainButton.isHidden = true
//                cell.pointsBottomLbl.isHidden = true
//                cell.couponMainButton.isHidden = true
//                cell.couponBottomLbl.isHidden = true
                cell.pointsButtonLeadingConstraint.constant = 0
            }
            
            
            // cell.pointsButton.layer.borderColor = MAIN_COLOR.cgColor

            cell.couponMainButton.addTarget(self, action: #selector(couponMainButton(_:)), for: .touchUpInside)
            cell.pointsMainButton.addTarget(self, action: #selector(pointsMainButton(_:)), for: .touchUpInside)
            cell.pointsButton.addTarget(self, action: #selector(pointsButton(_:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
            
        }
        else
        {
            
            
            let nib:UINib = UINib(nibName: "SelectionTypeTableCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "SelectionTypeTableCell")
            
            let cell  = tableView.dequeueReusableCell(withIdentifier: "SelectionTypeTableCell", for: indexPath) as! SelectionTypeTableCell
            cell.titleLbl.text = "y_payment_method".getLocalizedValue()
            cell.collectionView.delegate = self
            cell.collectionView.dataSource = self
            cell.collectionView.tag = indexPath.section
            cell.collectionView.reloadData()
            cell.selectionStyle = .none
            return cell
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if (self.walletAvailable == "0" && self.couponAvailable == "0") ? section == 1 : section == 2 {
            
            return COMMON_FUNCTIONS.getFooterView(title: "z_grand_total".getLocalizedValue(), price: (paymentSummaryDic["total"] as! String) , view: self.view, payment_mode: "", isFooterImageRequired: false)
            
            
        }
        
        if section == 1 && (self.walletAvailable != "0" || self.couponAvailable != "0") {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
            v.backgroundColor = UIColor.groupTableViewBackground
            return v
        }
        
        let v = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1))
        v.backgroundColor = .white
        return v
        
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (self.walletAvailable == "0" && self.couponAvailable == "0") ? section == 1 : section == 2 {
            return self.getHeaderView(title: "z_payment_summary".getLocalizedValue())
        }
        
        let tmpView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1))
        tmpView.backgroundColor = UIColor.white
        return tmpView
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (self.walletAvailable == "0" && self.couponAvailable == "0") ? section == 1 : section == 2 {
            return 100
        }
        
        if section == 1 && (self.walletAvailable != "0" || self.couponAvailable != "0") {
            return 10
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (self.walletAvailable == "0" && self.couponAvailable == "0") ? section == 1 : section == 2  {
            return 44
        }
        
        return 1
    }
    
    //MARK: Hide NavigationBar
    
    func hideNavigation()  {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    //MARK: - HeaderView For Section
    
    func getHeaderView(title: String) -> UIView {
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        headerView.backgroundColor = UIColor.white
        let infoLabel:UILabel = UILabel(frame: CGRect(x: 25, y: 10, width: self.view.frame.size.width - 32, height: 24))
        infoLabel.textColor = UIColor.black
        infoLabel.text = title
        //infoLabel.alpha = 0.80
        
        infoLabel.font = UIFont(name: ITALIC_SEMIBOLD, size: 17)
        headerView.addSubview(infoLabel)
        return headerView
        
    }
    
    
    func placeOrderAPI(transaction_id:String) {
        
        
        self.proceedButton.isUserInteractionEnabled = false
        self.proceedButton.backgroundColor = UIColor.lightGray
        
        let api_name = APINAME().ORDERS_API + "?timezone=\(localTimeZoneName)"
        var param:[String:Any]!
        
        let paramMutabaledic = params.mutableCopy() as! NSMutableDictionary
        if isPointsApplied {
            paramMutabaledic.setObject("", forKey: "coupon_code" as NSCopying)
            paramMutabaledic.setObject(points, forKey: "points" as NSCopying)
        }
        else
        {
            paramMutabaledic.setObject("", forKey: "points" as NSCopying)
            paramMutabaledic.setObject(couponCode, forKey: "coupon_code" as NSCopying)
        }
        
        if paymentSummaryDic.count > 0 {
            let payment_details = ["type":payment_mode,"payment_gateway":payment_gateway_type,
                                   "payment_gateway_transaction_id":transaction_id,
                                   "payment_transaction_amount":(paymentSummaryDic["total"] as! String),"token":self.Token]
            paramMutabaledic.setObject(payment_details, forKey: "payment_details" as NSCopying)
        }
        else
        {
            let payment_details = ["type":payment_mode,"payment_gateway":payment_gateway_type,
                                   "payment_gateway_transaction_id":transaction_id,
                                   "payment_transaction_amount":"0","token":self.Token]
            paramMutabaledic.setObject(payment_details, forKey: "payment_details" as NSCopying)
        }
        
        param = (paramMutabaledic as! [String : Any])
        
        print(param)
        WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name, is_loader_required: true, params: param, success: { (response) in
            print(response)
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
            if response["status_code"] as! NSNumber == 1
            {
                
                self.order_number = ((response["data"] as! NSDictionary).object(forKey: "order_id") as! NSNumber).stringValue
                DispatchQueue.main.async {
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderPlacedVC") as! OrderPlacedVC
                    viewController.order_number = self.order_number
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            else
            {
                COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
                return
            }
            
        }) { (error) in
            COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: false, option: .transitionCurlDown)
        }
        
    }
    
}


extension PaymentVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return paymentOptionsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UINib(nibName: "SelectionCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SelectionCollectionCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectionCollectionCell", for: indexPath) as! SelectionCollectionCell
        
        let fieldOptionsDic = (paymentOptionsArray.object(at: indexPath.row) as! NSDictionary)
        DispatchQueue.main.async {
            if fieldOptionsDic.object(forKey: "isSelected") as! String == "0"
            {
                cell.backV.layer.borderColor = UIColor.lightGray.cgColor
                cell.selectionTypeLbl.textColor = UIColor.lightGray
                cell.backV.backgroundColor = .clear
                cell.imageV.isHidden = true
            }
            else
            {
                self.payment_mode = (fieldOptionsDic["type"] as! String)
                self.payment_gateway_type = (fieldOptionsDic["identifier"] as! String)
                cell.backV.backgroundColor = UIColor(red: 245/255.0, green: 248/255.0, blue: 254/255.0, alpha: 1)
                cell.selectionTypeLbl.textColor = MAIN_COLOR
                cell.backV.layer.borderColor = MAIN_COLOR.cgColor
                cell.imageV.isHidden = false
                
                if (fieldOptionsDic["identifier"] as! String) == "paygate" {
                    if COMMON_FUNCTIONS.checkForNull(string: (fieldOptionsDic["is_web"] as AnyObject)).1 == "1" {
                        self.TokenDic = fieldOptionsDic
                        print(fieldOptionsDic)
                    }
                }
                else {
                    self.TokenDic = NSDictionary.init()
                }
            }
        }
       
        cell.selectionTypeLbl.text = (fieldOptionsDic.object(forKey: "title") as! String)
        cell.backV.layer.cornerRadius = 4
        cell.backV.layer.borderWidth = 1
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! SelectionCollectionCell
        let dataDic = (paymentOptionsArray.object(at: indexPath.row) as! NSDictionary)
        setSelectedRow(identifier: (dataDic.object(forKey: "identifier") as! String))
        let fieldOptionsDic = (paymentOptionsArray.object(at: indexPath.row) as! NSDictionary)
        let identifier = fieldOptionsDic["identifier"] as! String
       
        if identifier == "card"
        {
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DebitCreditCardVC") as! DebitCreditCardVC
            self.navigationController?.pushViewController(viewController, animated: true)
            return
            
        }
        
        if identifier == "paytm"
             {
//                 commonPaymentHandlerSharedInstance.pushPaytmPaymentVC()
             }
        
//        if identifier == "paygate" {
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaygateVC") as! PaygateVC
//            self.present(vc, animated: true, completion: nil)
//        }
        
        if fieldOptionsDic.object(forKey: "isSelected") as! String == "1" {
            cell.backV.backgroundColor = UIColor(red: 245/255.0, green: 248/255.0, blue: 254/255.0, alpha: 1)
            cell.selectionTypeLbl.textColor = MAIN_COLOR
            cell.backV.layer.borderColor = MAIN_COLOR.cgColor
            if fieldOptionsDic["data"] != nil
            {
                commonPaymentHandlerSharedInstance.setPaymentMethodEnvironment(with: fieldOptionsDic)
                
                if identifier == "stripe"
                {
                    
                    commonPaymentHandlerSharedInstance.setStripeCartView()
                }
                
            }
            cell.imageV.isHidden = false
            collectionView.reloadData()
            
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        return CGSize(width: 130, height: 70)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
    }
    
}


extension PaymentVC: UITextFieldDelegate
{
    public func textFieldDidEndEditing(_ textField: UITextField)
    {
        couponCode = textField.text!
        self.tableView.reloadData()
        return
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        couponCode = newString
        return true
    }
}





extension PaymentVC : CommonPaymentHandlerProtocol
{
    func paymentFailed(errorMsg: String) {
        self.view.makeToast(errorMsg)
        self.view.clearToastQueue()
    }
    
    func paymentDone(transactionId: String) {
       placeOrderAPI(transaction_id: transactionId)
    }
    
    
}

extension PaymentVC : PaytmProtocol {
    func patymPaymentDone(transactionId: String) {
       placeOrderAPI(transaction_id: transactionId)
    }
}

extension PaymentVC : WebViewResponseDelegate {
    func response(url:String) {
        let headers = [
                             "class_identifier": app_type,
                             "timezone":localTimeZoneName,
                             //"Content-Type": "application/json",
                             "Accept": "application/json",
                             "Authorization": "\(token_type) \(access_token)"
                             
                         ]
            Alamofire.request(URL.init(string: url)!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            print(response.result)

            switch response.result {

            case .success(_):
                if let json = response.value
                {
                   let response = (json as! [String:AnyObject])
                     if response["status_code"] as! NSNumber == 1 {
                        self.placeOrderAPI(transaction_id: "")
                    }
                    else {
                    COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
                    return
                }
                    
                }
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
}


