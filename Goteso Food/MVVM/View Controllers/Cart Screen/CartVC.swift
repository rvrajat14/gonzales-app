//
//  CartVC.swift
//  FoodApplication
//
//  Created by Kishore on 30/05/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialBottomSheet
import SwiftyJSON
import NotificationCenter
import CRRefresh
import Shimmer

let LABEL_HORIZONTAL_MARGIN = 15

class CartVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var proceedToCheckoutLbl: UILabel!
    
    @IBOutlet weak var noDataFoundDescLbl: UILabel!
    @IBOutlet weak var noDataFounLbl: UILabel!
    @IBOutlet weak var pageTitleLbl: UILabel!
    
    @IBOutlet weak var okayButton: UIButton!
    
    @IBOutlet weak var serverErrorView: UIView!
    @IBOutlet weak var storeNameLbl: UILabel!
    @IBAction func okayButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func backButton(_ sender: UIButton) {
   
    self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var emptyBasketV: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    var isShimmerOn = true
    
    var shimmerView:FBShimmeringView!
    @IBOutlet weak var proceedView: UIView!
    var itemsDataArray = NSMutableArray.init()
    var isForReorder = false
    var order_id = "",total_price = "", sub_total = ""
    
    var isForApplyCoupon = true, isForLoyaltyPoints = false
    var isLoyaltyPointApplied = false, isCouponCodeApplied = false
    
    var isApplyCouponViewHide = true
    var paymentDataDic = NSMutableDictionary.init()
    var isProductCartArrayContainsReorderData = false
    
    @IBOutlet weak var totalPriceLbl: UILabel!
    var user_data:UserDataClass!
    var paymentSummaryDataDic = NSMutableDictionary.init()
    
    //MARK: Proceed To Check Out Page
    
    @IBAction func proceedButton(_ sender: UIButton) {
        if UserDefaults.standard.object(forKey: "user_data") != nil {
            isProductCartArrayContainsReorderData = false
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CheckOutVC") as! CheckOutVC
            viewController.total_amount = total_price
            viewController.sub_total = self.sub_total
            viewController.paymentSummaryDataDic = paymentSummaryDataDic
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else
        {
            let alert = UIAlertController(title: "Login Required", message: "You have to login first to continue", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { (action) in
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! UINavigationController
                
                isFromAppdelegate = false
                self.present(viewController, animated: true, completion: nil)
                
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
                self.tabBarController?.selectedIndex = 0
            }))
            
            let popPresenter = alert.popoverPresentationController
            popPresenter?.sourceView = self.view
            popPresenter?.sourceRect = self.view.bounds
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    
    
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageTitleLbl.text = "z_cart".getLocalizedValue()
        okayButton.setTitle("z_okay".getLocalizedValue(), for: .normal)
        noDataFounLbl.text = "e_cart_title".getLocalizedValue()
        noDataFoundDescLbl.text = "e_cart_desc".getLocalizedValue()
        proceedToCheckoutLbl.text = "y_cart_proceed".getLocalizedValue()
        if Language.isRTL {
            totalPriceLbl.textAlignment = .left
        }
        else
        {
            totalPriceLbl.textAlignment = .right
        }
        
        self.serverErrorView.isHidden = true
        storeNameLbl.text = store_name
        okayButton.layer.borderWidth = 1
        okayButton.layer.borderColor = MAIN_COLOR.cgColor
        okayButton.layer.cornerRadius = 2
        loyaltyPoints = "0"
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
         
        NotificationCenter.default.addObserver(self, selector: #selector(viewWillAppear(_:)), name: NSNotification.Name("login_update_notitfication"), object: nil)
        addRefreshFunctionality()
        //getLocalJSON()
        NotificationCenter.default.addObserver(self, selector: #selector(EditInstructionNotificationAction(notification:)), name: NSNotification.Name?.init(NSNotification.Name.init("EditInstructionNotification")), object: nil)
        if productCartArray.count > 0 {
             self.getPaymentSummaryData(loader: false, loyalty_points: "0")
        }
     
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        if productCartArray.count == 0 {
            self.emptyBasketV.isHidden = false
        }
        else
        {
            self.emptyBasketV.isHidden = true
        }
        
        self.navigationItem.title = "CART"
        self.navigationController?.isNavigationBarHidden = true
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
////TableView Methods///////
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if isShimmerOn
        {
            return  1
        }
        else
        {
            if self.paymentSummaryDataDic.count > 0 {
                return 2
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if isShimmerOn
        {
            let deviceHeight = self.view.frame.size.height
            return  Int(deviceHeight / 72)
        }
        else
        {
            if (paymentSummaryDataDic.count) > 0
            {
                
                if section == 0
                {
                    return (productCartArray.count)
                }
                
                if section == 1
                {
                return (paymentSummaryDataDic.object(forKey: "data") as! NSArray).count
                }
               
            }
        return 0
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isShimmerOn {
            let nib1 = UINib(nibName: "OfferShimmerTableCell", bundle: nil)
           
            tableView.register(nib1, forCellReuseIdentifier: "OfferShimmerTableCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier:"OfferShimmerTableCell") as! OfferShimmerTableCell
             cell.isUserInteractionEnabled = false
            shimmerView = FBShimmeringView(frame: cell.frame)
            shimmerView.contentView = cell
            shimmerView.isShimmering = true
            return cell
        }
       
      else if self.paymentSummaryDataDic.count > 0
         {
            if let sm = shimmerView
            {
               sm.isShimmering = false
            }
            
            
        if indexPath.section == 0 {
            
                
            let itemModel = productCartArray[indexPath.row] as! ItemModel
                
                
                let nib1 = UINib(nibName: "CartItemTableViewCell", bundle: nil)
                
                tableView.register(nib1, forCellReuseIdentifier: "CartItemTableViewCell")
                let cell  = tableView.dequeueReusableCell(withIdentifier: "CartItemTableViewCell") as! CartItemTableViewCell
            
                cell.totalQuantityLbl.text = itemModel.quantity
                cell.itemImageV.isUserInteractionEnabled = false
                cell.itemImageV.tag = indexPath.row
                if itemModel.unit.isEmpty
                {
                    cell.unitLbl.text = "\(currency_type) \(itemModel.item_price_single) / unit"
            }
            else
                {
                    cell.unitLbl.text = "\(currency_type) \(itemModel.item_price_single) / \(itemModel.unit)"
            }
            DispatchQueue.main.async {
                 cell.setLabelHeight(string: itemModel.title)
            }
           
                let imageUrl = URL(string: IMAGE_BASE_URL + "item/" + itemModel.thumb_photo)
                cell.itemImageV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "empty_item"), options: .refreshCached, completed: nil)
                cell.itemNameLbl.text = itemModel.title
            
                  cell.setInstructionsButton.isHidden = true
            
                cell.setInstructionsButton.tag = indexPath.row
                cell.setInstructionsButton.addTarget(self, action: #selector(setInstructionsButton(sender:)), for: .touchUpInside)
                cell.itemPriceLbl?.text = currency_type + COMMON_FUNCTIONS.priceFormatWithCommaSeparator(price: itemModel.item_price_total )
                cell.totalQuantityLbl.text = itemModel.quantity
                cell.addButton.isHidden = true
                cell.minusButton?.tag = (cell.plusButton?.tag)!
                cell.minusButton.addTarget(self, action: #selector(minusButton(_:event:)), for:  .touchUpInside)
                cell.plusButton.addTarget(self, action: #selector(plusButton(_:event:)), for:  .touchUpInside)
                cell.selectionStyle = .none
            let servicesDataArray = itemModel.selectedVariants as! [NSDictionary]
            var servicesList = ""
            print(servicesDataArray)
            if servicesDataArray.count > 0
            {
                cell.customizedButtonHeight.constant = 30
                cell.customisedView.layer.cornerRadius = cell.customisedView.frame.size.height/2
                cell.customisedView.isHidden = false
                cell.customizedButton.isHidden = false
                cell.customizedButton.tag = indexPath.row
                cell.customizedButton.addTarget(self, action: #selector(customizedButton(sender:)), for: .touchUpInside)
                for value in servicesDataArray
                {
                    if !servicesList.isEmpty
                    {
                      servicesList += ", "
                    }
                    
                    let item_variant_value_title = (value.object(forKey: "item_variant_value_title") as! String)
                   
                    servicesList += item_variant_value_title
                }
            }
            else
            {
                cell.customizedButtonHeight.constant = 0
                cell.customizedButton.isHidden = true
                cell.customisedView.isHidden = true
            }
            
          // cell.itemHeightConstraint.constant = cell.itemNameLbl.optimalHeight
            
                return cell
            }
        else if indexPath.section == 1
  
        {
            let dataDic = ((paymentSummaryDataDic.object(forKey: "data") as! NSArray).object(at: indexPath.row) as! NSDictionary)
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
            
            let nib1 = UINib(nibName: "PaymentSummaryTableCell", bundle: nil)
            tableView.register(nib1, forCellReuseIdentifier: "PaymentSummaryTableCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentSummaryTableCell") as! PaymentSummaryTableCell
            
            if (paymentSummaryDataDic.count) > 0
            {
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
                
            }
            
            // cell.totalPriceLbl?.text = String(format: "%.2f", total_price )
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            }
        }
      return UITableViewCell.init()
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.section == 1 {
            return 33
        }
        
         return UITableViewAutomaticDimension
        

    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
            return 50
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 80
        }
         return 10
    }
    
 
    @objc func tapGestureRecognization(_ sender: UITapGestureRecognizer?){
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if paymentSummaryDataDic.count > 0 {
            
            
            let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
            headerView.backgroundColor = UIColor.white
            let infoLabel:UILabel = UILabel(frame: CGRect(x: 25, y: 18, width: self.view.frame.size.width - 32, height: 24))
            
            infoLabel.font = UIFont(name: ITALIC, size: 17)
            if section == 1 {
                    infoLabel.text = "z_payment_summary".getLocalizedValue()
                    infoLabel.font = UIFont(name: ITALIC_SEMIBOLD, size: 17)
                    infoLabel.textColor = .black
            }
            else
            {
                if productCartArray.count == 1
                {
                     infoLabel.text = "\(productCartArray.count)  " + "z_item".getLocalizedValue()
                }
                else
                {
                    infoLabel.text = "\(productCartArray.count)  " + "z_items".getLocalizedValue()
                }
               
                 infoLabel.textColor = UIColor.lightGray
            }
            
            //infoLabel.alpha = 0.80
            
           
            headerView.addSubview(infoLabel)
            return headerView
        }
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
          
            if paymentSummaryDataDic.count > 0
            {
                
                return COMMON_FUNCTIONS.getFooterView(title: "z_grand_total".getLocalizedValue(), price: total_price, view: self.view, payment_mode: "", isFooterImageRequired: true)
            }
                
//               total_price = (paymentSummaryDataDic.object(forKey: "total") as! String)
//            let titleLbl:UILabel = UILabel(frame: CGRect(x: 25, y: 10, width: 120, height: 21))
//            titleLbl.textColor = UIColor.black
//            titleLbl.text = "Grand Total"
//            //infoLabel.alpha = 0.80
//            titleLbl.font = UIFont(name: ITALIC_SEMIBOLD, size: 17)
//
//            footerView.addSubview(titleLbl)
//
//            let totalPriceLbl:UILabel = UILabel(frame: CGRect(x: 145, y: titleLbl.frame.origin.y, width: self.view.frame.size.width - 170, height: 21))
//            totalPriceLbl.textColor = UIColor.black
//            totalPriceLbl.textAlignment = .right
//             totalPriceLbl.text = currency_type + COMMON_FUNCTIONS.getCorrectPriceFormat(price: total_price)
//            //infoLabel.alpha = 0.80
//
//            totalPriceLbl.font = UIFont(name: ITALIC_SEMIBOLD, size: 17)
//            footerView.addSubview(totalPriceLbl)
//
//                let base_image = UIImageView(frame: CGRect(x: 0, y: totalPriceLbl.frame.origin.y + totalPriceLbl.frame.size.height + 25, width: self.view.frame.size.width, height: 30))
//                base_image.image = #imageLiteral(resourceName: "base")
//                footerView.addSubview(base_image)
//            }
//            return footerView
        }
        return nil
    }
/////End Table View Methods
    
    
    //MARK: - Selector Methods/////////////////////

    
    @objc func EditInstructionNotificationAction(notification: Notification)
    {
        if let userInfo = notification.userInfo  {
            if let dataDic = userInfo["itemDataDic"] as? NSMutableDictionary, let selectedIndex = userInfo["selectedIndex"] as? Int
            {
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "EditInstructionVC") as! EditInstructionVC
                viewController.selectedIndex = selectedIndex
                viewController.itemDataDic = dataDic
                self.present(viewController, animated: true, completion: nil)
            }
            else if let msg = userInfo["msg"] as? String
            {
                if msg == "a_cart_variants".getLocalizedValue()
                {
                    getPaymentSummaryData(loader: true, loyalty_points: "")
                }
                
                self.view.makeToast(msg)
                self.view.clearToastQueue()
            }
        }
        
        self.tableView.reloadData()
    
    }
    
    @objc func setInstructionsButton(sender:UIButton)
    {
        let subDataDictionary = productCartArray.object(at: sender.tag) as! NSDictionary
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LaundryItemInstructionDetailsVC") as! LaundryItemInstructionDetailsVC
        viewController.selectedIndex = sender.tag
        viewController.itemDataDic = subDataDictionary.mutableCopy() as! NSMutableDictionary
        self.present(viewController, animated: true, completion: nil)
      
        
    }
    
    @objc func popVC(_ sender: UIBarButtonItem)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
   
    @objc func plusButton(_ sender: UIButton?,event: AnyObject?) {
        
        let touches: Set<UITouch>
        touches = (event?.allTouches!)!
        let touch:UITouch = (touches.first)!
        let touchPosition:CGPoint = touch.location(in: self.tableView)
        let indexPath:NSIndexPath = self.tableView.indexPathForRow(at: touchPosition)! as NSIndexPath
        var count = Int((productCartArray[indexPath.row] as! ItemModel).quantity)!
        count += 1
        let tmpItemModel = (productCartArray[indexPath.row] as! ItemModel)
        tmpItemModel.quantity = String(count)
        productCartArray.replaceObject(at: indexPath.row, with: tmpItemModel)
        print("Product Cart Array = \(productCartArray)")
        let cell = self.tableView.cellForRow(at: indexPath as IndexPath) as! CartItemTableViewCell
        cell.totalQuantityLbl.text = String(count)
        self.getPaymentSummaryData(loader: true, loyalty_points: "0")
    }
    
    @objc func customizedButton(sender: UIButton)
    {
        let itemDataModel = productCartArray[sender.tag] as! ItemModel
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "EditVariantsVC") as! EditVariantsVC
        viewController.selectedIndex = sender.tag
        viewController.itemDataModel = itemDataModel
        self.present(viewController, animated: true, completion: nil)
    }
    
    @objc func minusButton(_ sender: UIButton?,event: AnyObject?) {
        
        let touches: Set<UITouch>
        touches = (event?.allTouches!)!
        let touch:UITouch = (touches.first)!
        let touchPosition:CGPoint = touch.location(in: self.tableView)
        let indexPath:NSIndexPath = self.tableView.indexPathForRow(at: touchPosition)! as NSIndexPath
        var count = Int((productCartArray[indexPath.row] as! ItemModel).quantity)!
        let cell = self.tableView.cellForRow(at: indexPath as IndexPath) as! CartItemTableViewCell
        cell.totalQuantityLbl.text = String(count)
        if (productCartArray.count) > 0
        {
            count -= 1
                if count < 1
                {
                    productCartArray.removeObject(at: indexPath.row)
                    cell.addButton.isHidden = false
                    self.tableView.reloadData()
                }
                else
                {
                    let tmpItemModel = (productCartArray.object(at: indexPath.row) as! ItemModel)
                    tmpItemModel.quantity = String(count)
                    productCartArray.replaceObject(at: indexPath.row, with: tmpItemModel)
                    print("Product Cart Array = \(productCartArray)")
                    cell.totalQuantityLbl.text = String(count)
                }
            }
         
        else
        {
            cell.addButton.isHidden = false
        }
        if productCartArray.count == 0 {
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.getPaymentSummaryData(loader: true, loyalty_points: "0")
        
    }
    
  
    
    func addRefreshFunctionality()  {
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            self?.getPaymentSummaryData(loader:false,loyalty_points: "0")
        }
        
    }
  
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true
        if isProductCartArrayContainsReorderData {
            if (productCartArray.count) > 0
            {
                productCartArray.removeAllObjects()
            }
        }
    }
    
    
    //MARK: Get Services
    
    //MARK: Local Json
   /* func getLocalJSON()  {
        if let path = Bundle.main.path(forResource: "OrderCalculationLocalJSON", ofType: "json")
        {
            do
            {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String,AnyObject>
                {
                   
                    self.tableView.isScrollEnabled = true
                    self.proceedView.isHidden = false
                    
                    self.isShimmerOn = false
                    
                    self.paymentSummaryDataDic =  (((jsonResult as NSDictionary)["data"] as! NSArray).mutableCopy() as! NSMutableArray)
                    self.itemsDataArray = (paymentSummaryDataDic.object(forKey: "items") as! NSArray).mutableCopy() as! NSMutableArray
                    //productCartArray = self.itemsDataArray
                  
                    //print(self.paymentSummaryArray)
                    DispatchQueue.main.async {
                        let total_price = (self.paymentSummaryDataDic.object(forKey: "total") as! NSNumber).stringValue
                        
                        self.totalPriceLbl.text = currency_type + COMMON_FUNCTIONS.getCorrectPriceFormat(price: total_price)
                        self.tableView.reloadData()
                        self.tableView.cr.endHeaderRefresh()
                    }
                }
                
            }
            catch
            {
                
            }
        }
        
    }
    
    */
    
    //MARK: -Get Payment Summary Data From API
   
    func getPaymentSummaryData(loader:Bool,loyalty_points:String) {
        var api_name = ""
       
        var param:[String:Any]!
       
        if isForReorder {
          api_name = APINAME().ORDERS_API + "/get-reorder-data/\(order_id)?timezone=\(localTimeZoneName)"
            productCartArray.removeAllObjects()
        }else
        {
            api_name = APINAME().CART_SUMMARY_API + "?timezone=\(localTimeZoneName)"
        }
       
            param = ["items": COMMON_FUNCTIONS.getItemJSONFromItemModel(), "coupon_code":"", "store_id":store_id,"points":"","order_meta":NSDictionary.init()] as [String:Any]
        
        print(param)
        
        ///For Reorder
        
        if isForReorder {
       
         WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: loader, success: { (response) in
             print(response)
           
            if !self.serverErrorView.isHidden
            {
                 COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
           
            
             
            
            if response["status_code"] as! NSNumber == 1
            {
                 self.tableView.isScrollEnabled = true
                self.proceedView.isHidden = false
                
               self.isShimmerOn = false
               // self.paymentDataDic = response.mutableCopy() as! NSMutableDictionary
                self.paymentSummaryDataDic = ((response["data"] as! NSDictionary)["payment"] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                let dataArray = ((response["data"] as! NSDictionary)["items"] as! NSArray).mutableCopy() as! NSMutableArray
                
                self.itemsDataArray.removeAllObjects()
                for  subCategoryItems in (dataArray as! [NSDictionary])
                {
                    
                    for (index,cartItem) in (productCartArray as! [ItemModel]).enumerated()
                    {
                        if COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_id"] as AnyObject).1 == cartItem.id
                        {
                             cartItem.quantity = COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["quantity"] as AnyObject).1
                            cartItem.price = COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_price"] as AnyObject).1
                            cartItem.item_price_total = COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_price_total"] as AnyObject).1
                            cartItem.item_price_single = COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_price_single"] as AnyObject).1
                            cartItem.discount = COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_discount"] as AnyObject).1
                        }
                        productCartArray.replaceObject(at: index, with: cartItem)
                    }
                  
                }
                
               //  productCartArray = self.itemsDataArray
                
                
                print("Payment Data Dic  \(response)")
              
                for value in (self.paymentSummaryDataDic.object(forKey: "data") as! NSArray) as! [NSDictionary]
                {
                    if value["title"] as! String == "Sub Total"
                    {
                        self.sub_total = (value["value"] as! String)
                    }
                }
                
                DispatchQueue.main.async {
                   self.total_price = COMMON_FUNCTIONS.checkForNull(string: self.paymentSummaryDataDic["total"]  as AnyObject).1
                    
                    self.totalPriceLbl.text = currency_type + COMMON_FUNCTIONS.getCorrectPriceFormat(price: self.total_price)
                    self.isProductCartArrayContainsReorderData = true
                    self.isForReorder = false
                    self.tableView.reloadData()
                    self.tableView.cr.endHeaderRefresh()
                }
            }
            else
            {

                 COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
                if self.shimmerView.isShimmering
                {
                    self.shimmerView.isShimmering = false
                    self.isShimmerOn = false
                    self.tableView.reloadData()
                }
               // self.tableView.isScrollEnabled = false
                self.tableView.cr.endHeaderRefresh()
            }
            
        }) { (error) in
            if self.shimmerView.isShimmering
            {
                self.shimmerView.isShimmering = false
                self.isShimmerOn = false
                self.tableView.reloadData()
            }
             self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
         //   self.tableView.isScrollEnabled = false
            self.tableView.cr.endHeaderRefresh()
            self.proceedView.isHidden = true
           
        }
        
          }
        else
        {
        ///Normal API With Parameters
      
        WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name , is_loader_required: loader, params: param, success: { (response) in
            print(response)
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            if response["status_code"] as! NSNumber == 1
            {
                self.proceedButton.backgroundColor = MAIN_COLOR
                self.proceedButton.isEnabled = true
                self.tableView.isScrollEnabled = true
                self.proceedView.isHidden = false
                self.isShimmerOn = false
                self.paymentSummaryDataDic = ((response["data"] as! NSDictionary)["payment"] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                let dataArray = ((response["data"] as! NSDictionary)["items"] as! NSArray).mutableCopy() as! NSMutableArray
                
                 self.itemsDataArray.removeAllObjects()
                for  subCategoryItems in (dataArray as! [NSDictionary])
                {
                    let itemModel = ItemModel(id: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_id"] as AnyObject).1, title: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_title"] as AnyObject).1, thumb_photo: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["thumb_photo"] as AnyObject).1, photo: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["photo"] as AnyObject).1, discount: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_discount"] as AnyObject).1, store_id: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["store_id"] as AnyObject).1, item_description: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_description"] as AnyObject).1, quantity: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["quantity"] as AnyObject).1, price: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_price"] as AnyObject).1, item_price_single: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_price_single"] as AnyObject).1, item_price_total: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_price_total"] as AnyObject).1, unit: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["unit"] as AnyObject).1, active_status: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_active_status"] as AnyObject).1, item_stock_count: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_stock_count"] as AnyObject).1, variants: (subCategoryItems["actual_variants"] as! NSArray).mutableCopy() as! NSMutableArray, selectedVariants: (subCategoryItems["variants"] as! NSArray).mutableCopy() as! NSMutableArray)
                    self.itemsDataArray.add(itemModel)
                    
                }
                
                productCartArray = self.itemsDataArray
                print("Payment Data Dic  \(response)")
                for value in (self.paymentSummaryDataDic.object(forKey: "data") as! NSArray) as! [NSDictionary]
                {
                    if value["title"] as! String == "Sub Total"
                    {
                        self.sub_total = (value["value"] as! String)
                    }
                }
                DispatchQueue.main.async {
                     self.total_price = COMMON_FUNCTIONS.checkForNull(string: ((response["data"] as! NSDictionary)["payment"] as! NSDictionary)["total"] as AnyObject).1
                    
                    self.totalPriceLbl.text = currency_type + COMMON_FUNCTIONS.getCorrectPriceFormat(price: self.total_price)
                    self.tableView.reloadData()
                    self.tableView.cr.endHeaderRefresh()
                }
            }
            else
            {
                self.proceedButton.backgroundColor = .lightGray
                self.proceedButton.isEnabled = false
                 self.proceedView.isHidden = false
                 COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
                
                self.paymentSummaryDataDic = ((response["data"] as! NSDictionary)["payment"] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                let dataArray = ((response["data"] as! NSDictionary)["items"] as! NSArray).mutableCopy() as! NSMutableArray
                
                self.itemsDataArray.removeAllObjects()
                for  subCategoryItems in (dataArray as! [NSDictionary])
                {
                    let itemModel = ItemModel(id: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_id"] as AnyObject).1, title: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_title"] as AnyObject).1, thumb_photo: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["thumb_photo"] as AnyObject).1, photo: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["photo"] as AnyObject).1, discount: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_discount"] as AnyObject).1, store_id: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["store_id"] as AnyObject).1, item_description: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_description"] as AnyObject).1, quantity: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["quantity"] as AnyObject).1, price: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_price"] as AnyObject).1, item_price_single: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_price_single"] as AnyObject).1, item_price_total: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_price_total"] as AnyObject).1, unit: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["unit"] as AnyObject).1, active_status: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_active_status"] as AnyObject).1, item_stock_count: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_stock_count"] as AnyObject).1, variants: (subCategoryItems["actual_variants"] as! NSArray).mutableCopy() as! NSMutableArray, selectedVariants: (subCategoryItems["variants"] as! NSArray).mutableCopy() as! NSMutableArray)
                    self.itemsDataArray.add(itemModel)
                    
                }
                
                productCartArray = self.itemsDataArray
                print("Payment Data Dic  \(response)")
                for value in (self.paymentSummaryDataDic.object(forKey: "data") as! NSArray) as! [NSDictionary]
                {
                    if value["title"] as! String == "Sub Total"
                    {
                        self.sub_total = (value["value"] as! String)
                    }
                }
                DispatchQueue.main.async {
                    self.total_price = COMMON_FUNCTIONS.checkForNull(string: ((response["data"] as! NSDictionary)["payment"] as! NSDictionary)["total"] as AnyObject).1
                    
                    self.totalPriceLbl.text = currency_type + COMMON_FUNCTIONS.getCorrectPriceFormat(price: self.total_price)
                    self.tableView.reloadData()
                    self.tableView.cr.endHeaderRefresh()
                }
                
                if self.shimmerView.isShimmering
                {
                    self.shimmerView.isShimmering = false
                    self.isShimmerOn = false
                    //self.tableView.reloadData()
                }
              //  self.tableView.isScrollEnabled = false
               // self.tableView.cr.endHeaderRefresh()
            }
       
        }) { (error) in
            
            
            if self.shimmerView.isShimmering
            {
                self.shimmerView.isShimmering = false
                self.isShimmerOn = false
                self.tableView.reloadData()
            }
           // self.tableView.isScrollEnabled = false
            self.tableView.cr.endHeaderRefresh()
            self.proceedView.isHidden = true
             self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
          
        }
        }
    }

   
    
}





