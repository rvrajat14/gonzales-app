//
//  EditVariantsVC.swift
//  My MM
//
//  Created by Kishore on 17/01/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit
import NotificationCenter

class EditVariantsVC: UIViewController {

    @IBOutlet weak var pageTitleLbl: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var serverErrorView: UIView!
    @IBAction func updateButton(_ sender: UIButton) {
        
            let (isValid,item_variant_type_title,minimum_selection) = validateForMinimumSelectionValueOfAnVariant()
        if !isValid {
            
            self.view.makeToast("\(item_variant_type_title)" + " | " + "a_variant_min".getLocalizedValue() + " | \(minimum_selection)", duration: 1, position: ToastPosition.bottom, title: "", image: nil, style: .init(), completion: nil)
            self.view.clearToastQueue()
            return
        }
            else
            {
                itemDataModel.selectedVariants = tempVariantsArray
                print(itemDataModel)
                productCartArray[selectedIndex] = itemDataModel
                NotificationCenter.default.post(name: NSNotification.Name.init("EditInstructionNotification"), object: nil, userInfo: ["msg":"a_cart_variants".getLocalizedValue()])
                
                self.dismiss(animated: true, completion: nil)
            }
         
    }
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBAction func backButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name.init("EditInstructionNotification"), object: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    var itemDataModel = ItemModel()
    var selectedIndex = 0
    var singleTypeTotalPrice = 0.0
    var tempVariantsArray = NSMutableArray.init()
    var itemTotalPrice = 0.0
    var variantsDataArray  = NSMutableArray.init()
    
    
    var indexPath:NSIndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        pageTitleLbl.text = "y_cart_variants".getLocalizedValue()
        backButton.setTitle("z_back".getLocalizedValue(), for: .normal)
        updateButton.setTitle("z_update".getLocalizedValue(), for: .normal)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1))
        topView.layer.masksToBounds = true
        topView.layer.cornerRadius = 10
//        variantsDataArray = itemDataModel.variants
//
//        for (mainIndex,mainValue) in self.variantsDataArray.enumerated()
//        {
//            let mainDictionary = (mainValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
//
//            let variantsValueArray = (mainDictionary.object(forKey: "options") as! NSArray).mutableCopy() as! NSMutableArray
//            if variantsValueArray.count > 0
//            {
//                for (subIndex,subValue) in variantsValueArray.enumerated()
//                {
//                    let subDictionary = (subValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
//                    subDictionary.setObject("0", forKey: "item_variant_photo" as NSCopying)
//                    subDictionary.setObject("0", forKey: "selected_variants" as NSCopying)
//                    for matchedValue in self.itemDataModel.selectedVariants as! [NSDictionary]
//                    {
//                        if matchedValue["item_variant_value_id"] as! NSNumber == subDictionary["item_variant_value_id"] as! NSNumber
//                        {
//                            if subDictionary["selection_type"] as! String == "single"
//                            {
//
//                                subDictionary.setObject( Double(matchedValue["item_variant_price"] as! String)! , forKey: "old_stored_value" as NSCopying)
//                            }
//                            subDictionary.setObject("1", forKey: "selected_variants" as NSCopying)
//                            self.tempVariantsArray.add(subDictionary)
//                        }
//                    }
//                    variantsValueArray.replaceObject(at: subIndex, with: subDictionary)
//                }
//            }
//
//            mainDictionary.setObject(variantsValueArray, forKey: "options" as NSCopying)
//            self.variantsDataArray.replaceObject(at: mainIndex, with: mainDictionary)
//        }
//
        getProductsVariants()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    //MARK: External Function
    
    //MARK: - Check For Minimum Selection Value
    
    func validateForMinimumSelectionValueOfAnVariant() -> (isValid:Bool,title:String,minimum_sel:Int) {
        
        for mainDic1 in self.variantsDataArray {
            let mainDic = mainDic1 as! NSDictionary
            
            let item_variant_type_id = Int(truncating: mainDic["item_setting_variant_type_id"] as! NSNumber)
            let minimum_selection = Int(truncating: mainDic["minimum_selection_needed"] as! NSNumber)
            let item_variant_type_title = mainDic["item_setting_variant_type_title"] as! String
            
            let (isAdded,count) = isVariantAdded(item_variant_type_id: item_variant_type_id)
            if isAdded
            {
                if minimum_selection > count
                {
                    return (false ,item_variant_type_title,minimum_selection)
                }
            }
            else
            {
                if minimum_selection > 0
                {
                    return (false,item_variant_type_title,minimum_selection)
                }
            }
        }
        return (true,"",-1)
    }
    
    //MARK: -Check Variant Is Added or Not In TempVariantArray
    func isVariantAdded(item_variant_type_id:Int) -> (Bool,Int) {
        var item_variant_values_count = 0
        var flag = false
        
        for mainDic1 in self.tempVariantsArray {
            let mainDic = mainDic1 as! NSDictionary
            print(mainDic)
            let itemVariantTypeId = Int(truncating: mainDic.object(forKey: "item_setting_variant_type_id") as! NSNumber)
            
            if itemVariantTypeId == item_variant_type_id
            {
                item_variant_values_count += 1
                flag = true
            }
            
        }
        
        if flag {
            return (true,item_variant_values_count)
        }
        else
        {
            return (false,-1)
        }
    }
    
    //MARK: -Validation function for Multiple Selection
    
    func checkForValidationOfSelectedVariantsArray(maximum_selection:Int,itemSettingVariantTypeId:NSNumber,selectionType:String) -> Bool {
        if maximum_selection == 0 {
            return true
        }
        //        var containSingleType = false
        //        if selectionType == "single" {
        //            for value in self.tempVariantsArray {
        //                if (value as! NSDictionary).object(forKey: "selection_type") as! String == "single"
        //                {
        //                    containSingleType = true
        //                    break
        //                }
        //            }
        //
        //        }
        
        //        if containSingleType {
        //            if maximum_selection  >= getVariantCounOfItemVariantSettingTypeId(itemVariantSettingTypeId: itemSettingVariantTypeId)
        //            {
        //                return true
        //            }
        //            else
        //            {
        //                return false
        //            }
        //        }
        //        else
        //        {
        if  maximum_selection > getVariantCounOfItemVariantSettingTypeId(itemVariantSettingTypeId: itemSettingVariantTypeId) {
            return true
        }
        else
        {
            return false
        }
        // }
    }
    
    //MARK: Get Variant count of particular item variant setting type id
    func getVariantCounOfItemVariantSettingTypeId(itemVariantSettingTypeId:NSNumber) -> Int {
        var count = 0
        
        for value in self.tempVariantsArray as!  [NSDictionary] {
            if value["item_setting_variant_type_id"] as! NSNumber == itemVariantSettingTypeId
            {
                count += 1
            }
        }
        print("Variant Count = \(count))")
        return  count
    }
    
    
    //MARK: -Multiple Selection Logic For Variants
    //MARK: -Add TempVariant in TempVariantArray
    
    func addVariantUsingMultipleSeleion(indexPath: IndexPath) {
        let mainDic = (self.variantsDataArray.object(at: indexPath.section) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        
        let tempVariantValuesArray = (mainDic.object(forKey: "options") as! NSArray).mutableCopy() as! NSMutableArray
        
        let tempVariantsDataDic = (tempVariantValuesArray.object(at: indexPath.row) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        let item_variant_price = tempVariantsDataDic.object(forKey: "item_variant_price") as! String
       // let item_variant_price_difference = tempVariantsDataDic.object(forKey: "item_variant_price_difference") as! String
       // let variantPriceDifference = getVariantPrice(item_price: item_variant_price, item_price_difference: item_variant_price_difference)
        let itemSettingVariantTypeId = tempVariantsDataDic.object(forKey: "item_setting_variant_type_id") as! NSNumber
        let selected_variants = tempVariantsDataDic.object(forKey: "selected_variants") as! String
        if  selected_variants == "0" {
            
            let maximum_selection = Int(truncating: mainDic.object(forKey: "maximum_selection_needed") as! NSNumber)
            if checkForValidationOfSelectedVariantsArray(maximum_selection: maximum_selection, itemSettingVariantTypeId: itemSettingVariantTypeId, selectionType: "multiple")
            {
                //itemTotalPrice += item_variant_price
                tempVariantsDataDic.setObject("1", forKey: "selected_variants" as NSCopying)
                tempVariantValuesArray.replaceObject(at: indexPath.row, with: tempVariantsDataDic)
                tempVariantsArray.add(tempVariantsDataDic)
            }
            else
            {
                self.view.makeToast("a_variant_max".getLocalizedValue(), duration: 1, position: ToastPosition.bottom, title: "", image: nil, style: .init(), completion: nil)
                
                self.view.clearToastQueue()
                return
            }
            
        }
        else if  selected_variants == "1" {
//            if itemTotalPrice == 0
//            {
//
//            }
//            else
//            {
//                itemTotalPrice -= item_variant_price
//            }
            tempVariantsDataDic.setObject("0", forKey: "selected_variants" as NSCopying)
            tempVariantValuesArray.replaceObject(at: indexPath.row, with: tempVariantsDataDic)
            if tempVariantsArray.count > 0
            {
                self.removeVariant(variantId: Int(truncating: tempVariantsDataDic.object(forKey: "item_variant_value_id") as! NSNumber))
            }
        }
        print(itemTotalPrice)
        mainDic.setObject(tempVariantValuesArray, forKey: "options" as NSCopying)
        self.variantsDataArray.replaceObject(at: indexPath.section, with: mainDic)
    }
    
    //MARK: -Remove Variant if it is added in tempVariantArray
    
    func removeVariant(variantId: Int) {
        
        for (_,value) in tempVariantsArray.enumerated() {
            
            if Int(truncating: (value as! NSDictionary).object(forKey: "item_variant_value_id") as! NSNumber) == variantId
            {
                tempVariantsArray.remove(value)
                break
            }
            
        }
        
    }

    
    //MARK: Get Variant Price
    
    func getVariantPrice(item_price:String, item_price_difference:String) -> Double {
        
        if item_price == "0"
        {
            if item_price_difference == "0" || item_price_difference.isEmpty
            {
                return 0.0
            }
            else
            {
                return  Double(item_price_difference)!
            }
        }
        else
        {
            return Double(item_price)!
        }
        
    }
    
   
    
    //MARK: -Single Selection Logic For Variants
    //MARK: -Add TempVariant in TempVariantArray
    
    func addVariantUsingSingleSelection(indexPath: IndexPath) {
        
        
        let selectedIndex = indexPath.row
        let mainDic = (self.variantsDataArray.object(at: indexPath.section) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        var old_store_value = 0.0
        
        let tempVariantValuesArray = ((mainDic.object(forKey: "options") as! NSArray).mutableCopy() as! NSMutableArray)
        for (index,value) in tempVariantValuesArray.enumerated()
        {
            let subDic = (value as! NSDictionary).mutableCopy() as! NSMutableDictionary
            let item_variant_price = subDic.object(forKey: "item_variant_price") as! String
           // let item_variant_price_difference = subDic.object(forKey: "item_variant_price_difference") as! String
           // let variantPriceDifference = getVariantPrice(item_price: item_variant_price, item_price_difference: item_variant_price_difference)
            let selected_variants = subDic.object(forKey: "selected_variants") as! String
            if subDic.value(forKey: "old_stored_value") != nil
            {
                old_store_value = Double(truncating: subDic.value(forKey: "old_stored_value") as! NSNumber)
            }
            
            if selectedIndex == index
            {
                singleTypeTotalPrice = 0.0
                if  selected_variants == "0"   {
                   // singleTypeTotalPrice = variantPriceDifference
                    subDic.setObject("1", forKey: "selected_variants" as NSCopying)
                   // subDic.setObject(variantPriceDifference, forKey: "old_stored_value" as NSCopying)
                    tempVariantValuesArray.replaceObject(at: index, with: subDic)
                    tempVariantsArray.add(subDic)
                    print("singleTotalPrice = \(singleTypeTotalPrice)")
                   // print("\nvariantPriceDifference = \(variantPriceDifference)")
                }
                
            }
            else
            {
                
                subDic.setObject("0", forKey: "selected_variants" as NSCopying)
                tempVariantValuesArray.replaceObject(at: index, with: subDic)
                print(tempVariantsArray)
                if tempVariantsArray.count > 0
                {
                    self.removeVariant(variantId: Int(truncating: subDic.object(forKey: "item_variant_value_id") as! NSNumber))
                }
                print(tempVariantsArray)
            }
        }
        itemTotalPrice -= old_store_value
        itemTotalPrice += singleTypeTotalPrice
        print("Item Total Price With Variants = \(itemTotalPrice)")
        mainDic.setObject(tempVariantValuesArray, forKey: "options" as NSCopying)
        self.variantsDataArray.replaceObject(at: indexPath.section, with: mainDic)
        
    }
    
    
    //MARK: Selector
    @objc func checkboxButton(sender:UIButton, event:AnyObject)
    {
        let touches: Set<UITouch>
        touches = (event.allTouches!)!
        let touch:UITouch = (touches.first)!
        let touchPosition:CGPoint = touch.location(in: self.tableView)
        let indexPath:NSIndexPath = self.tableView.indexPathForRow(at: touchPosition)! as NSIndexPath
        //let cell = self.tableView.cellForRow(at: indexPath as IndexPath) as! RadioButtonTableViewCell
        
        let mainDic = (self.variantsDataArray.object(at: indexPath.section) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        let selection_type = (mainDic.object(forKey: "selection_type") as! String)
        
        if selection_type == "multiple" {
            addVariantUsingMultipleSeleion(indexPath: indexPath as IndexPath)
        }
        else
        {
            self.addVariantUsingSingleSelection(indexPath: indexPath as IndexPath)
        }
        
        
        let tmpDataArray = (((self.variantsDataArray.object(at: indexPath.section) as! NSDictionary).object(forKey: "options") as! NSArray).mutableCopy() as! NSMutableArray).object(at: indexPath.row) as! NSDictionary
        
        
        if selection_type == "multiple" {
            if tmpDataArray.object(forKey: "selected_variants") as! String == "1" {
                sender.setImage(#imageLiteral(resourceName: "checkBox"), for: .normal)
            }
            else
            {
                sender.setImage(#imageLiteral(resourceName: "emptyCheckBox"), for: .normal)
            }
            
        }
        else
        {
            if tmpDataArray.object(forKey: "selected_variants") as! String == "1" {
                sender.setImage(#imageLiteral(resourceName: "round-checked"), for: .normal)
            }
            else
            {
                sender.setImage(#imageLiteral(resourceName: "radio_off"), for: .normal)
            }
        }
        self.tableView.reloadData()
        print(tempVariantsArray)
    }
    
    //MARK: -Get product variants
    
    
    func getProductsVariants() {
        let api_name = APINAME()
       let item_id = itemDataModel.id
        let url = api_name.ITEM_API + "/\(item_id)"
        WebService.requestGetUrl(strURL: url, params: NSDictionary.init(), is_loader_required: false, success: { (response) in
            print(response)
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
             
            
            if response["status_code"] as! NSNumber == 1
            {
                let dataDict = (response["data"] as! NSDictionary)
                
                    self.variantsDataArray = ((dataDict["variants"] as! NSArray).mutableCopy() as! NSMutableArray)
                
                for (mainIndex,mainValue) in self.variantsDataArray.enumerated()
                {
                    let mainDictionary = (mainValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    let item_setting_variant_type_id = (mainDictionary["item_setting_variant_type_id"] as! NSNumber)
                    
                    let variantsValueArray = (mainDictionary.object(forKey: "options") as! NSArray).mutableCopy() as! NSMutableArray
                    if variantsValueArray.count > 0
                    {
                        for (subIndex,subValue) in variantsValueArray.enumerated()
                        {
                             let subDictionary = (subValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
                            subDictionary.setObject("0", forKey: "selected_variants" as NSCopying)
                            subDictionary.setObject(item_setting_variant_type_id, forKey: "item_setting_variant_type_id" as NSCopying)
                            
                            for matchedValue in self.itemDataModel.selectedVariants as! [NSDictionary]
                            {
                                if matchedValue["item_variant_value_id"] as! NSNumber == subDictionary["item_variant_value_id"] as! NSNumber
                                {
                                   if mainDictionary["selection_type"] as! String == "single"
                                   {
                                    
                                    subDictionary.setObject( Double(matchedValue["item_variant_price"] as! String)! , forKey: "old_stored_value" as NSCopying)
                                    }
                                  subDictionary.setObject("1", forKey: "selected_variants" as NSCopying)
                                    self.tempVariantsArray.add(subDictionary)
                                }
                            }
                            variantsValueArray.replaceObject(at: subIndex, with: subDictionary)
                        }
                    }
                    
                    mainDictionary.setObject(variantsValueArray, forKey: "options" as NSCopying)
                    self.variantsDataArray.replaceObject(at: mainIndex, with: mainDictionary)
                }
                
                print(self.variantsDataArray)
                self.tableView.reloadData()
            }
                
            else
            {
                COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
            }
            
        }) { (failure) in
             self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
    }
    
    
}

extension EditVariantsVC : UITableViewDelegate,UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if self.variantsDataArray.count > 0 {
                if ((self.variantsDataArray.object(at: section) as! NSDictionary).object(forKey: "options") as! NSArray).count > 0
                {
                    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
                    // headerView.backgroundColor = UIColor.blue
                    
                    let titleLbl:UILabel = UILabel(frame: CGRect(x: headerView.frame.origin.x + 16, y: 15, width: self.view.frame.size.width - 32, height: 20))
                    // titleLbl.backgroundColor = UIColor.yellow
                    titleLbl.font = UIFont(name: REGULAR_FONT, size: 17)
                    
                    titleLbl.text = ((self.variantsDataArray.object(at: section) as! NSDictionary)["item_setting_variant_type_title"] as! String)
                    let fontD:UIFontDescriptor = titleLbl.font.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!
                    titleLbl.font = UIFont(descriptor: fontD, size: 17)
                    headerView.addSubview(titleLbl)
                    
                    return headerView
                }
        }
        return UIView(frame: .zero)
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if variantsDataArray.count > 0 {
           return 50
        }
            return 0
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if variantsDataArray.count > 0 {
            return variantsDataArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((self.variantsDataArray.object(at: section) as! NSDictionary).object(forKey: "options") as! NSArray).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nib:UINib = UINib(nibName: "RadioButtonTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "RadioButtonTableViewCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "RadioButtonTableViewCell", for: indexPath) as! RadioButtonTableViewCell
        if self.variantsDataArray.count != 0 {
            let variantsDataArray = ((self.variantsDataArray.object(at: indexPath.section) as! NSDictionary).object(forKey: "options") as! NSArray).mutableCopy() as! NSMutableArray
            let selection_type = (self.variantsDataArray.object(at: indexPath.section) as! NSDictionary)["selection_type"] as! String
            let variantDic = variantsDataArray.object(at: indexPath.row) as! NSDictionary
            let dataDic = variantsDataArray.object(at: indexPath.row) as! NSDictionary
            let item_variant_value_title = (dataDic.object(forKey: "item_variant_value_title") as! String)
            let item_variant_price = dataDic.object(forKey: "item_variant_price") as! String
             let price_status = ((self.variantsDataArray.object(at: indexPath.section) as! NSDictionary).object(forKey: "price_status") as! String)
            
            if price_status == "0"
            {
                cell.variantsNameLbl.text = item_variant_value_title
            }
            else if price_status == "1"
            {
                cell.variantsNameLbl.text = "\(item_variant_value_title)  ( + \(currency_type)\(item_variant_price))"
            }
            else
            {
                cell.variantsNameLbl.text = "\(item_variant_value_title)  (\(currency_type)\(item_variant_price))"
            }
            
            if selection_type == "multiple"
            {
                if variantDic.object(forKey: "selected_variants") as! String == "0"
                {
                    cell.checkBoxButton.setImage(#imageLiteral(resourceName: "emptyCheckBox"), for: .normal)
                }
                else
                {
                    cell.checkBoxButton.setImage(#imageLiteral(resourceName: "checkBox"), for: .normal)
                }
            }
            else
            {
                if variantDic.object(forKey: "selected_variants") as! String == "0"
                {
                    cell.checkBoxButton.setImage(#imageLiteral(resourceName: "radio_off"), for: .normal)
                }
                else
                {
                    cell.checkBoxButton.setImage(#imageLiteral(resourceName: "round-checked"), for: .normal)
                }
            }
            
            cell.checkBoxButton.tag = Int((dataDic.object(forKey: "item_variant_value_id") as! NSNumber).stringValue)!
            cell.checkBoxButton.addTarget(self, action: #selector(checkboxButton(sender:event:)), for: .touchUpInside)
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
   
    
}
