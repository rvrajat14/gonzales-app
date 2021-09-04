//
//  CheckOutVC.swift
//  FoodApplication
//
//  Created by Kishore on 04/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import Shimmer
import NotificationCenter


class CheckOutVC: UIViewController,UITableViewDelegate,UITextViewDelegate {
    
    @IBOutlet weak var proceedForPaymentLbl: UILabel!
    
    @IBOutlet weak var pageTitleLbl: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var serverErrorView: UIView!
    @IBOutlet weak var totalPriceLbl: UILabel!
    @IBOutlet weak var storeNameLbl: UILabel!
    @IBOutlet weak var blurV: UIView!
    @IBAction func backButton(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    @IBAction func proceedButton(_ sender: UIButton) {
        if checkForRequiredValue()
        {
            return
        }
        else
        {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
            viewController.params = makeDataArray()
            viewController.user_id = user_data.user_id!
            viewController.paymentSummaryDic = paymentSummaryDataDic
            viewController.totalPrice = total_amount
            viewController.sub_total = sub_total
            viewController.storeDic = self.storeDic
            self.navigationController?.pushViewController(viewController, animated: true)
            
        }
    }
    
    @IBOutlet weak var proceedButton: UIButton!
    var vehicleDetails = ""
    var vehicleDetailsDataDic = NSMutableDictionary.init()
    var deliveryNotes = ""
    var vehicle_notes = ""
    var current_time = ""
    
     
    var delivery_type = ""
    var total_amount = "", sub_total = ""
    var shimmerView:FBShimmeringView!
    var isShimmerOn = true
    var isDeliveryTypeShowRuleSet = false
    var isOrderTypeShowRuleSet = false
     let userDefaults = UserDefaults.standard
    var allMetaDataFieldsArray = NSMutableArray.init()
    
     var user_data:UserDataClass!
    var paymentSummaryDataDic = NSMutableDictionary.init()
    var storeDic = NSDictionary.init()
    
    var allFieldsDataArray = NSMutableArray.init()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageTitleLbl.text = "z_checkout".getLocalizedValue()
        proceedForPaymentLbl.text = "y_checkout_proceed".getLocalizedValue()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MM-yyyy HH:mm"
        current_time = dateFormat.string(from: Date()) + "-00:00"
        self.serverErrorView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(addCarDetailsNotificationAction(notification:)), name: NSNotification.Name?.init(NSNotification.Name.init("addCarDetailsNotificationAction")), object: nil)
        selectedAddressDictionary = AddressModel()
        selectedPickUpAddressDictionary = AddressModel()
        selectedTimeForDelivery = ""
        selectedDeliveryDate = ""
        selectedPickupDate = "ASAP"
        selectedPickupDateForJSON = ""
        
        if Language.isRTL {
            totalPriceLbl.textAlignment = .left
        }
        
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
         totalPriceLbl.text = currency_type + total_amount
       
        let decoded  = userDefaults.object(forKey: "user_data") as! Data
          NSKeyedUnarchiver.setClass(UserDataClass.self, forClassName: "UserDataClass")
        user_data = (NSKeyedUnarchiver.unarchiveObject(with: decoded) as! UserDataClass)
        getFieldsDataAPI()
      //  getLocalJSON()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        //self.tableView.estimatedRowHeight = 50
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
        self.storeNameLbl.text = store_name
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
       self.navigationController?.isNavigationBarHidden = true
        setValuesofDataArray(isForText: false)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

}


//MARK: - TableView Methods

extension CheckOutVC: UITableViewDataSource
{
    
    @objc func ASAPButtonTapped(_ sender:UIButton) {
        selectedPickupDate = "ASAP"
        for (index,value) in allFieldsDataArray.enumerated() {
                   let dataDic = ((value as! NSDictionary).mutableCopy() as!NSMutableDictionary)
                   let input_type = dataDic.object(forKey: "input_type") as! String
                   
                   if input_type == "timeSlotsPicker"
                   {
                       if !selectedPickupDate.isEmpty{
                           
                        dataDic.setObject(selectedPickupDate, forKey: "value" as NSCopying)
                       }
                       allFieldsDataArray.replaceObject(at: index, with: dataDic)
                   }
        }
//        viewWillAppear(true)
        self.tableView.reloadData()
    }
    
    @objc func specifyOwnButtonTapped(_sender:UIButton) {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TimeSlotsVC") as! TimeSlotsVC
            //  viewController.isForAddressEditing = false
            self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        let dataDictionary = allFieldsDataArray.object(at: indexPath.section) as! NSDictionary
        let type = dataDictionary.object(forKey: "input_type") as! String
        let identifier = dataDictionary.object(forKey: "identifier") as! String
            if type == "radio"
            {
                
                let nib:UINib = UINib(nibName: "SelectionTypeTableCell", bundle: nil)
                
                tableView.register(nib, forCellReuseIdentifier: "SelectionTypeTableCell")
                
                let cell  = tableView.dequeueReusableCell(withIdentifier: "SelectionTypeTableCell", for: indexPath) as! SelectionTypeTableCell
                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                let title = dataDictionary.object(forKey: "order_setting_meta_type_title") as! String
                cell.titleLbl.text = title
                cell.collectionView.tag = indexPath.section
 
            cell.selectionStyle = .none
            return cell
            }
        else if type == "text" {
            
            let nib:UINib = UINib(nibName: "CheckoutDeliveryInstructionsTVCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "CheckoutDeliveryInstructionsTVCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckoutDeliveryInstructionsTVCell", for: indexPath) as! CheckoutDeliveryInstructionsTVCell
            cell.instructionTxtView.delegate = self
            let title = dataDictionary.object(forKey: "order_setting_meta_type_title") as! String
            let placeholder = (dataDictionary["placeholder"] as! String)
                
            cell.titleLbl.text = title
            if identifier == "vehicle_notes"
            {
                if vehicle_notes.isEmpty
                {
                cell.instructionTxtView.placeholder = placeholder
                }
                else
                {
                  cell.instructionTxtView.text = vehicle_notes
                }
                cell.instructionTxtView.tag = 1
            }
            else
            {
                if deliveryNotes.isEmpty
                {
                cell.instructionTxtView.placeholder = placeholder
                }
                else
                {
                  cell.instructionTxtView.text = deliveryNotes
                }
                 cell.instructionTxtView.tag = 2
            }
            if indexPath.section == tableView.numberOfSections - 2
            {
                cell.separatorV.isHidden = true
            }
                else
            {
                cell.separatorV.isHidden = false
            }
                
            cell.selectionStyle = .none
            return cell
        }
       else if type == "address" {
            
            let nib  = UINib(nibName: "CheckoutTextFieldTableCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "CheckoutTextFieldTableCell")
            
            let cell  = tableView.dequeueReusableCell(withIdentifier: "CheckoutTextFieldTableCell", for: indexPath) as! CheckoutTextFieldTableCell
            
             let title = dataDictionary.object(forKey: "order_setting_meta_type_title") as! String
            let placeholder = (dataDictionary["placeholder"] as! String)
            cell.titleLbl.text = title
            if (dataDictionary.object(forKey: "default_value") as! String).isEmpty
            {
               
                if identifier == "pickup_address"
                {
                    cell.infoLbl.text = placeholder
                }
                else
                {
                    cell.infoLbl.text = placeholder
                }
                
            }
            else
            {
               // cell.accessoryType = .none
         cell.infoLbl.text = (dataDictionary.object(forKey: "default_value") as! String)
            }
                
                if indexPath.section == tableView.numberOfSections - 2
                {
                    cell.separatorV.isHidden = true
                }
                else
                {
                    cell.separatorV.isHidden = false
                }
                
             cell.imagV.image = #imageLiteral(resourceName: "location_placeholder")
              cell.selectionStyle = .none
            //  cell.accessoryType = .disclosureIndicator
            return cell
        }
        
       else if type == "vehicle_popup" {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "vehicle_popup_cell")
            var cell = tableView.dequeueReusableCell(withIdentifier: "vehicle_popup_cell", for: indexPath)
            if cell.isEqual(nil)
            {
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "vehicle_popup_cell")
            }
           // cell.textLabel?.font = UIFont(name: REGULAR_FONT, size: 14)
            cell.textLabel?.numberOfLines = 0
            
            if !vehicleDetails.isEmpty
            {
                cell.textLabel?.text = vehicleDetails
            }
            else
            {
                cell.textLabel?.text = ""
            }
            // cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            return cell
        }
        
//        else if type == "timeSlotsPicker" {
//            let nib  = UINib(nibName: "CheckoutTextFieldTableCell", bundle: nil)
//            tableView.register(nib, forCellReuseIdentifier: "CheckoutTextFieldTableCell")
//            let cell  = tableView.dequeueReusableCell(withIdentifier: "CheckoutTextFieldTableCell", for: indexPath) as! CheckoutTextFieldTableCell
//            let title = dataDictionary.object(forKey: "order_setting_meta_type_title") as! String
//            let placeholder = (dataDictionary["placeholder"] as! String)
//            cell.titleLbl.text = title
//            if (dataDictionary.object(forKey: "value") as! String).isEmpty
//            {
//                cell.infoLbl.text = placeholder
//            }
//            else
//            {
//
//               cell.infoLbl.text = (dataDictionary.object(forKey: "value") as! String)
//            }
//                if indexPath.section == tableView.numberOfSections - 2
//                {
//                    cell.separatorV.isHidden = true
//                }
//                else
//                {
//                    cell.separatorV.isHidden = false
//                }
//             cell.imagV?.image = #imageLiteral(resourceName: "clock_image")
//            // cell.accessoryType = .disclosureIndicator
//              cell.selectionStyle = .none
//            return cell
//        }
        
        
            else if type == "timeSlotsPicker"  {
                let nib  = UINib(nibName: "NewTimeSlotTVCell", bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: "NewTimeSlotTVCell")
                let cell  = tableView.dequeueReusableCell(withIdentifier: "NewTimeSlotTVCell", for: indexPath) as! NewTimeSlotTVCell
                let title = dataDictionary.object(forKey: "order_setting_meta_type_title") as! String
                cell.selectTimeLbl.text = title
                if (dataDictionary.object(forKey: "value") as! String).isEmpty
                {
                    cell.ownTimeLbl.text = "Specify your own time"
                }
                 else
                {
                    
                    if (dataDictionary.object(forKey: "value") as! String) == "ASAP" {
                        cell.asapView.backgroundColor = MAIN_COLOR
                        cell.ownTimeView.backgroundColor = UIColor.white
                         cell.ownTimeLbl.text = "Specify your own time"
                    }
                    else {
                        cell.asapView.backgroundColor = UIColor.white
                        cell.ownTimeView.backgroundColor = MAIN_COLOR
                      cell.ownTimeLbl.text = (dataDictionary.object(forKey: "value") as! String)
                    }
                }
                
                cell.asapButton.addTarget(self, action: #selector(ASAPButtonTapped(_:)), for: .touchUpInside)
                cell.ownTimeSelectionButton.addTarget(self, action: #selector(specifyOwnButtonTapped(_sender:)), for: .touchUpInside)
                cell.selectionStyle = .none
                return cell
            }
       
            
            let dataDic = (paymentSummaryDataDic.object(forKey: "data") as! NSArray).object(at: indexPath.row) as! NSDictionary
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
            if title == "Sub Total" {
                sub_total = value
            }
        
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
    
    
     
    public func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.tag == 1 {
            vehicle_notes = textView.text
        }
        else
        {
            deliveryNotes = textView.text
        }
        
        self.setValuesofDataArray(isForText: true)
       
    }
    
    
    //MARK: Get Arrow Image
    
    func getImage(yPosition: CGFloat) -> UIImageView {
        
        let arrowImage = UIImageView(frame: CGRect(x: self.view.frame.size.width - 40, y: yPosition, width: 15, height: 15))
        arrowImage.image = #imageLiteral(resourceName: "forward")
        arrowImage.contentMode = .center
        return arrowImage
    }
    
    
    //MARK: - Set Values of DataArray
    func setValuesofDataArray(isForText:Bool) {
      
        for (index,value) in allFieldsDataArray.enumerated() {
            let dataDic = ((value as! NSDictionary).mutableCopy() as!NSMutableDictionary)
            let identifier = dataDic.object(forKey: "identifier") as! String
            let input_type = dataDic.object(forKey: "input_type") as! String
            
            if input_type == "timeSlotsPicker"
            {
                if !selectedPickupDate.isEmpty{
                    
                 dataDic.setObject(selectedPickupDate, forKey: "value" as NSCopying)
                }
                allFieldsDataArray.replaceObject(at: index, with: dataDic)
            }
            
//            if identifier == "delivery_time"
//            {
//                if !selectedDeliveryDate.isEmpty{
//                    dataDic.setObject(selectedDeliveryDate, forKey: "value" as NSCopying)
//                }
//                allFieldsDataArray.replaceObject(at: index, with: dataDic)
//            }
            
            
            if input_type == "vehicle_popup"
            {
                if !vehicleDetails.isEmpty{
                    dataDic.setObject(vehicleDetails, forKey: "value" as NSCopying)
                }
                allFieldsDataArray.replaceObject(at: index, with: dataDic)
            }
            
            if input_type == "text"
            {
                if identifier == "vehicle_notes"
                {
                    if !vehicle_notes.isEmpty{
                        dataDic.setObject(vehicle_notes, forKey: "value" as NSCopying)
                    }
                }
                else
                {
                    if !deliveryNotes.isEmpty{
                        dataDic.setObject(deliveryNotes, forKey: "value" as NSCopying)
                    }
                }
               
                allFieldsDataArray.replaceObject(at: index, with: dataDic)
            }
            
            if !isForText
            {
                if input_type == "address"
                {
                    var addressDataDic : AddressModel!
                    
                    if identifier == "pickup_address"
                    {
                        addressDataDic = selectedPickUpAddressDictionary
                    }
                    else
                    {
                        getPaymentSummaryData(loader: true)
                        addressDataDic = selectedAddressDictionary
                    }
                    
                    if addressDataDic.title != "" {
                        var selectedAddress = ""
                        if addressDataDic.line1.isEmpty == false
                        {
                            selectedAddress = addressDataDic.line1
                        }
                        if addressDataDic.line2.isEmpty == false
                        {
                            selectedAddress += ", " + addressDataDic.line2
                        }
                        if addressDataDic.city.isEmpty == false
                        {
                            selectedAddress += ", " + addressDataDic.city
                        }
                        
                        if addressDataDic.state.isEmpty == false
                        {
                            selectedAddress += ", " + addressDataDic.state
                        }
                        if addressDataDic.country.isEmpty == false
                        {
                            selectedAddress += ", " + addressDataDic.country
                        }
//                        if addressDataDic.pincode.isEmpty == false
//                        {
//                            selectedAddress += ", " + addressDataDic.pincode
//                        }
                        
                        if !selectedAddress.isEmpty
                        {
                            dataDic.setObject(self.getAddressJSONDictionary(identifier: identifier), forKey: "value" as NSCopying)
                            dataDic.setObject(selectedAddress, forKey: "default_value" as NSCopying)
                        }
                        
                    }
                    
                    allFieldsDataArray.replaceObject(at: index, with: dataDic)
                }
            }
            
           
        }
        print(allFieldsDataArray)
    }
    
    
    //MARK: -Selector Methods
    
    @objc func addVehicleDetailsButton(sender: UIButton)
    {
        
    }
    
    
    @objc func addCarDetailsNotificationAction(notification: Notification)
    {
         self.blurV.isHidden = true
        if notification.userInfo != nil {
            self.vehicleDetailsDataDic = NSMutableDictionary(dictionary: notification.userInfo!["vehicleDetails"] as! NSDictionary)
            self.vehicleDetails = "Registration no. : " + (vehicleDetailsDataDic["registration_number"] as! String) + "\n" + (vehicleDetailsDataDic["brand_name"] as! String)
            self.vehicleDetails += "\n" + (vehicleDetailsDataDic["model_name"] as! String) + "\n" + (vehicleDetailsDataDic["body_type"] as! String)
            self.vehicleDetails += "\n" + (vehicleDetailsDataDic["Transmission"] as! String) + "\n" + (vehicleDetailsDataDic["Fuel_type"] as! String)
             self.tableView.reloadData()
        }
       
    }
    
    //MARK: Set Selected Row
    
    func setSelectedRow(section: Int, row: Int) {
        let selectedIndex = row
        let mainDic = (self.allFieldsDataArray.object(at: section) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        let tempFieldsValuesArray = ((mainDic.object(forKey: "field_options") as! NSArray).mutableCopy() as! NSMutableArray)
        
        
        for (index,value) in tempFieldsValuesArray.enumerated()
        {
            let subDic = (value as! NSDictionary).mutableCopy() as! NSMutableDictionary
            
            if selectedIndex == index
            {
                subDic.setObject("1", forKey: "isSelected" as NSCopying)
                tempFieldsValuesArray.replaceObject(at: index, with: subDic)
                let identifier = (mainDic.object(forKey: "identifier") as! String)
                let input_type = (mainDic.object(forKey: "input_type") as! String)
                
                let value = subDic.object(forKey: "value") as! String
                let title = subDic.object(forKey: "title") as! String
                
                if input_type == "radio"
                {
                    let display_show_rule = identifier + "=" + value
                    checkShowRuleValue(display_show_rule: display_show_rule, identifier: identifier)
                }
                mainDic.setObject(title, forKey: "display_value" as NSCopying)
                mainDic.setObject(value, forKey: "value" as NSCopying)
            }
            else
            {
                subDic.setObject("0", forKey: "isSelected" as NSCopying)
                tempFieldsValuesArray.replaceObject(at: index, with: subDic)
            }
        }
        mainDic.setObject(tempFieldsValuesArray, forKey: "field_options" as NSCopying)
        self.allFieldsDataArray.replaceObject(at: section, with: mainDic)
        self.tableView.reloadData()
    }
    
    //MARK: Check For Parent Identifier Value
    
    func checkForParentIdentifierValue(parent_identifier:String) -> Bool {
        for mainValue in  self.allFieldsDataArray
        {
            let dataDic = (mainValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
            let identifier = dataDic.object(forKey: "identifier") as! String
            if identifier != "paymentSummary"
            {
            let value = dataDic.object(forKey: "value") as! String
                
                if parent_identifier == identifier
                {
                    if  value.isEmpty
                    {
                        return true
                      
                    }
                    else
                    {
                        return false
                       
                    }
                    
                }
            }
            
            
        }
         return false
    }
    
    
    //MARK: Check For  Show Rule
    func checkShowRuleValue(display_show_rule:String,identifier:String)  {
        
        for (index,mainValue) in  self.allFieldsDataArray.enumerated()
        {
            let dataDic = (mainValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
            let parent_identifier = dataDic.object(forKey: "parent_identifier") as! String
            let displayShowRule = dataDic.object(forKey: "display_show_rule") as! String
           
            
            if parent_identifier == identifier
                {
                    let show_bool = dataDic.object(forKey: "show_bool") as! NSNumber
                    if displayShowRule == display_show_rule
                        {
                            if show_bool == 0
                                    {
                                        dataDic.setObject(1, forKey: "show_bool" as NSCopying)
                                        self.allFieldsDataArray.replaceObject(at: index, with: dataDic)
                                        if parent_identifier == "delivery_type"
                                        {
                                            self.setValuesofDataArray(isForText: false)
                                           // self.getPaymentSummaryData(loader: false, delivery_type: "home_delivery")
                                        }
                                        
                                    }
                            }
                    else
                        {
                                        dataDic.setObject(0, forKey: "show_bool" as NSCopying)
                                        dataDic.setObject("", forKey: "value" as NSCopying)
                                        dataDic.setObject("", forKey: "default_value" as NSCopying)
                                        self.allFieldsDataArray.replaceObject(at: index, with: dataDic)
                                        print(self.allFieldsDataArray)
                                        if parent_identifier == "delivery_type"
                                        {
                                         selectedAddressDictionary = AddressModel()
                                            getPaymentSummaryData(loader: true)
                                        }
                                         selectedPickupDate = ""
                            
                        }
                }
        }
        
    }
    
   
    func numberOfSections(in tableView: UITableView) -> Int {
        if allFieldsDataArray.count > 0 {
            return allFieldsDataArray.count
        }
         return 0
        
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
         if allFieldsDataArray.count > 0
         {
            let dataDic = (self.allFieldsDataArray.object(at: section) as! NSDictionary)
            let identifier = dataDic.object(forKey: "identifier") as! String
            let display_show_rule = dataDic.object(forKey: "display_show_rule") as! String
            let show_bool =  dataDic.object(forKey: "show_bool") as! NSNumber
          
            if let input_type = dataDic.object(forKey: "input_type") as? String
            {
                if input_type == "radio"
                {
                return 1
                }
            }
            
            if identifier == "paymentSummary" && display_show_rule.isEmpty
            {
                return ((allFieldsDataArray.object(at: section) as! NSDictionary).object(forKey: "data") as! NSArray).count
            }
            
            if display_show_rule.isEmpty
            {
                return 1
            }
            
            if !display_show_rule.isEmpty && show_bool == 1 {
                    return 1
                }
            else if !display_show_rule.isEmpty && show_bool == 0 {
                    return 0
                }
            
             return 0
        }
        
        
        else
         {
            return 0
        }
    }
    
   
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let dataDic = (self.allFieldsDataArray.object(at: section) as! NSDictionary)
        let identifier = dataDic.object(forKey: "identifier") as! String
        
        if identifier == "paymentSummary" {
           
             return 44
        }
       
    return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
        if UIDevice.current.userInterfaceIdiom == .pad {
            if allFieldsDataArray.count > 0 {
                let dataDictionary = allFieldsDataArray.object(at: indexPath.section) as! NSDictionary
                let type = dataDictionary.object(forKey: "input_type") as! String
                
                if type == "text"
                {
                    return 130
                }
                else if type == "paymentSummary"
                {
                    return UITableViewAutomaticDimension
                }
                else if type == "radio"
                {
                    return 110
                }
                else
                {
                    return 100
                }
            }
        }
        
        return UITableViewAutomaticDimension
       
    }
    
    //MARK: Make Address JSON Dictionary
    
    func getAddressJSONDictionary(identifier:String) -> String {
        var addressModel : AddressModel!
        
        if identifier == "pickup_address" {
            addressModel = selectedPickUpAddressDictionary
        }
        else
        {
           addressModel = selectedAddressDictionary
        }
            if (addressModel.title) != "" {
                
                let dataDic1 = NSDictionary(dictionaryLiteral: ("address_id", addressModel.id),("address_line1", addressModel.line1),("address_line2", addressModel.line2),("city", addressModel.city),("state", addressModel.state),("country", addressModel.country),("pincode", ""),("latitude", addressModel.latitude),("longitude", addressModel.longitude),("created_at", " "),("address_title", addressModel.title),("address_phone", addressModel.phone))
                
                let jsonData = try? JSONSerialization.data(withJSONObject: dataDic1, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)
                print(jsonString!)
                return jsonString!
            }
       
        return ""
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let dataDic = (self.allFieldsDataArray.object(at: section) as! NSDictionary)
        let display_show_rule = dataDic.object(forKey: "display_show_rule") as! String
        let identifier = dataDic.object(forKey: "identifier") as! String

        if section == tableView.numberOfSections - 2 {
            return 10
        }
        
        if display_show_rule.isEmpty {
            if identifier == "paymentSummary" {
                return 100
            }
        }
        

       return 2
    }
    
   
    
    //MARK: - Set Section Header View ////////
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if  allFieldsDataArray.count > 0 {
            let dataDic = (self.allFieldsDataArray.object(at: section) as! NSDictionary)
            let title = dataDic.object(forKey: "order_setting_meta_type_title") as! String
            let identifier = dataDic.object(forKey: "identifier") as! String
            if identifier == "paymentSummary" {
              return self.getHeaderView(title: title, isForButton: false)
            }
        }
        let v = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 2))
        v.backgroundColor = .white
        return v
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let identifier = (self.allFieldsDataArray.object(at: section) as! NSDictionary).object(forKey: "identifier") as! String
        if identifier == "paymentSummary" {
            
                if paymentSummaryDataDic.count > 0
                {
                    let total_price = (paymentSummaryDataDic.object(forKey: "total") as! String)
                     return COMMON_FUNCTIONS.getFooterView(title: "z_grand_total".getLocalizedValue(), price: total_price, view: self.view, payment_mode: "", isFooterImageRequired: false)
                 
                }
            
        }
        if section == tableView.numberOfSections - 2 {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
            v.backgroundColor = UIColor.groupTableViewBackground
            return v
        }
       
        let v = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 2))
        v.backgroundColor = .white
        return v
        
    }
    
    
    
    //MARK: -Get Payment Summary Data From API
    
    func getPaymentSummaryData(loader:Bool) {
        let api_name = APINAME().PLACE_ORDER_CALCULATE + "?timezone=\(localTimeZoneName)"
        
        let param = (makeDataArray() as! [String : Any])
       
        
        print(param)
        
            WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name , is_loader_required: loader, params: param, success: { (response) in
                print(response)
                if !self.serverErrorView.isHidden
                {
                    COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
                }
                
                
                if response["status_code"] as! NSNumber == 1
                {
                    self.bottomView.backgroundColor  = MAIN_COLOR
                    self.proceedButton.isUserInteractionEnabled = true
                    self.paymentSummaryDataDic = ((response["data"] as! NSDictionary)["payment"] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    self.storeDic = (response["data"] as! NSDictionary)["store"] as! NSDictionary
                    for value in (self.paymentSummaryDataDic.object(forKey: "data") as! NSArray) as! [NSDictionary]
                    {
                        if value["title"] as! String == "Sub Total"
                        {
                            self.sub_total = (value["value"] as! String)
                        }
                    }
                    DispatchQueue.main.async {
                        self.total_amount = (((response["data"] as! NSDictionary)["payment"] as! NSDictionary).object(forKey: "total") as! String)
                        self.totalPriceLbl.text = currency_type +  self.total_amount
                        self.paymentSummaryDataDic.setObject("Payment Summary", forKey: "order_setting_meta_type_title" as NSCopying)
                        self.paymentSummaryDataDic.setObject("paymentSummary", forKey: "identifier" as NSCopying)
                        self.paymentSummaryDataDic.setObject("paymentSummary", forKey: "input_type" as NSCopying)
                        self.paymentSummaryDataDic.setObject("", forKey: "display_show_rule" as NSCopying)
                        self.paymentSummaryDataDic.setObject("", forKey: "parent_identifier" as NSCopying)
                        self.paymentSummaryDataDic.setObject(1, forKey: "show_bool" as NSCopying)
                        if self.allFieldsDataArray.count > 0
                        {
                            self.allFieldsDataArray.replaceObject(at: self.allFieldsDataArray.count - 1, with: self.paymentSummaryDataDic)
                        }
                        self.tableView.reloadData()
                        self.tableView.cr.endHeaderRefresh()
                    }
                }
                else
                {
                    COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
                    self.bottomView.backgroundColor  = .lightGray
                    self.proceedButton.isUserInteractionEnabled = false
                        self.tableView.reloadData()
                    //  self.tableView.isScrollEnabled = false
                    self.tableView.cr.endHeaderRefresh()
                }
                
            }) { (error) in
               
                // self.tableView.isScrollEnabled = false
                self.tableView.cr.endHeaderRefresh()
                 self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
                
        }
    }

    
    ///////////////////////////////////
    
    
    // MARK: - Selection Of Item For Radio Cell///////////
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dataDic = (self.allFieldsDataArray.object(at: indexPath.section) as! NSDictionary)
        let identifier = dataDic.object(forKey: "identifier") as! String
        let input_type = dataDic.object(forKey: "input_type") as! String
   
            if input_type == "address" {
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DeliveryAddressVC") as! DeliveryAddressVC
                if identifier == "pickup_address"
                {
                   viewController.isForDeliveryAddress = false
                }
                else
                {
                   viewController.isForDeliveryAddress = true
                }
                viewController.isFromCheckOut = true
                    self.navigationController?.pushViewController(viewController, animated: true)
            }
//            if input_type == "timeSlotsPicker" {
//                 let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TimeSlotsVC") as! TimeSlotsVC
//                //  viewController.isForAddressEditing = false
//                self.navigationController?.pushViewController(viewController, animated: true)
//            }
        
    }
    
  
/////////////////////
    
 
    //MARK: - Check For Required Value
    
    func checkForRequiredValue() ->Bool {
        
        for (index,dataDic1) in self.allFieldsDataArray.enumerated() {
            
            let dataDic = ((dataDic1 as! NSDictionary).mutableCopy() as! NSMutableDictionary)
            let identifier = dataDic.object(forKey: "identifier") as! String
            
            if identifier != "paymentSummary"
            {
                let value = dataDic.object(forKey: "value") as! String
                let required_or_not = dataDic.object(forKey: "required_or_not") as! String
               let order_setting_meta_type_title = dataDic.object(forKey: "order_setting_meta_type_title") as! String
                let show_bool = dataDic.object(forKey: "show_bool") as! NSNumber
 
            if show_bool == 1
            {
                if required_or_not == "1"
                {
                        if value.isEmpty
                        {
                            if identifier == "notes"
                            {
                                
                             displayAlert(msg: "z_enter".getLocalizedValue() + "  \n\(order_setting_meta_type_title)")
                            }
                            else
                            {
                            displayAlert(msg: "\(order_setting_meta_type_title)\n  " + "y_checkout_required".getLocalizedValue())
                            }
                        return true
                        }
                  
                }
                
            }
                else
            {
                dataDic.setObject("", forKey: "value" as NSCopying)
                self.allFieldsDataArray.replaceObject(at: index, with: dataDic)
                }
            }
           
        }
        return false
    }
    
    
    //MARK: -Display Alert View
    func displayAlert(msg:String) {
        let alert = UIAlertController(title: "", message: msg, preferredStyle: .alert)
       
        alert.addAction(UIAlertAction(title: "z_ok".getLocalizedValue(), style: .default, handler: { (action) in
            return
        }))
        let popOverController = alert.popoverPresentationController
        popOverController?.sourceView = self.view
        popOverController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        popOverController?.permittedArrowDirections = []
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    //MARK: -Make Data Array for JSON
    
    func makeDataArray() -> NSDictionary {
        
       // let orderType = ((productCartArray.object(at: 0) as! NSDictionary).object(forKey: "type") as! String)
                for (mainIndex,dicValue) in allMetaDataFieldsArray.enumerated()
                {
                    let dicValue1 = (dicValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
            let (isContain,dictionaryValue) = isContainDic(dictionary: dicValue1)
                    if isContain
                    {
                        print(dictionaryValue)
                        allMetaDataFieldsArray.replaceObject(at: mainIndex, with: dictionaryValue)
                    }
                    else
                    {
                    if dicValue1.object(forKey: "identifier") as! String == "customer_id"
                    {
                        dicValue1.setObject(user_data.user_id!, forKey: "value" as NSCopying)
                        
                        allMetaDataFieldsArray.replaceObject(at: mainIndex, with: dicValue1)
                    }
                    }
            }
         
        print(allMetaDataFieldsArray)
        
        let param = ["items": COMMON_FUNCTIONS.getItemJSONFromItemModel(), "customer_id":user_data.user_id!,"type":"","points": "", "coupon_code":"", "store_id": store_id.isEmpty ? (productCartArray[0] as! ItemModel).store_id : store_id ,"order_meta":NSDictionary(dictionaryLiteral: ("fields",allMetaDataFieldsArray))] as NSDictionary
        print(param)
        return param
    }
    
    
    func isContainDic(dictionary: NSDictionary) -> (isContain:Bool,dic:NSMutableDictionary) {
        for (index,value) in allFieldsDataArray.enumerated() {
            let dataDic = value as! NSMutableDictionary
            if dataDic.object(forKey: "identifier") as! String == dictionary.object(forKey: "identifier") as! String
            {
                _  = dataDic.object(forKey: "parent_identifier") as! String
        
                 if dataDic.object(forKey: "input_type") as! String == "address"
                 {
                    
                    return (true,self.makeAddressJSON(dic: dataDic.mutableCopy() as! NSMutableDictionary, index: index))
                }
                return (true,dataDic)
            }
        }
        return (false,NSMutableDictionary.init())
    }
    
    @objc func popVC(_ sender: UIBarButtonItem)
    {
        self.navigationController?.popViewController(animated: true)
    }
/////////////////////////////////////////////
    
   
    func makeAddressJSON(dic:NSMutableDictionary,index:Int) -> NSMutableDictionary  {
         let identifier = dic.object(forKey: "identifier") as! String
        _ = dic.object(forKey: "show_bool") as! NSNumber
        var default_address = ""
        
       if let defaultAddress = dic["value"] as? String
       {
        default_address = defaultAddress
        }
        if identifier == "delivery_address"
        {
            if selectedAddressDictionary.title == ""
            {
                dic.setObject(default_address, forKey: "value" as NSCopying)
            }
            else
            {
                dic.setObject(getAddressJSONDictionary(identifier:"delivery_address"), forKey: "value" as NSCopying)
            }
        }
        if identifier == "pickup_address"
        {
            dic.setObject(getAddressJSONDictionary(identifier: "pickup_address"), forKey: "value" as NSCopying)
        }
        return dic
       
    }
    
  //MARK: - HeaderView For Section
    
    func getHeaderView(title: String,isForButton:Bool) -> UIView {
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        headerView.backgroundColor = UIColor.white
        let infoLabel:UILabel = UILabel(frame: CGRect(x: 25, y: 18, width: self.view.frame.size.width - 32, height: 20))
        infoLabel.textColor = UIColor(red: 149/255.0, green: 149/255.0, blue: 149/255.0, alpha: 1)
        
        infoLabel.font = UIFont(name: "OpenSansLight-Italic", size: 16)
        infoLabel.text = title
        //infoLabel.alpha = 0.80
        
        
      
            infoLabel.font = UIFont(name: ITALIC_SEMIBOLD, size: 17)
            infoLabel.textColor = .black
     
        headerView.addSubview(infoLabel)
         
        
        return headerView
        
    }
    
   
    func removeAllSubViewOfCells(cell: UITableViewCell) {
        
        let views:NSArray = cell.contentView.subviews as NSArray
       
        
        for (index,view)  in views.enumerated(){
            
            let _:UIView = views.object(at: index) as! UIView
            (view as AnyObject).removeFromSuperview()
            print(index)
            
        }
    }
    
    //MARK: Local Json
    func getLocalJSON()  {
        if let path = Bundle.main.path(forResource: "OrderFormLocalJSON", ofType: "json")
        {
            do
            {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String,AnyObject>
                {
                   var count = 1
                    self.allMetaDataFieldsArray = ((jsonResult as NSDictionary)["fields"]  as! NSArray).mutableCopy() as! NSMutableArray
                    
                        for subValue in self.allMetaDataFieldsArray
                        {
                            let dataDic = (subValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
                            
                            let identifier = dataDic.object(forKey: "identifier") as! String
                            
                            let input_type = dataDic.object(forKey: "input_type") as! String
                            
                            if identifier == "customer_id"
                            {
                                continue
                            }
                            
                            if input_type == "radio"
                            {
                                let fieldsArray = (dataDic.object(forKey: "field_options") as! NSArray).mutableCopy() as! NSMutableArray
                                
                                for (index,value) in fieldsArray.enumerated()
                                {
                                    let value1 = (value as! NSDictionary).mutableCopy() as! NSMutableDictionary
                                    value1.setObject(count, forKey: "field_id" as NSCopying)
                                    value1.setObject("0", forKey: "isSelected" as NSCopying)
                                    fieldsArray.replaceObject(at: index, with: value1)
                                    count = count + 1
                                }
                                dataDic.setObject(fieldsArray, forKey: "field_options" as NSCopying)
                                
                            }
                            
                            self.allFieldsDataArray.add(dataDic)
                            
                        }
                        
                  
                    self.paymentSummaryDataDic.setObject("Payment Summary", forKey: "order_setting_meta_type_title" as NSCopying)
                    self.paymentSummaryDataDic.setObject("paymentSummary", forKey: "identifier" as NSCopying)
                    self.paymentSummaryDataDic.setObject("", forKey: "display_show_rule" as NSCopying)
                    self.paymentSummaryDataDic.setObject("", forKey: "parent_identifier" as NSCopying)
                    self.paymentSummaryDataDic.setObject(1, forKey: "show_bool" as NSCopying)
                    self.allFieldsDataArray.add(self.paymentSummaryDataDic)
                    self.tableView.reloadData()
                    print(self.allFieldsDataArray)
                }
                
            }
            catch
            {
                
            }
        }
        
    }
    
    
    //MARK: -Get Form Fields Data From API
    func getFieldsDataAPI()   {
        var count = 1
        let api_name = APINAME().GET_ORDER_FORM + "?user_id=\(user_data.user_id!)&timezone=\(localTimeZoneName)"
        
        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: true, success: { (response) in
          print(response)
            var show_bool = ""
            
          if !self.serverErrorView.isHidden
          {
            COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
             
             if response["status_code"] as! NSNumber == 1
             {
            
             self.allMetaDataFieldsArray = (response["data"]  as! NSArray).mutableCopy() as! NSMutableArray
            
            for subValue in self.allMetaDataFieldsArray
            {
                let dataDic = (subValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
                
                let identifier = dataDic.object(forKey: "identifier") as! String
               
                let input_type = dataDic.object(forKey: "input_type") as! String
                
                if identifier == "delivery_address"
                {
                    show_bool = ((dataDic.object(forKey: "show_bool") as! NSNumber).stringValue)
                }
                
                if identifier == "customer_id"
                {
                    continue
                }
                
                if input_type == "radio"
                {
                    let fieldsArray = (dataDic.object(forKey: "field_options") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    for (index,value) in fieldsArray.enumerated()
                    {
                        let value1 = (value as! NSDictionary).mutableCopy() as! NSMutableDictionary
                        value1.setObject(count, forKey: "field_id" as NSCopying)
                        value1.setObject("0", forKey: "isSelected" as NSCopying)
                        fieldsArray.replaceObject(at: index, with: value1)
                        count = count + 1
                    }
                    dataDic.setObject(fieldsArray, forKey: "field_options" as NSCopying)
                    
                }
                
               
                
                self.allFieldsDataArray.add(dataDic)
                
            }
            
            if self.allFieldsDataArray.count > 0
            {
                if self.paymentSummaryDataDic["data"] == nil
                {
                    self.paymentSummaryDataDic.setObject(NSArray.init(), forKey: "data" as NSCopying)
                    self.paymentSummaryDataDic.setObject("0", forKey: "total" as NSCopying)
                }
                self.paymentSummaryDataDic.setObject("z_payment_summary".getLocalizedValue(), forKey: "order_setting_meta_type_title" as NSCopying)
                self.paymentSummaryDataDic.setObject("paymentSummary", forKey: "identifier" as NSCopying)
                self.paymentSummaryDataDic.setObject("paymentSummary", forKey: "input_type" as NSCopying)
                self.paymentSummaryDataDic.setObject("", forKey: "display_show_rule" as NSCopying)
                self.paymentSummaryDataDic.setObject("", forKey: "parent_identifier" as NSCopying)
                self.paymentSummaryDataDic.setObject(1, forKey: "show_bool" as NSCopying)
                self.allFieldsDataArray.add(self.paymentSummaryDataDic)
            }
            
           
            if show_bool == "1"
            {
                self.getPaymentSummaryData(loader: true)
            }
            else
            {
                 self.tableView.reloadData()
            }
            }
            else
             {
                self.view.makeToast((response["message"] as! String))
            }
            
            self.setValuesofDataArray(isForText: false)
            print(self.allFieldsDataArray)
            
        }) { (failure) in
            self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
        
        
    }
    }


extension CheckOutVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
         let dataDictionary = allFieldsDataArray.object(at: collectionView.tag) as! NSDictionary
        return (dataDictionary.object(forKey: "field_options") as! NSArray).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UINib(nibName: "SelectionCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SelectionCollectionCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectionCollectionCell", for: indexPath) as! SelectionCollectionCell
         let dataDictionary = allFieldsDataArray.object(at: collectionView.tag) as! NSDictionary
        let fieldOptionsDic = ((dataDictionary.object(forKey: "field_options") as! NSArray)[indexPath.row] as! NSDictionary)
        
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
                cell.backV.backgroundColor = UIColor(red: 245/255.0, green: 248/255.0, blue: 254/255.0, alpha: 1)
                cell.selectionTypeLbl.textColor = MAIN_COLOR
                cell.backV.layer.borderColor = MAIN_COLOR.cgColor
                cell.imageV.isHidden = false
            }
        }
        
       
        cell.selectionTypeLbl.text = (fieldOptionsDic.object(forKey: "title") as! String)
        cell.backV.layer.cornerRadius = 4
        cell.backV.layer.borderWidth = 1
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        let cell = collectionView.cellForItem(at: indexPath) as! SelectionCollectionCell
        let dataFieldDic1 = allFieldsDataArray.object(at: collectionView.tag) as! NSDictionary
        let parent_identifier = dataFieldDic1.object(forKey: "parent_identifier") as! String
        
        if !parent_identifier.isEmpty{
            let result =  checkForParentIdentifierValue(parent_identifier:parent_identifier)
            if result
            {
                displayAlert(msg: "Select the \n\(parent_identifier) first")
            }
        }
        
        
        setSelectedRow(section: collectionView.tag, row: indexPath.row)
        
        let dataFieldDic = allFieldsDataArray.object(at: collectionView.tag) as! NSDictionary
        let fieldOptionsDic = ((dataFieldDic.object(forKey: "field_options") as! NSArray).object(at: indexPath.row) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        
        
        if fieldOptionsDic.object(forKey: "isSelected") as! String == "1" {
            cell.backV.backgroundColor = UIColor(red: 245/255.0, green: 248/255.0, blue: 254/255.0, alpha: 1)
            cell.selectionTypeLbl.textColor = MAIN_COLOR
            cell.backV.layer.borderColor = MAIN_COLOR.cgColor
            cell.imageV.isHidden = false
            collectionView.reloadData()
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        return CGSize(width: 157, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
    }
}

