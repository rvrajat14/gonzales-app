//
//  PopUpVC.swift
//  FirstSwiftTask
//
//  Created by Kishore on 30/05/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import PullToDismiss
import NotificationCenter
import Shimmer

class PopUpVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    
    
    
    @IBOutlet weak var topView: UIView!
    
    @IBAction func backButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name.init("itemInstructionNotificaion"), object: nil)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    var isTypeSelected = true
    var isFragileSelected = false
    
    
    @IBOutlet weak var washingTypeButtonBottomV: UIView!
    
    @IBAction func washingTypeButton(_ sender: UIButton) {
           sender.setTitleColor(MAIN_COLOR, for: .normal)
        instructionButton.setTitleColor(UIColor.lightGray, for: .normal)
         washingTypeButtonBottomV.isHidden = false
        instructionButtonBottomV.isHidden = true
       isTypeSelected = true
        self.tableView.reloadData()
    }
    
    @IBAction func instructionButton(_ sender: UIButton) {
        washingTypeButton.setTitleColor(UIColor.lightGray, for: .normal)
        sender.setTitleColor(MAIN_COLOR, for: .normal)
        washingTypeButtonBottomV.isHidden = true
        instructionButtonBottomV.isHidden = false
        isTypeSelected = false
         self.tableView.reloadData()
    }
    
    @IBOutlet weak var serverErrorView: UIView!
    @IBOutlet weak var instructionButtonBottomV: UIView!
    @IBOutlet weak var instructionButton: UIButton!
    @IBAction func crossButton(_ sender: UIButton) {
       
        
    }
    @IBOutlet weak var washingTypeButton: UIButton!
    @IBOutlet weak var crossButton: UIButton!
    
    var shimmerView:FBShimmeringView!
    var itemModel = ItemModel()
    var singleTypeTotalPrice = 0.0
    var tempVariantsArray:NSMutableArray!
    var itemTotalPrice = 0.0
    var variantsDataArray  = NSMutableArray.init()
    var instructionDataArray = NSMutableArray.init()
    
    @IBOutlet weak var totalItemLbl: UILabel!
   
    @IBOutlet weak var addItemButton: UIButton!
    var pullToDismiss: PullToDismiss?
    var indexPath:NSIndexPath?
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.setTitle("z_back".getLocalizedValue(), for: .normal)
        
        addItemButton.setTitle("z_add".getLocalizedValue(), for: .normal)
        
        self.addItemButton.layer.cornerRadius = 6
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1))
        self.serverErrorView.isHidden = true
        variantsDataArray = itemModel.variants
        
        for (mainIndex,mainValue) in self.variantsDataArray.enumerated()
        {
            let mainDictionary = (mainValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
            let item_setting_variant_type_id = mainDictionary["item_setting_variant_type_id"] as! NSNumber
            
            let variantsValueArray = (mainDictionary.object(forKey: "options") as! NSArray).mutableCopy() as! NSMutableArray
            if variantsValueArray.count > 0
            {
                for (subIndex,subValue) in (variantsValueArray as! [NSDictionary]).enumerated()
                {
                    let subDictionary = subValue.mutableCopy() as! NSMutableDictionary
                    subDictionary.setObject(item_setting_variant_type_id, forKey: "item_setting_variant_type_id" as NSCopying)
                    subDictionary.setObject("0", forKey: "selected_variants" as NSCopying)
                    
                    variantsValueArray.replaceObject(at: subIndex, with: subDictionary)
                }
            }
            
            mainDictionary.setObject(variantsValueArray, forKey: "options" as NSCopying)
            self.variantsDataArray.replaceObject(at: mainIndex, with: mainDictionary)
        }
        
        self.crossButton.isHidden = true
        self.instructionButton.isHidden = true
        self.instructionButtonBottomV.isHidden = true
        topView.layer.masksToBounds = true
        topView.layer.cornerRadius = 10
        //getProductsVariants()
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        tempVariantsArray = NSMutableArray.init()
        tempVariantsArray.removeAllObjects()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.variantsDataArray.count == 0 {
            return 1
        }
        print(self.variantsDataArray.count)
        
        if isTypeSelected {
            return self.variantsDataArray.count
        }
        else
        {
            return 1
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.variantsDataArray.count == 0 {
            let deviceHeight = self.view.frame.size.height
            return  Int(deviceHeight / 63)
        }
       
        return ((self.variantsDataArray.object(at: section) as! NSDictionary).object(forKey: "options") as! NSArray).count
       
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if self.variantsDataArray.count == 0   {
            let nib1 = UINib(nibName: "VariantsTableCell", bundle: nil)
            
            tableView.register(nib1, forCellReuseIdentifier: "VariantsTableCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier:"VariantsTableCell") as! VariantsTableCell
            
            shimmerView = FBShimmeringView(frame: cell.frame)
            shimmerView.contentView = cell
            shimmerView.isShimmering = true
            return cell
        }
        
        if let sm = shimmerView {
            sm.isShimmering = false
        }
        
            if isTypeSelected {
                
                let nib:UINib = UINib(nibName: "RadioButtonTableViewCell", bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: "RadioButtonTableViewCell")
                let cell = tableView.dequeueReusableCell(withIdentifier: "RadioButtonTableViewCell", for: indexPath) as! RadioButtonTableViewCell
                if self.variantsDataArray.count != 0 {
                    let variantsDataArray = ((self.variantsDataArray.object(at: indexPath.section) as! NSDictionary).object(forKey: "options") as! NSArray).mutableCopy() as! NSMutableArray
                    let selection_type = (self.variantsDataArray.object(at: indexPath.section) as! NSDictionary)["selection_type"] as! String
                    let dataDic = (variantsDataArray.object(at: indexPath.row) as! NSDictionary)
                    let price_status = ((self.variantsDataArray.object(at: indexPath.section) as! NSDictionary).object(forKey: "price_status") as! String)
                    let item_variant_value_title = (dataDic.object(forKey: "item_variant_value_title") as! String)
                    let item_variant_price = dataDic.object(forKey: "item_variant_price") as! String
                    
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
                        if dataDic.object(forKey: "selected_variants") as! String == "0"
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
                        if dataDic.object(forKey: "selected_variants") as! String == "0"
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
            else
            {
                let addInstructionNib = UINib(nibName: "AddInstructionTableViewCell", bundle: nil)
                self.tableView.register(addInstructionNib, forCellReuseIdentifier: "AddInstructionTableViewCell")
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddInstructionTableViewCell", for: indexPath) as! AddInstructionTableViewCell
                let dataDic = instructionDataArray[indexPath.row] as! NSDictionary
                 cell.courierDetailsView.isHidden = true
                cell.instructionView.isHidden = false
                cell.instructionDetailsView.layer.cornerRadius = 6
                cell.instructionDetailsView.layer.borderWidth = 1
                cell.instructionDetailsView.layer.borderColor = UIColor.lightGray.cgColor
                cell.instructionTitleLbl.text = (dataDic["order_item_instructions_type_title"] as! String)
                cell.instructionDetailsTxt.delegate = self
                cell.instructionDetailsTxt.tag = indexPath.row
                
                let placeholder = dataDic["order_item_instructions_type_placeholder"] as! String
                let value = dataDic["value"] as! String
                
                if value.isEmpty
                {
                    cell.instructionDetailsTxt.placeholder = placeholder
                }
                else
                {
                    cell.instructionDetailsTxt.text = value
                }
                
                cell.selectionStyle = .none
                return cell
            }
            
        
    }
    
   
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        let datadic = (instructionDataArray[textField.tag] as! NSDictionary).mutableCopy() as! NSMutableDictionary
        datadic.setObject(textField.text!, forKey: "value" as NSCopying)
        instructionDataArray.replaceObject(at: textField.tag, with: datadic)
        
        let cell = tableView.cellForRow(at: IndexPath(row: textField.tag, section: 0)) as! AddInstructionTableViewCell
        cell.instructionDetailsTxt.text = textField.text!
       
    }
    
    //MARK: -Selector Methods
    
    
    
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
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isTypeSelected {
            let cell = self.tableView.cellForRow(at: indexPath as IndexPath) as! RadioButtonTableViewCell
            
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
                    
                    cell.checkBoxButton.setImage(#imageLiteral(resourceName: "checkBox"), for: .normal)
                }
                else
                {
                    cell.checkBoxButton.setImage(#imageLiteral(resourceName: "emptyCheckBox"), for: .normal)
                }
                
            }
            else
            {
                if tmpDataArray.object(forKey: "selected_variants") as! String == "1" {
                    cell.checkBoxButton.setImage(#imageLiteral(resourceName: "round-checked"), for: .normal)
                }
                else
                {
                    cell.checkBoxButton.setImage(#imageLiteral(resourceName: "radio_off"), for: .normal)
                }
            }
            self.tableView.reloadData()
            print(tempVariantsArray)
        }
        
        
    }
    
 
    //MARK: -Single Selection Logic For Variants
    //MARK: -Add TempVariant in TempVariantArray
    
    func addVariantUsingSingleSelection(indexPath: IndexPath) {
       
        let selectedIndex = indexPath.row
        let mainDic = (self.variantsDataArray.object(at: indexPath.section) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        let tempVariantValuesArray = ((mainDic.object(forKey: "options") as! NSArray).mutableCopy() as! NSMutableArray)
        for (index,value) in tempVariantValuesArray.enumerated()
        {
            let subDic = (value as! NSDictionary).mutableCopy() as! NSMutableDictionary
            let selected_variants = subDic.object(forKey: "selected_variants") as! String
                if selectedIndex == index
                    {
                     if  selected_variants == "0"   {
                        subDic.setObject("1", forKey: "selected_variants" as NSCopying)
                        tempVariantValuesArray.replaceObject(at: index, with: subDic)
                        tempVariantsArray.add(subDic)
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
        itemTotalPrice += singleTypeTotalPrice
        mainDic.setObject(tempVariantValuesArray, forKey: "options" as NSCopying)
        self.variantsDataArray.replaceObject(at: indexPath.section, with: mainDic)
        
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
        let itemSettingVariantTypeId = tempVariantsDataDic.object(forKey: "item_setting_variant_type_id") as! NSNumber
        let selected_variants = tempVariantsDataDic.object(forKey: "selected_variants") as! String
        if  selected_variants == "0" {
            let maximum_selection = Int(truncating: mainDic.object(forKey: "maximum_selection_needed") as! NSNumber)
            if checkForValidationOfSelectedVariantsArray(maximum_selection: maximum_selection, itemSettingVariantTypeId: itemSettingVariantTypeId, selectionType: "multiple")
            {
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
            tempVariantsDataDic.setObject("0", forKey: "selected_variants" as NSCopying)
            tempVariantValuesArray.replaceObject(at: indexPath.row, with: tempVariantsDataDic)
            if tempVariantsArray.count > 0
            {
                self.removeVariant(variantId: Int(truncating: tempVariantsDataDic.object(forKey: "item_variant_value_id") as! NSNumber))
            }
        }
        mainDic.setObject(tempVariantValuesArray, forKey: "options" as NSCopying)
        self.variantsDataArray.replaceObject(at: indexPath.section, with: mainDic)
    }
    
  
    
    //MARK: -Validation function for Multiple Selection
    
    func checkForValidationOfSelectedVariantsArray(maximum_selection:Int,itemSettingVariantTypeId:NSNumber,selectionType:String) -> Bool {
        if maximum_selection == 0 {
            return true
        }
            if  maximum_selection > getVariantCounOfItemVariantSettingTypeId(itemVariantSettingTypeId: itemSettingVariantTypeId) {
                return true
            }
            else
            {
                return false
            }
    }
    
    
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
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print(" ")
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
        
       // var title = ""
        if self.variantsDataArray.count > 0 {
       
        if isTypeSelected {
            if ((self.variantsDataArray.object(at: section) as! NSDictionary).object(forKey: "options") as! NSArray).count > 0
            {
                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
                let titleLbl:UILabel = UILabel(frame: CGRect(x: headerView.frame.origin.x + 16, y: 15, width: self.view.frame.size.width - 32, height: 20))
                titleLbl.font = UIFont(name: REGULAR_FONT, size: 17)
                titleLbl.text = ((self.variantsDataArray.object(at: section) as! NSDictionary)["item_setting_variant_type_title"] as! String)
                let fontD:UIFontDescriptor = titleLbl.font.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!
                titleLbl.font = UIFont(descriptor: fontD, size: 17)
                headerView.addSubview(titleLbl)
                
                return headerView
            }
        }
            
        }
               return UIView(frame: .zero)
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.isTypeSelected
        {
        return 50
        }
        return 0
    }

    
    //MARK: -Get TableMain Header
    
    func getHeader() -> UIView {
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 80))
        headerView.backgroundColor = UIColor.white
        let sideView = UIView(frame: CGRect(x: 0, y: 10, width: 4, height: 60))
        sideView.backgroundColor = MAIN_COLOR
        headerView.addSubview(sideView)
        
        let titleLbl:UILabel = UILabel(frame: CGRect(x: headerView.frame.origin.x + 16, y: headerView.frame.origin.y + 12, width: self.view.frame.size.width - 32, height: 24))
        titleLbl.font = UIFont(name: REGULAR_FONT, size: 20)
        titleLbl.text =  itemModel.title
        let fontD:UIFontDescriptor = titleLbl.font.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!
        titleLbl.font = UIFont(descriptor: fontD, size: 20)
        headerView.addSubview(titleLbl)
        
        let priceLbl:UILabel = UILabel(frame: CGRect(x: titleLbl.frame.origin.x, y: titleLbl.frame.origin.y + titleLbl.frame.size.height + 2, width: self.view.frame.size.width - 32, height: 20))
        priceLbl.font = UIFont(name: REGULAR_FONT, size: 16)
        priceLbl.text = currency_type + itemModel.price
        headerView.addSubview(priceLbl)
        return headerView
    }
    
    //MARK: - Add Product into Cart Array
    
    @IBAction func addItemButton(_ sender: UIButton) {
        
        let (isValid,item_variant_type_title,minimum_selection) = validateForMinimumSelectionValueOfAnVariant()
        if !isValid {
            
            self.view.makeToast("\(item_variant_type_title)" + " | " + "a_variant_min".getLocalizedValue() + " | \(minimum_selection)", duration: 1, position: ToastPosition.bottom, title: "", image: nil, style: .init(), completion: nil)
            
            self.view.clearToastQueue()
            
            return
        }
        
        if tempVariantsArray.count > 0
        {
           
            
            var isMatched = false
            
            if (productCartArray.count) > 0 {
                
                for  (index,tempItemModel) in ((productCartArray as! [ItemModel]).enumerated())
                {
                    let tempArray = tempItemModel.selectedVariants
                    
                        if isArrayEqual(newArray: tempVariantsArray, OldArray:tempArray)
                        {
                            var quantity =  Int(tempItemModel.quantity)!
                            quantity += 1
                            tempItemModel.quantity = String(quantity)
                            productCartArray.replaceObject(at: index, with: tempItemModel)
                            
                            isMatched = true
                            break
                        }
                   
                    isMatched = false
                }
                if isMatched
                {
                    ModalTransitionMediator.instance.sendPopoverDismissed(modelChanged: true)
                    NotificationCenter.default.post(name: NSNotification.Name.init("itemInstructionNotificaion"), object: nil)
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                    print(productCartArray)
                    return
                }
                else
                {
                    let tmpItem = ItemModel()
                    tmpItem.quantity = "1"
                    tmpItem.selectedVariants = tempVariantsArray
                    tmpItem.id = itemModel.id
                    tmpItem.store_id = itemModel.store_id
                    tmpItem.price = itemModel.price
                    tmpItem.title = itemModel.title
                    tmpItem.thumb_photo = itemModel.thumb_photo
                    tmpItem.photo = itemModel.photo
                    tmpItem.variants = itemModel.variants
                    tmpItem.active_status = itemModel.active_status
                    tmpItem.item_description = itemModel.item_description
                    tmpItem.item_price_single = itemModel.item_price_single
                    tmpItem.item_price_total = itemModel.item_price_total
                    tmpItem.unit = itemModel.unit
                    productCartArray.add(tmpItem)
                    ModalTransitionMediator.instance.sendPopoverDismissed(modelChanged: true)
                    NotificationCenter.default.post(name: NSNotification.Name.init("itemInstructionNotificaion"), object: nil)
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                    print(productCartArray)
                    return
                }
                
            }
            else
            {
                let tmpItem = ItemModel()
                tmpItem.quantity = "1"
                tmpItem.selectedVariants = tempVariantsArray
                tmpItem.id = itemModel.id
                tmpItem.store_id = itemModel.store_id
                tmpItem.price = itemModel.price
                tmpItem.title = itemModel.title
                tmpItem.thumb_photo = itemModel.thumb_photo
                tmpItem.photo = itemModel.photo
                tmpItem.variants = itemModel.variants
                tmpItem.active_status = itemModel.active_status
                tmpItem.item_description = itemModel.item_description
                tmpItem.item_price_single = itemModel.item_price_single
                tmpItem.item_price_total = itemModel.item_price_total
                tmpItem.unit = itemModel.unit
                productCartArray.add(tmpItem)
                ModalTransitionMediator.instance.sendPopoverDismissed(modelChanged: true)
                print(productCartArray)
                NotificationCenter.default.post(name: NSNotification.Name.init("itemInstructionNotificaion"), object: nil)
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                return
            }
            
        }
        else
        {
            var quantity = 0, currentIndex = -1
            var result = false
            
            for (index,value) in (productCartArray as! [ItemModel]).enumerated(){
                
                if value.id == itemModel.id && value.selectedVariants.count == 0
                {
                    result = true
                    quantity = Int(value.quantity)!
                    currentIndex = index
                    break;
                }
                
                result = false
                
            }
            
            
            if result
            {
                quantity += 1
                let tmpItemModel = (productCartArray[currentIndex] as! ItemModel)
                tmpItemModel.quantity = String(quantity)
                productCartArray.replaceObject(at: currentIndex, with: tmpItemModel)
            }
            else
            {
                let tmpItem = ItemModel()
                tmpItem.selectedVariants = tempVariantsArray
                tmpItem.quantity = "1"
                tmpItem.id = itemModel.id
                tmpItem.store_id = itemModel.store_id
                tmpItem.price = itemModel.price
                tmpItem.title = itemModel.title
                tmpItem.thumb_photo = itemModel.thumb_photo
                tmpItem.photo = itemModel.photo
                tmpItem.variants = itemModel.variants
                tmpItem.active_status = itemModel.active_status
                tmpItem.item_description = itemModel.item_description
                tmpItem.item_price_single = itemModel.item_price_single
                tmpItem.item_price_total = itemModel.item_price_total
                tmpItem.unit = itemModel.unit
                productCartArray.add(tmpItem)
            }
            
            
            ModalTransitionMediator.instance.sendPopoverDismissed(modelChanged: true)
            print(productCartArray)
            NotificationCenter.default.post(name: NSNotification.Name.init("itemInstructionNotificaion"), object: nil)
            self.presentingViewController?.dismiss(animated: true, completion: nil)
            return
        }
        
    }
 
    
    
    //MARK: Local JSON
   
    func getLocalJSON()  {
        if let path = Bundle.main.path(forResource: "ItemVariantsJSON", ofType: "json")
        {
            do
            {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                print(jsonResult)
                if let jsonResult = jsonResult as? Dictionary<String,AnyObject>
                {
                  
                     let allDataDicArray = ((jsonResult as NSDictionary)["data"] as! NSArray) as! [NSDictionary]
                    
                    if allDataDicArray.count > 1
                    
                    {
                        self.washingTypeButton.setTitle((allDataDicArray[0]["title"] as! String), for: .normal)
                        self.instructionButton.setTitle((allDataDicArray[1]["title"] as! String), for: .normal)
                      self.variantsDataArray = (allDataDicArray[0]["data"] as! NSArray).mutableCopy() as! NSMutableArray
                    self.instructionDataArray = (allDataDicArray[1]["data"] as! NSArray).mutableCopy() as! NSMutableArray
                    }
                    else if allDataDicArray.count == 1
                    {
                         self.washingTypeButton.setTitle((allDataDicArray[0]["title"] as! String), for: .normal)
                         self.variantsDataArray = (allDataDicArray[0]["data"] as! NSArray).mutableCopy() as! NSMutableArray
                        self.instructionButton.isHidden = true
                        self.crossButton.isHidden = true
                        self.instructionButtonBottomV.isHidden = true
                    }
                    
                    if instructionDataArray.count == 0
                    {
                        self.instructionButtonBottomV.isHidden = true
                        self.instructionButton.isHidden = true
                        self.crossButton.isHidden = true
                    }
                    
                  
                    for (mainIndex,mainValue) in self.variantsDataArray.enumerated()
                    {
                        let mainDictionary = (mainValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
                        
                        let variantsValueArray = (mainDictionary.object(forKey: "options") as! NSArray).mutableCopy() as! NSMutableArray
                        if variantsValueArray.count > 0
                        {
                            for (subIndex,subValue) in variantsValueArray.enumerated()
                            {
                                let subDictionary = (subValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
                                subDictionary.setObject("0", forKey: "selected_variants" as NSCopying)
                                variantsValueArray.replaceObject(at: subIndex, with: subDictionary)
                            }
                        }
                        
                        mainDictionary.setObject(variantsValueArray, forKey: "variants" as NSCopying)
                        self.variantsDataArray.replaceObject(at: mainIndex, with: mainDictionary)
                    }
                    print(self.variantsDataArray)
                    self.tableView.reloadData()
                }
                
            }
            catch
            {
                
            }
        }
        
    }
    
    
    //MARK: -Get product variants
    
    
    func getProductsVariants() {
        let api_name = APINAME()
        let url = api_name.ITEM_VARIANT + "?item=\(itemModel.id)&timezone=\(localTimeZoneName)"
        WebService.requestGetUrl(strURL: url, params: NSDictionary.init(), is_loader_required: false, success: { (response) in
            print(response)
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
            
            
            if response["status_code"] as! NSNumber == 1
            {

                let allDataDicArray = (response["data"] as! NSArray) as! [NSDictionary]
                
                if allDataDicArray.count > 1
                    
                {
                    self.washingTypeButton.setTitle((allDataDicArray[0]["variant_title"] as! String), for: .normal)
                    self.instructionButton.setTitle((allDataDicArray[1]["variant_title"] as! String), for: .normal)
                    self.variantsDataArray = (allDataDicArray[0]["data"] as! NSArray).mutableCopy() as! NSMutableArray
                    self.instructionDataArray = (allDataDicArray[1]["data"] as! NSArray).mutableCopy() as! NSMutableArray
                }
                else if allDataDicArray.count == 1
                {
                    self.washingTypeButton.setTitle((allDataDicArray[0]["variant_title"] as! String), for: .normal)
                    self.variantsDataArray = (allDataDicArray[0]["data"] as! NSArray).mutableCopy() as! NSMutableArray
                    self.instructionButton.isHidden = true
                    self.crossButton.isHidden = true
                    self.instructionButtonBottomV.isHidden = true
                }
                
                if self.instructionDataArray.count == 0
                {
                    self.instructionButtonBottomV.isHidden = true
                    self.instructionButton.isHidden = true
                    self.crossButton.isHidden = true
                }
                
                
                for (mainIndex,mainValue) in self.variantsDataArray.enumerated()
                {
                    let mainDictionary = (mainValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    
                    let variantsValueArray = (mainDictionary.object(forKey: "options") as! NSArray).mutableCopy() as! NSMutableArray
                    if variantsValueArray.count > 0
                    {
                        for (subIndex,subValue) in (variantsValueArray as! [NSDictionary]).enumerated()
                        {
                              let subDictionary = subValue.mutableCopy() as! NSMutableDictionary
                           
                            subDictionary.setObject("0", forKey: "selected_variants" as NSCopying)
                            
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
    
    
    //MARK: -Comparing Two Array
    
    func isArrayEqual(newArray:NSArray,OldArray:NSArray) -> Bool {
        print("new array = \(newArray)")
        print("new array = \(OldArray)")
       
        
        if newArray.isEqual(to: OldArray as! [Any]) {
           print("Equal")
        }else{
            print("Not Equal")
        }
        
        if newArray.count != 0  || OldArray.count != 0 {
            let set1 = NSSet(array: newArray as! [Any])
            let set2 = NSSet(array: OldArray as! [Any])
            
            if set1.isEqual(to: set2 as! Set<AnyHashable>)
            {
            return true
            }
        }
         return false
    }
    
    
    
    
}


 


