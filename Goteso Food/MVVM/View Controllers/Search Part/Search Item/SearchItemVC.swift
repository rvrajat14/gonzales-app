//
//  SearchItemVC.swift
//  My MM
//
//  Created by Kishore on 03/01/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit
import CRRefresh
import NotificationCenter

class SearchItemVC: UIViewController {

    @IBOutlet weak var pageTitleLbl: UILabel!
    @IBOutlet weak var serverErrorView: UIView!
    @IBOutlet weak var blurV: UIView!
    
    @IBOutlet weak var noDataFoundLbl: UILabel!
    @IBAction func basketButton(_ sender: CustomBadgeButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBOutlet weak var basketButton: CustomBadgeButton!
    var searchedItemArray = NSMutableArray.init()
    var currentPage = 1
    var total_page = 0
    var to_page = 0
    var category_level = "1"
    var allItemsDataArray = NSMutableArray.init()
     @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTxtField: UITextField!
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var backButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageTitleLbl.text = "h_search_product".getLocalizedValue()
        searchTxtField.placeholder = "h_search_product".getLocalizedValue()
        noDataFoundLbl.text = "e_items".getLocalizedValue()
        if Language.isRTL {
            searchTxtField.textAlignment = .right
        }
        else
        {
            searchTxtField.textAlignment = .left
        }
        
        self.searchView.layer.cornerRadius = 10
        SHADOW_EFFECT.makeBottomShadow(forView: self.noDataView, shadowHeight: 5)
        self.searchTxtField.becomeFirstResponder()
      
        addRefreshFunctionality()
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
        let nib = UINib(nibName: "ItemTableCellWithAddButton", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ItemTableCellWithAddButton")
         NotificationCenter.default.addObserver(self, selector: #selector(itemInstructionViewNotificaionAction(notification:)), name: NSNotification.Name.init("itemInstructionNotificaion"), object: nil)
        
        if productCartArray.count > 0 {
            basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
        }
        
        CallApi(search_string: "", page: 1)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: -Add Pull To Down and Pull To Up Refresh
    
    func addRefreshFunctionality()  {
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            self?.CallApi(search_string: (self?.searchTxtField.text!)!, page: 1)
            
            self?.tableView.cr.resetNoMore()
        }
        
        
        tableView.cr.addFootRefresh(animator: NormalFooterAnimator()) {
            [weak self] in
            if (self?.to_page)! == (self?.total_page)!
            {
                self?.tableView.cr.noticeNoMoreData()
                return
            }
            self?.CallApi(search_string: (self?.searchTxtField.text!)!, page: (self?.currentPage)!)
        }
    }
    
    
    //MARK: API CALL
    func CallApi(search_string:String,page:Int) -> Void{
        
        var api_name = APINAME().ITEM_API + "?page=\(page)&store_id=\(store_id)&search=\(search_string)"
        api_name = api_name.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: false, success: { (response) in
            
            print(response)
            self.searchedItemArray.removeAllObjects()
          
            if response["status_code"] as! NSNumber == 1
            {
                if page == 1
                {
                    
                    self.allItemsDataArray.removeAllObjects()
                    self.currentPage = 1
                }
                
              let dataArray = ((response["data"] as! NSDictionary).object(forKey: "data") as! NSArray)
                
                if dataArray.count == 0
                {
                     self.allItemsDataArray.removeAllObjects()
                    self.tableView.reloadData()
                    self.tableView.cr.endHeaderRefresh()
                    self.tableView.cr.endFooterRefresh()
                    self.noDataView.isHidden = false
                    return
                }
                
                self.total_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "total") as! NSNumber)
                self.to_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "to") as! NSNumber)
                
               
                for (itemIndex,subCategoryItems) in (dataArray as! [NSDictionary]).enumerated()
                {
                    let itemModel = ItemModel(id: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_id"] as AnyObject).1, title: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_title"] as AnyObject).1, thumb_photo: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["thumb_photo"] as AnyObject).1, photo: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["photo"] as AnyObject).1, discount: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_discount"] as AnyObject).1, store_id: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["store_id"] as AnyObject).1, item_description: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_description"] as AnyObject).1, quantity: "0", price:  COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_price"] as AnyObject).1, item_price_single: "0", item_price_total: "0", unit: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["unit"] as AnyObject).1, active_status: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_active_status"] as AnyObject).1, item_stock_count: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_stock_count"] as AnyObject).1, variants: ((subCategoryItems["variants"] as! NSArray).mutableCopy() as! NSMutableArray), selectedVariants: NSMutableArray())
                
                  
                   self.allItemsDataArray[itemIndex] = itemModel
                    
                }
                
                if (((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "next_page_url") as? String) != nil
                {
                    self.currentPage += 1
                }
                
                self.noDataView.isHidden = true
                
                self.searchedItemArray = NSMutableArray(array: self.allItemsDataArray)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.cr.endHeaderRefresh()
                    self.tableView.cr.endFooterRefresh()
                    
                }
                
            }
            else
            {
                self.allItemsDataArray.removeAllObjects()
                self.searchedItemArray.removeAllObjects()
                self.tableView.reloadData()
                self.tableView.cr.endHeaderRefresh()
                self.tableView.cr.endFooterRefresh()
                self.noDataView.isHidden = false
                
            }
        }) { (failure) in
            
            if self.tableView != nil
            {
                self.tableView.cr.endHeaderRefresh()
                self.tableView.cr.endFooterRefresh()
            }
            self.tableView.isHidden = true
            COMMON_FUNCTIONS.showAlert(msg: "Request Time Out!")
        }
    }
    
    //MARK: Search Logic
    func getDataAfterSearch(searchStr:String)  {
        
        searchedItemArray.removeAllObjects()
        for value in allItemsDataArray as! [ItemModel] {
            
            let titleString = value.title
            
            if  titleString.uppercased().contains( searchStr.uppercased())
            {
                self.searchedItemArray.add(value)
            }
        }
        
        if searchedItemArray.count == 0 || searchedItemArray.isEqual(nil) {
            self.noDataView.isHidden = false
        }
        else
        {
            self.noDataView.isHidden = true
        }
        self.tableView.reloadData()
    }
    
    
    //MARK: Selector
    
    @objc func itemInstructionViewNotificaionAction(notification: Notification)
    {
        
        self.blurV.isHidden = true
        if let userInfo = notification.userInfo
        {
            if let result = userInfo["isForEdit"] as? Bool {
                if result
                {
                    //                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddLaundryItemVC") as! AddLaundryItemVC
                    //                    viewController.itemDataDic = userInfo["item_data_dictionary"] as! NSMutableDictionary
                    //                    viewController.isForEditing = true
                    //                    self.present(viewController, animated: true, completion: nil)
                    //                    return
                    
                }
            }
            
        }
        
        basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
       
        self.tableView.reloadData()
    }
    
    func ifProductAlreadyInCart (productID: String?) -> (isMatched: Bool, count: Int, index: Int) {
        var result: Bool
        var count = 0
        _ = 0
        
        result = false
        
        for (index,value) in (productCartArray.enumerated()){
            let dic = value as! NSDictionary
            
            if (dic["id"] as? NSNumber)?.stringValue == productID
            {
                result = true
                count = dic.object(forKey: "quantity") as! Int
                return (result,count,index)
                
            }
            result = false
        }
        return (result,count,-1)
    }
    
    
    @objc func addButton(_ sender: UIButton?,event: AnyObject?){
        let touches: Set<UITouch>
        touches = (event?.allTouches!)!
        let touch:UITouch = (touches.first)!
        let touchPosition:CGPoint = touch.location(in: self.tableView)
        let indexPath:NSIndexPath = self.tableView.indexPathForRow(at: touchPosition)! as NSIndexPath
        let cell  = self.tableView.cellForRow(at: indexPath as IndexPath) as! ItemTableCellWithAddButton
        let itemModel = searchedItemArray[indexPath.row] as! ItemModel
      
        if (productCartArray.count) > 0 {
            let old_store_id = itemModel.store_id
            if store_id == old_store_id
            {
                print("Matched")
            }
            else
            {
                
                
                let alert = UIAlertController(title: "a_another_store_title".getLocalizedValue(), message: "a_another_store_desc".getLocalizedValue(), preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "z_yes".getLocalizedValue(), style: .default, handler: { (action) in
                    productCartArray.removeAllObjects()
                    self.basketButton.badgeValue = ""
                    if itemModel.variants.count > 0 //Variants   Exist
                    {
                        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PopUpVC") as! PopUpVC
                        viewController.itemModel = itemModel
                        self.view.bringSubview(toFront:  self.blurV)
                        self.blurV.isHidden = false
                        self.present(viewController, animated: true, completion: nil)
                    }
                    else
                    {
                        cell.addButton.isHidden = true
                        cell.plusButton.isEnabled = true
                        cell.totalQuantityLbl.text = "1"
                        itemModel.variants = NSMutableArray.init()
                        itemModel.quantity = "1"
                        productCartArray.add(itemModel)
                    }
                    
                    if  COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "0"{
                        self.basketButton.badgeValue = ""
                    }
                    else
                    {
                        self.basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
                    }

                }))
             
                alert.addAction(UIAlertAction(title: "z_no".getLocalizedValue(), style: .destructive, handler: { (action) in
                    return
                }))
                let popPresenter = alert.popoverPresentationController
                popPresenter?.sourceView = self.view
                popPresenter?.sourceRect = self.view.bounds
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        
        if itemModel.variants.count > 0 //Variants   Exist
        {
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PopUpVC") as! PopUpVC
            
            viewController.itemModel = itemModel
            self.view.bringSubview(toFront:  self.blurV)
            self.blurV.isHidden = false
            self.present(viewController, animated: true, completion: nil)
            
        }
        else
        {
            
            cell.addButton.isHidden = true
            cell.plusButton.isEnabled = true
            cell.totalQuantityLbl.text = "1"
            itemModel.variants = NSMutableArray.init()
            itemModel.quantity = "1"
            productCartArray.add(itemModel)
        }
        
        basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
       
    }
    
    //MARK: Plus Button
    
    @objc func plusButton(_ sender: UIButton?,event: AnyObject?) {
        let touches: Set<UITouch>
        touches = (event?.allTouches!)!
        let touch:UITouch = (touches.first)!
        let touchPosition:CGPoint = touch.location(in: self.tableView)
        let indexPath:NSIndexPath = self.tableView.indexPathForRow(at: touchPosition)! as NSIndexPath
        let cell  = self.tableView.cellForRow(at: indexPath as IndexPath) as! ItemTableCellWithAddButton
        let itemModel = searchedItemArray[indexPath.row] as! ItemModel
        if itemModel.variants.count > 0 //Variants Not Exist
        {
            let viewController: PopUpVC = self.storyboard?.instantiateViewController(withIdentifier: "PopUpVC") as! PopUpVC
            viewController.itemModel = itemModel
            self.view.bringSubview(toFront:  self.blurV)
            self.blurV.isHidden = false
            // let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
            self.present(viewController, animated: true, completion: nil)
            print("Product Cart Array = \(productCartArray)")
            return
        }
        else
        {
            let item_id = itemModel.id
            
            var (matched,quantity,index) = COMMON_FUNCTIONS.ifProductAlreadyInCart(productID: item_id)
            
            if matched
            {
                quantity += 1
                let tmpItemModel = (productCartArray[index] as! ItemModel)
                tmpItemModel.quantity = String(quantity)
                productCartArray.replaceObject(at: index, with: tmpItemModel)
            }
            cell.totalQuantityLbl.text = "\(COMMON_FUNCTIONS.cartItemCount(productID: item_id))"
            basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
        }
        
    }
    
    //MARK: Minus Button
    
    @objc func minusButton(_ sender: UIButton?,event: AnyObject?) {
        
        let touches: Set<UITouch>
        touches = (event?.allTouches!)!
        let touch:UITouch = (touches.first)!
        let touchPosition:CGPoint = touch.location(in: self.tableView)
        let indexPath:NSIndexPath = self.tableView.indexPathForRow(at: touchPosition)! as NSIndexPath
        let cell  = self.tableView.cellForRow(at: indexPath as IndexPath) as! ItemTableCellWithAddButton
        let itemModel = searchedItemArray[indexPath.row] as! ItemModel
        
        if itemModel.variants.count > 0 //Variants   Exist
        {
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
            self.navigationController?.pushViewController(viewController, animated: true)
            
        }
        else
        {
            let itemId = itemModel.id
            var (isMatched,itemCount,index) = COMMON_FUNCTIONS.ifProductAlreadyInCart(productID: itemId)
            
            if  isMatched == true{
                let tmpItemModel = (productCartArray.object(at: index) as! ItemModel)
                itemCount -= 1
                if itemCount < 1
                {
                    
                    productCartArray.removeObject(at: index)
                    cell.addButton.layer.borderWidth = 1
                    cell.addButton.layer.cornerRadius = 4
                    cell.addButton.layer.borderColor = MAIN_COLOR.cgColor
                    cell.plusButton.isEnabled = false
                    cell.addButton.isHidden = false
                    
                }
                else
                {
                    tmpItemModel.quantity = String(itemCount)
                    productCartArray.replaceObject(at: index, with: tmpItemModel)
                    cell.plusButton.isEnabled = true
                    cell.addButton.isHidden = true
                }
            }
            if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "0"
            {
                self.basketButton.badgeValue = ""
            }
            else
            {
              self.basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
            }
            
            cell.totalQuantityLbl.text = String(COMMON_FUNCTIONS.cartItemCount(productID: itemId))
        }
        
    }
    
    
}
extension SearchItemVC : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        print(newString)
        CallApi(search_string: newString, page: 1)
        return true
        
    }
}

extension SearchItemVC: UITableViewDelegate,UITableViewDataSource
{
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.searchedItemArray.count > 0
        {
            return searchedItemArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableCellWithAddButton", for: indexPath) as! ItemTableCellWithAddButton
        let itemModel = searchedItemArray[indexPath.row] as! ItemModel
        
        let imageUrl = URL(string: IMAGE_BASE_URL + "item/" + itemModel.thumb_photo)
        
        cell.itemImageV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "empty_item"), options: .refreshCached, completed: nil)
        cell.itemNameLbl.text = itemModel.title
        let item_id = itemModel.id
        
        cell.itemPriceLbl.text = "\(currency_type) \(itemModel.price)"
        let (matched,_,_) = COMMON_FUNCTIONS.ifProductAlreadyInCart(productID: item_id)
        
        if matched{
            cell.addButton.isHidden = true
            cell.totalQuantityLbl.text = COMMON_FUNCTIONS.getTheTotalQuantityOfProductWithId(p_id: item_id)
            //  cell.totalQuantityLbl.text = String(COMMON_FUNCTIONS.cartItemCount(productID: item_id.stringValue))
        }
        else
        {
            cell.addButton.isHidden = false
        }
        
        let itemStatus = itemModel.active_status
        if itemStatus == "0"
        {
            cell.quantityView.isHidden = true
            cell.itemStatusView.isHidden = false
            cell.itemNotAvailableV.layer.cornerRadius = 2
            cell.itemNotAvailableV.layer.borderWidth = 1
            cell.itemNotAvailableV.layer.borderColor = UIColor.lightGray.cgColor
        }
        else
        {
            cell.quantityView.isHidden = false
            cell.itemStatusView.isHidden = true
            
        }
        let unit = itemModel.unit
        
        if !unit.isEmpty {
            cell.itemCategoryLbl.text = unit
            cell.itemCategoryLbl.isHidden = false
        }
        else
        {
            cell.itemCategoryLbl.isHidden = true
            cell.itemCategoryLbl.text = ""
        }
        
        cell.addButton.tag = indexPath.row
        cell.plusButton.tag = indexPath.row
        cell.addButton.addTarget(self, action: #selector(addButton(_:event:)), for: UIControlEvents.touchUpInside)
        cell.minusButton.addTarget(self, action: #selector(minusButton(_:event:)), for: UIControlEvents.touchUpInside)
        cell.plusButton.addTarget(self, action: #selector(plusButton(_:event:)), for: UIControlEvents.touchUpInside)
        cell.selectionStyle = .none
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorView.isHidden = true
        }
        
        return cell
        
        
    }
   
}
