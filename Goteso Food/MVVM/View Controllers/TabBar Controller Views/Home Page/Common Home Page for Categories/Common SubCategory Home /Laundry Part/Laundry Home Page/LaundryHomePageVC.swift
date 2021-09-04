//
//  LaundryHomePageVC.swift
//  My MM
//
//  Created by Kishore on 15/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import SDWebImage
import Shimmer
import CRRefresh
import CoreLocation
import MaterialComponents.MaterialBottomSheet

class LaundryHomePageVC: UIViewController,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var blurV: UIView!
      var titleScrollView : UIScrollView!
      var titleButtonsArray = NSMutableArray.init()
      var isForScrolling = true
    var segmentedControl1: ZSegmentedControl!

    @IBOutlet weak var serverErrorView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBAction func backButton(_ sender: UIButton) {
        if backButton.isHidden {
            return
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    @IBOutlet weak var skipSelectionLbl: UILabel!
    
    @IBOutlet weak var yourCartLbl: UILabel!
    @IBOutlet weak var backButtonWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var numberOfCartItemsLbl: UILabel!
    
    @IBOutlet weak var noDataFoundLbl: UILabel!
    @IBAction func searchButton(_ sender: UIButton) {
    }
    @IBAction func basketButton(_ sender: CustomBadgeButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var basketButton: CustomBadgeButton!
    @IBOutlet weak var pageTitleLbl: UILabel!
    @IBOutlet weak var viewCartV: UIView!
    var timer : Timer!
    
    var scrolViewHeight : CGFloat = 0
    
    var storeModel = StoreModel()
    var isImagesSet = false
     let userDefaults = UserDefaults.standard
    var isShimmerOn = true
    var shimmerView:FBShimmeringView!
     var scrollView: UIScrollView!
    var tableCategoryArray:NSMutableArray!
   
    var allItemsDataArray: NSMutableArray!
    var selectedCategory:Int!
  
    var selectedCategoryId : String?
    var selectedCategoryName : String?
    
    
    var images_url_array = NSMutableArray.init()
    
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var shimmerTableView: UITableView!
    
    @IBAction func viewBasketButton(_ sender: UIButton) {
        
        if self.skipSelectionLbl.isHidden {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
            store_name = storeModel.store_title
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else
        {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CheckOutVC") as! CheckOutVC
            viewController.total_amount = "0.00"
            viewController.sub_total = "0.00"
            viewController.paymentSummaryDataDic = NSMutableDictionary.init()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
       
    }
    @IBOutlet weak var viewBasketButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noDataFoundLbl.text = "e_item_title".getLocalizedValue()
        yourCartLbl.text = "y_items_basket".getLocalizedValue()
        skipSelectionLbl.text = "z_skip_selection".getLocalizedValue()
        if Language.isRTL {
            numberOfCartItemsLbl.textAlignment = .left
        }
        else
        {
            numberOfCartItemsLbl.textAlignment = .right
        }
       
        if storeModel.store_id.isEmpty {
            storeModel.store_id = store_id
            storeModel.store_title = store_name
        }
        else
        {
            store_name = storeModel.store_title
            store_id = storeModel.store_id
        }
      
        self.isShimmerOn = true
     
 
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.tableCategoryArray = NSMutableArray.init()
        self.allItemsDataArray = NSMutableArray.init()
        selectedCategory = 0
        self.searchView.layer.cornerRadius = 12
        self.navigationController?.isNavigationBarHidden = true
        self.shimmerTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
        self.shimmerTableView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(itemInstructionViewNotificaionAction(notification:)), name: NSNotification.Name.init("itemInstructionNotificaion"), object: nil)
        //getLocalJSON()
        
        self.pageTitleLbl.text = store_name
        
        self.CallApi()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.bringSubview(toFront: viewCartV)
         self.bottomViewHeight.constant = 44
        if productCartArray.count == 0 && app_type == "laundry" {
            self.skipSelectionLbl.isHidden = false
        }
        else
        {
             self.skipSelectionLbl.isHidden = true
        }
            
        
        if basketButton != nil {
            if productCartArray.count > 0
            {
                basketButton.badgeValue = "\(COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart())"
            }
            else
            {
                basketButton.badgeValue = ""
                
            }
        }
        if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "1"
        {
            self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() + " " + "z_item".getLocalizedValue()
        }
        else
        {
            self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_items".getLocalizedValue()
        }
        
        shimmerTableView.reloadData()
     print(storeModel)
      if storeTypeCode == "00"  {
        
            if app_type == "laundry"
            {
                self.backButtonWidthConstraints.constant = 44
                self.tabBarController?.tabBar.isHidden = true
                self.backButton.isHidden = false
            }
            else
            {
                self.backButtonWidthConstraints.constant = 0
                self.tabBarController?.tabBar.isHidden = false
                self.backButton.isHidden = true 
            }
        
       
        }
        else
        {
            self.backButtonWidthConstraints.constant = 44
            self.tabBarController?.tabBar.isHidden = true
            self.backButton.isHidden = false
            
        }
        self.pageTitleLbl.text = storeModel.store_title
        if app_type != "laundry" {
            self.skipSelectionLbl.isHidden = true
        }
        else
        {
            if productCartArray.count > 0
            {
                self.skipSelectionLbl.isHidden = true
            }
            else
            {
                self.skipSelectionLbl.isHidden = false
            }
        }
        
        
    }
    
    
    //MARK: -Add Pull To Down and Pull To Up Refresh
    func addRefreshFunctionality()  {
        
        
                shimmerTableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
                    self?.CallApi()
             
        }
        
    }
    
    //MARK: Call API
    
    func CallApi() -> Void{
         var api_name = ""
        if storeModel.store_id.isEmpty {
            api_name = APINAME().CATEGORY_API + "?include_subcategories=true&include_empty_categories=false&include_items=true&store_id=\(store_id)"
        }
        else
        {
            api_name = APINAME().CATEGORY_API + "?include_subcategories=true&include_empty_categories=false&include_items=true&store_id=\(storeModel.store_id)"
        }
        
        
        
        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: false, success: { (response) in
            self.allItemsDataArray.removeAllObjects()
            self.tableCategoryArray.removeAllObjects()
           
            print(response)
            
            
            
            if response["status_code"] as! NSNumber == 1
            {
                self.isShimmerOn = false
                let dataArray = (response["data"] as! NSArray)
                if dataArray.count > 0
                {
                    
                    
                        self.shimmerTableView.cr.endHeaderRefresh()
                    
                        for (mainIndex,mainCategory) in (dataArray as!  [NSDictionary]).enumerated()
                        {
                                let mainCategoryModel = MainCategoryModel()
                                mainCategoryModel.id = COMMON_FUNCTIONS.checkForNull(string: mainCategory["category_id"] as AnyObject).1
                                mainCategoryModel.title = COMMON_FUNCTIONS.checkForNull(string: mainCategory["category_title"] as AnyObject).1
                                mainCategoryModel.photo = COMMON_FUNCTIONS.checkForNull(string: mainCategory["category_photo"] as AnyObject).1
                                mainCategoryModel.status = COMMON_FUNCTIONS.checkForNull(string: mainCategory["status"] as AnyObject).1
                                mainCategoryModel.main_category_description = COMMON_FUNCTIONS.checkForNull(string: mainCategory["description"] as AnyObject).1
                            var subCategories = [SubCategoryModel]()
                            
                            for  subcategory in (mainCategory["subcategories"] as! [NSDictionary])
                            {
                                 let subCategoryModel = SubCategoryModel()
                                
                                    subCategoryModel.id = COMMON_FUNCTIONS.checkForNull(string: subcategory["category_id"] as AnyObject).1
                                    subCategoryModel.title = COMMON_FUNCTIONS.checkForNull(string: subcategory["category_title"] as AnyObject).1
                                    subCategoryModel.parent_id = COMMON_FUNCTIONS.checkForNull(string: subcategory["parent_id"] as AnyObject).1
                                    subCategoryModel.store_id = COMMON_FUNCTIONS.checkForNull(string: subcategory["store_id"] as AnyObject).1
                                    subCategoryModel.photo = COMMON_FUNCTIONS.checkForNull(string: subcategory["category_photo"] as AnyObject).1
                                    subCategoryModel.status = COMMON_FUNCTIONS.checkForNull(string: subcategory["status"] as AnyObject).1
                                    subCategoryModel.sub_category_description = COMMON_FUNCTIONS.checkForNull(string: subcategory["description"] as AnyObject).1
                                 var items = [ItemModel]()
                                for  subCategoryItems in (subcategory["items"] as! [NSDictionary])
                                {
                                     let itemModel = ItemModel(id: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_id"] as AnyObject).1, title: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_title"] as AnyObject).1, thumb_photo: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["thumb_photo"] as AnyObject).1, photo: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["photo"] as AnyObject).1, discount: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_discount"] as AnyObject).1, store_id: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["store_id"] as AnyObject).1, item_description: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_description"] as AnyObject).1, quantity: "0", price: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_price"] as AnyObject).1, item_price_single: "0", item_price_total: "0", unit: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["unit"] as AnyObject).1, active_status: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_active_status"] as AnyObject).1, item_stock_count: COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_stock_count"] as AnyObject).1, variants: ((subCategoryItems["variants"] as! NSArray).mutableCopy() as! NSMutableArray), selectedVariants: NSMutableArray())
                                    
                                    items.append(itemModel)
                                   // items[itemIndex] = itemModel
                                    
                                }
                                subCategoryModel.items = items
                                subCategories.append(subCategoryModel)
                              //  subCategories[subIndex] = subCategoryModel
                            }
                            mainCategoryModel.subCategories = subCategories
                          
                            self.allItemsDataArray[mainIndex] = mainCategoryModel
                        }
                        
                    
                        for value in (self.allItemsDataArray as! [MainCategoryModel])
                        {
                            
                            self.tableCategoryArray.add(value.title)
                        }
                    if Language.isRTL
                    {
                        self.setupForSegmentedControl()
                    }
                    else
                    {
                        self.setupForTableViewAndSegmentedControl()
                    }
                       // self.setupForTableViewAndSegmentedControl()
                        //self.setupForTableViewAndScrollView()
                        
                     
                    
                }
                    
                else
                {
                    self.allItemsDataArray.removeAllObjects()
                    
                    self.view.bringSubview(toFront: self.noDataView)
                    self.noDataView.isHidden = false
                }
                
                print("array is ",self.allItemsDataArray)
            }
            else
            {
       
                self.view.bringSubview(toFront: self.noDataView)
                self.noDataView.isHidden = false
            }
            
            
        }) { (failure) in
            
                self.shimmerTableView.cr.endHeaderRefresh()
           
        
            COMMON_FUNCTIONS.showAlert(msg: "Request Time Out!")
        }
    }
    
    
    @objc func imagesSetAction(_:Timer)
    {
        isImagesSet = true
        CallApi()
    }
    
    
    //MARK : Resize Image
    func resizeImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat) -> UIImage {
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    
    //MARK: -TableView Methods /////////////////////
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isShimmerOn
        {
            return 1
        }
        else
        {
            if self.allItemsDataArray.count > 0
            {
                
                if ((self.allItemsDataArray[selectedCategory] as! MainCategoryModel).subCategories).count > 0
                {
                    print("Selected Category = \(String(describing: selectedCategory))")
                    return ((self.allItemsDataArray[selectedCategory] as! MainCategoryModel).subCategories).count
                }
            }
        }
        self.view.bringSubview(toFront: self.noDataView)
        self.noDataView.isHidden = false
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShimmerOn
        {
            let deviceHeight = self.view.frame.size.height
            return  Int(deviceHeight / 80)
        }
        if allItemsDataArray.count > 0 {
            
            
            let sub_category_dic = (((self.allItemsDataArray[selectedCategory] as! MainCategoryModel).subCategories)[section])
            print(sub_category_dic)
            if sub_category_dic.id.isNotEmpty
            {
                let items_array = sub_category_dic.items
               
                if items_array.count > 0
                {
                    self.view.bringSubview(toFront: tableView)
                    self.noDataView.isHidden = true
                    print("count = \(items_array.count)")
                    return items_array.count
                }
            }
        }
        //        self.view.bringSubview(toFront: self.noDataView)
        //         self.noDataView.isHidden = false
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.allItemsDataArray.count == 0 {
            return 0
        }
        else
        {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if self.allItemsDataArray.count == 0 {
            return UIView(frame: .zero)
        }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        headerView.backgroundColor = .white
        let titleLbl = UILabel(frame: CGRect(x: 16, y: 10, width: self.view.frame.size.width - 32, height: 20))
       
        
            if selectedCategory > self.allItemsDataArray.count
            {
                return nil
            }
            let dataDic = (((self.allItemsDataArray[selectedCategory] as! MainCategoryModel).subCategories)[section])
            print((dataDic.title))
            titleLbl.text = dataDic.title
        
        titleLbl.textColor = MAIN_COLOR
        titleLbl.font = UIFont(name: ITALIC, size: 16)
        headerView.addSubview(titleLbl)
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            return 30
        }
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 12))
        headerView.backgroundColor = UIColor.groupTableViewBackground
        return headerView
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        return UITableViewAutomaticDimension
//
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isShimmerOn
        {
            let nib1 = UINib(nibName: "ShimmerTableCell", bundle: nil)
            tableView.register(nib1, forCellReuseIdentifier: "ShimmerTableCell")
            let cell = tableView.dequeueReusableCell(withIdentifier:"ShimmerTableCell") as! ShimmerTableCell
            shimmerView = FBShimmeringView(frame: cell.frame)
            shimmerView.contentView = cell
            shimmerView.isShimmering = true
            return cell
        }
        else
        {
            
            let nib = UINib(nibName: "ItemTableCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "ItemTableCell")
            let cell  = tableView.dequeueReusableCell(withIdentifier: "ItemTableCell") as! ItemTableCell
            
            var itemModel : ItemModel!
            cell.customizedButtonHeight.constant = 0
            
                print(self.allItemsDataArray)
               itemModel = ((((self.allItemsDataArray[selectedCategory] as! MainCategoryModel).subCategories)[indexPath.section]).items[indexPath.row])
            
            print(itemModel)
          //  DispatchQueue.main.async {
            
           // }
            let imageUrl = URL(string: IMAGE_BASE_URL + "item/" + itemModel.thumb_photo)
            cell.itemImageV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "empty_item"), options: .refreshCached, completed: nil)
            cell.itemNameLbl.text = itemModel.title
            let item_id = itemModel.id
          
            cell.itemImageV.isUserInteractionEnabled = true
            cell.itemImageV.tag = Int(itemModel.id)!
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognization(_:)))
            cell.itemImageV.addGestureRecognizer(tapGestureRecognizer)
            cell.itemPriceLbl.text = "\(currency_type) \(itemModel.price)"
            let (matched,_,_) = COMMON_FUNCTIONS.ifProductAlreadyInCart(productID: item_id)
            
            if matched{
                cell.addButton.isHidden = true
                cell.totalQuantityLbl.text = COMMON_FUNCTIONS.getTheTotalQuantityOfProductWithId(p_id: item_id)
                
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
                
                cell.itemStatusView.isHidden = true
                cell.quantityView.isHidden = false
            }
            
            cell.setInstructionsButton.isHidden = true
            let unit = itemModel.unit
            if !unit.isEmpty {
                cell.itemCategoryLbl.text = unit
                cell.unitLblHeightConstraint.constant = 17.0
               
            }
            else
            {
                cell.itemCategoryLbl.text = ""
                cell.unitLblHeightConstraint.constant = 0.0
              
            }
             cell.itemCategoryLbl.isHidden = false
            cell.addButton.tag = indexPath.row
            cell.plusButton.tag = indexPath.row
            cell.setInstructionsButton.tag = indexPath.row
            cell.addButton.addTarget(self, action: #selector(addButton(_:event:)), for: UIControlEvents.touchUpInside)
            cell.addMItemsButton.addTarget(self, action: #selector(addMItemsButton(_:event:)), for: UIControlEvents.touchUpInside)
            cell.minusButton.addTarget(self, action: #selector(minusButton(_:event:)), for: UIControlEvents.touchUpInside)
            cell.plusButton.addTarget(self, action: #selector(plusButton(_:event:)), for: UIControlEvents.touchUpInside)
            cell.selectionStyle = .none
            cell.separatorView.isHidden = true
             cell.setLabelHeight(string: itemModel.title)
         
            //cell.itemTitleHeightConstraint.constant = cell.itemNameLbl.optimalHeight + 10
            return cell
        }
    }
    
  
    //MARK: Change Table View Height
//
//    func changeTableViewLayout(height: CGFloat)  {
//
//        selectedTableView = (tableViewArray?.object(at: selectedCategory) as! UITableView)
//        selectedTableView.frame = CGRect(x: selectedTableView.frame.origin.x, y: selectedTableView.frame.origin.y, width: selectedTableView.frame.size.width, height: height)
//    }
    
    
    //MARK: - Selector Methods//////////
    
    @objc func tapGestureRecognization(_ sender: UITapGestureRecognizer?){
        
        let tag_value = sender?.view?.tag
        
        let viewController: ItemDetailsPopUpVC = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetailsPopUpVC") as! ItemDetailsPopUpVC
        viewController.item_id = String(format: "%i", tag_value!)
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        self.present(bottomSheet, animated: true, completion: nil)
        
    }
    
   
    
    @objc func itemInstructionViewNotificaionAction(notification: Notification)
    {
        
            
            if productCartArray.count == 0 {
                
              //  changeTableViewLayout(height: scrolViewHeight + 10)
                 self.skipSelectionLbl.isHidden = false
                //self.bottomViewHeight.constant = 0
                
            }
            else if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "1" && self.bottomViewHeight.constant != 44
            {
                basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
                self.skipSelectionLbl.isHidden = true
                self.bottomViewHeight.constant = 44
               
                self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_item".getLocalizedValue()
            }
            else
            {
                self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_items".getLocalizedValue()
            }
        shimmerTableView.reloadData()
         
        
        self.blurV.isHidden = true
        
        if productCartArray.count > 0 {
            if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "1"
            {
                self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_item".getLocalizedValue()
            }
            else
            {
                self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_items".getLocalizedValue()
            }
            
        }
        
        if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "0" {
           // self.bottomViewHeight.constant = 0
             self.skipSelectionLbl.isHidden = false
            basketButton.badgeValue = ""
        }
        else
        {
            basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
        }
        self.view.bringSubview(toFront: viewCartV)
        
        if app_type != "laundry" {
            self.skipSelectionLbl.isHidden = true
        }
        else
        {
            if productCartArray.count > 0
            {
                self.skipSelectionLbl.isHidden = true
            }
            else
            {
                self.skipSelectionLbl.isHidden = false
            }
        }
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
    
    //MARK: Add Button
    
    @objc func addMItemsButton(_ sender: UIButton?,event: AnyObject?){
        let touches: Set<UITouch>
        touches = (event?.allTouches!)!
        let touch:UITouch = (touches.first)!
        
        let touchPosition:CGPoint = touch.location(in: shimmerTableView)
        let indexPath:NSIndexPath = shimmerTableView.indexPathForRow(at: touchPosition)! as NSIndexPath
        let cell  = shimmerTableView.cellForRow(at: indexPath as IndexPath) as! ItemTableCell
        var dataDic : NSMutableDictionary!
        let sub_category_dic = (((self.allItemsDataArray[selectedCategory] as! NSDictionary)["subcategories"] as! NSArray)[indexPath.section] as! NSDictionary)
        let items_array = sub_category_dic["items"] as! NSArray
        dataDic = ((items_array[indexPath.row] as! NSDictionary).mutableCopy() as! NSMutableDictionary)
   
        
        if cell.addMItemsButton.currentTitle == "ADD" {
            cell.addMItemsButton.layer.borderColor = MAIN_COLOR.cgColor
            cell.addMItemsButton.setTitleColor(.white, for: .normal)
            cell.addMItemsButton.backgroundColor = MAIN_COLOR
            cell.addMItemsButton.setTitle("ADDED", for: .normal)
            dataDic.setObject(NSArray.init(), forKey: "variants" as NSCopying)
            dataDic.setObject(1, forKey: "quantity" as NSCopying)
            productCartArray.add(dataDic)
        }
        else
        {
            cell.addMItemsButton.setTitleColor(.black, for: .normal)
            cell.addMItemsButton.layer.borderColor = UIColor.black.cgColor
            cell.addMItemsButton.backgroundColor = .white
            cell.addMItemsButton.setTitle("ADD", for: .normal)
            let itemId = (dataDic.object(forKey: "item_id") as! NSNumber).stringValue
            let ( isMatched,_,index) = COMMON_FUNCTIONS.ifProductAlreadyInCart(productID: itemId)
            if  isMatched == true{
                productCartArray.removeObject(at: index)
            }
            cell.addMItemsButton.layer.borderWidth = 1
            
        }
        
        if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "1"
        {
            self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_item".getLocalizedValue()
        }
        else
        {
            self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_items".getLocalizedValue()
        }
        basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
        
    }
    
    
    @objc func addButton(_ sender: UIButton?,event: AnyObject?){
        let touches: Set<UITouch>
        touches = (event?.allTouches!)!
        let touch:UITouch = (touches.first)!
        
        let touchPosition:CGPoint = touch.location(in: shimmerTableView)
        let indexPath:NSIndexPath = shimmerTableView.indexPathForRow(at: touchPosition)! as NSIndexPath
        let cell  = shimmerTableView.cellForRow(at: indexPath as IndexPath) as! ItemTableCell
        var itemModel : ItemModel!
        
        
            itemModel = (((allItemsDataArray[selectedCategory] as! MainCategoryModel).subCategories[indexPath.section]).items[indexPath.row])
            
       
        
        if (productCartArray.count) > 0 {
            let old_store_id = (productCartArray.object(at: 0) as! ItemModel).store_id
            if storeModel.store_id == old_store_id
            {
                print("Matched")
            }
            else
            {
                
                let alert = UIAlertController(title: "a_another_store_title".getLocalizedValue(), message: "a_another_store_desc".getLocalizedValue(), preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "z_yes".getLocalizedValue(), style: .default, handler: { (action) in
                    productCartArray.removeAllObjects()
                    self.basketButton.badgeValue = ""
                    //self.bottomViewHeight.constant = 0
                    self.skipSelectionLbl.isHidden = false
                    self.addButtonData(itemModel: itemModel, cell: cell)
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
        
        addButtonData(itemModel: itemModel, cell: cell)
    }
    
    
    //ADD Button Function Data
    func addButtonData(itemModel:ItemModel, cell: ItemTableCell)   {
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
            cell.totalQuantityLbl.text = "1"
            self.skipSelectionLbl.isHidden = true
            itemModel.variants = NSMutableArray.init()
            itemModel.quantity = "1"
            if self.bottomViewHeight.constant == 0
            {
                if productCartArray.count == 0
                {
                    self.skipSelectionLbl.isHidden = true
                    self.bottomViewHeight.constant = 44
                   
                        self.view.bringSubview(toFront: self.viewCartV)
                    
                }
            }
            
            productCartArray.add(itemModel)
        }
        
        if productCartArray.count > 0 {
            if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "1"
            {
                self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_item".getLocalizedValue()
            }
            else
            {
                self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_items".getLocalizedValue()
            }
            
        }
        
        if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "0" {
            //self.bottomViewHeight.constant = 0
            self.skipSelectionLbl.isHidden = false
            self.basketButton.badgeValue = ""
        }
        else
        {
            self.basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
        }
    }
    
    //MARK: Plus Button
    
    @objc func plusButton(_ sender: UIButton?,event: AnyObject?) {
        let touches: Set<UITouch>
        touches = (event?.allTouches!)!
        let touch:UITouch = (touches.first)!
        
        let touchPosition:CGPoint = touch.location(in: shimmerTableView)
        let indexPath:NSIndexPath = shimmerTableView.indexPathForRow(at: touchPosition)! as NSIndexPath
        let cell  = shimmerTableView.cellForRow(at: indexPath as IndexPath) as! ItemTableCell
        var itemModel : ItemModel!
        
        
            itemModel = (((allItemsDataArray[selectedCategory] as! MainCategoryModel).subCategories[indexPath.section]).items[indexPath.row])
       
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
            if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "1"
            {
                self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_item".getLocalizedValue()
            }
            else
            {
                self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_items".getLocalizedValue()
            }
            basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
        }
        
    }
    
    //MARK: Minus Button
    
    @objc func minusButton(_ sender: UIButton?,event: AnyObject?) {
        
        let touches: Set<UITouch>
        touches = (event?.allTouches!)!
        let touch:UITouch = (touches.first)!
        
        let touchPosition:CGPoint = touch.location(in: shimmerTableView)
        let indexPath:NSIndexPath = shimmerTableView.indexPathForRow(at: touchPosition)! as NSIndexPath
        let cell  = shimmerTableView.cellForRow(at: indexPath as IndexPath) as! ItemTableCell
         var itemModel : ItemModel!
        
            print("Array Count = \(allItemsDataArray.count)")
            itemModel = (((allItemsDataArray[selectedCategory] as! MainCategoryModel).subCategories[indexPath.section]).items[indexPath.row])
        
        if itemModel.variants.count > 0 //Variants   Exist
        {
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
            self.navigationController?.pushViewController(viewController, animated: true)
            return
            
        }
        else
        {
            let itemId = itemModel.id
            var (isMatched,itemCount,index) = COMMON_FUNCTIONS.ifProductAlreadyInCart(productID: itemId)
            
            if  isMatched == true{
                let  tmpItemModel = (productCartArray.object(at: index) as! ItemModel)
                itemCount -= 1
                
                if itemCount < 1
                {
                    cell.setInstructionsButton.setTitle("Set Instructions", for: .normal)
                    productCartArray.removeObject(at: index)
                    cell.addButton.isHidden = false
                }
                else
                {
                    tmpItemModel.quantity = String(itemCount)
                    productCartArray.replaceObject(at: index, with: tmpItemModel)
                    cell.addButton.isHidden = true
                    
                }
                
            }
            if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "1"
            {
                self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_item".getLocalizedValue()
            }
            else
            {
                self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_items".getLocalizedValue()
            }
            
            if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "0"
            {
               // self.bottomViewHeight.constant = 0
                self.skipSelectionLbl.isHidden = false
                self.basketButton.badgeValue = ""
                
                   // changeTableViewLayout(height: scrolViewHeight + 10)
                
            }
            else
            {
                self.basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
            }
            cell.totalQuantityLbl.text = String(COMMON_FUNCTIONS.cartItemCount(productID: itemId))
        }
        if app_type != "laundry" {
            self.skipSelectionLbl.isHidden = true
        }
        
    }
    
    //MARK: - Setup For TableView And Segment Control
    func setupForTableViewAndSegmentedControl()  {
        
        let width = UIScreen.main.bounds.size.width
        segmentedControl1 = ZSegmentedControl(frame: CGRect(x: 0, y: topView.frame.size.height + topView.frame.origin.y + 0, width: width, height: 50))
        segmentedControl1.textFont = UIFont(name: REGULAR_FONT, size: 15)!
        segmentedControl1.backgroundColor = .white
        segmentedControl1.textSelectedColor = MAIN_COLOR
        segmentedControl1.delegate = self
        segmentedControl1.setTitles(tableCategoryArray as! [String], style: .adaptiveSpace(15))
        segmentedControl1.setSilder(backgroundColor: MAIN_COLOR, position: .bottomWithHight(2), widthStyle: .adaptiveSpace(18))
        // self.shimmerTableView.tableHeaderView = segmentedControl1
        self.view.addSubview(segmentedControl1)
        shimmerTableView.reloadData()
        DispatchQueue.main.async {
            self.view.bringSubview(toFront: self.viewCartV)
        }
        
    }
    
    func setupForSegmentedControl()  {
        
        let width = UIScreen.main.bounds.size.width
        var extraHeight : CGFloat
        if hasTopNotch {
            extraHeight = 25
        }
        else
        {
            extraHeight = 0
        }
        
        
        titleScrollView = UIScrollView(frame: CGRect(x: 0, y: self.topView.frame.size.height + self.topView.frame.origin.y + extraHeight - 2, width: width, height: 50))
        titleScrollView.showsHorizontalScrollIndicator = false
        titleScrollView.showsVerticalScrollIndicator = false
        titleScrollView.backgroundColor = .white
        if Language.isRTL {
              titleScrollView.semanticContentAttribute = .forceLeftToRight
        }
      
        titleScrollView.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        
        
        var scrollViewWidth : CGFloat = 0.0
        
        for (index,value) in (tableCategoryArray as! [String]).enumerated() {
            
            let bottomV = UIView()
            titleScrollView.addSubview(bottomV)
            bottomV.translatesAutoresizingMaskIntoConstraints = false
            let titleButton = UIButton()
            titleButton.translatesAutoresizingMaskIntoConstraints = false
            titleButton.setTitle(value , for: .normal)
            
            titleScrollView.addSubview(titleButton)
            if Language.isRTL
            {
                titleScrollView.semanticContentAttribute = .forceRightToLeft
            }
            else
            {
                titleScrollView.semanticContentAttribute = .forceLeftToRight
            }
            titleButton.tag = index
            if Language.isRTL
            {
                titleButton.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
            print(index)
            titleButton.addTarget(self, action: #selector(titleButtonAction(_:)), for: .touchUpInside)
            let btnWidth = getCustomeSizeOfString(str: value, font: UIFont(name: REGULAR_FONT, size: 15)!).width + 50
            
            
            if index == 0
            {
                print(titleScrollView.leadingAnchor)
                
                
                titleButton.trailingAnchor.constraint(equalTo: titleScrollView.leadingAnchor, constant: -15).isActive = true
                
                
                titleButton.centerYAnchor.constraint(equalTo: titleScrollView.centerYAnchor).isActive = true
                titleButton.widthAnchor.constraint(equalToConstant: btnWidth).isActive = true
                titleButton.heightAnchor.constraint(equalToConstant: titleScrollView!.frame.size.height - 4).isActive = true
                
                
            }
            else
            {
                
                let lastAddedButton = ((titleButtonsArray.lastObject as! NSDictionary)["button"] as! UIButton)
                
                
                titleButton.trailingAnchor.constraint(equalTo: lastAddedButton.leadingAnchor, constant: -15).isActive = true
                
                
                titleButton.centerYAnchor.constraint(equalTo: titleScrollView.centerYAnchor).isActive = true
                titleButton.widthAnchor.constraint(equalToConstant: btnWidth).isActive = true
                titleButton.heightAnchor.constraint(equalToConstant: titleScrollView!.frame.size.height - 4).isActive = true
                
            }
            
            if index == selectedCategory
            {
                titleButton.setTitleColor(MAIN_COLOR, for: .normal)
                
                bottomV.isHidden = false
            }
            else
            {
                titleButton.setTitleColor(UIColor.lightGray, for: .normal)
                bottomV.isHidden = true
            }
            bottomV.centerXAnchor.constraint(equalTo: titleButton.centerXAnchor).isActive = true
            bottomV.topAnchor.constraint(equalTo: titleButton.bottomAnchor, constant: 1).isActive = true
            bottomV.widthAnchor.constraint(equalToConstant: btnWidth).isActive = true
            bottomV.heightAnchor.constraint(equalToConstant: 1).isActive = true
            bottomV.backgroundColor = MAIN_COLOR
            bottomV.tag = titleButton.tag
            titleButtonsArray.add(NSDictionary(dictionaryLiteral: ("bottomV",bottomV),("button",titleButton)))
            
            scrollViewWidth += btnWidth + 15
            
        }
        
        if scrollViewWidth > width {
            titleScrollView.contentSize = CGSize(width: scrollViewWidth, height: titleScrollView.frame.size.height)
        }
        
        self.view.addSubview(titleScrollView)
        shimmerTableView.reloadData()
    }
    
    
    @objc func titleButtonAction( _ sender: UIButton)
    {
       // let category_id = mainCategoryModel.subCategories[sender.tag].id
      
        selectedCategory = sender.tag
        
        for (index,value) in (titleButtonsArray as! [NSDictionary]).enumerated() {
            
            let mutableData = (value.mutableCopy() as! NSMutableDictionary)
            let btn = (mutableData["button"] as! UIButton)
            let v = (mutableData["bottomV"] as! UIView)
            
            if sender.tag == (mutableData["button"] as! UIButton).tag
            {
                btn.setTitleColor(MAIN_COLOR, for: .normal)
                titleScrollView.scrollToView(view: btn, animated: true)
                v.isHidden = false
            }
            else
            {
                btn.setTitleColor(UIColor.lightGray, for: .normal)
                v.isHidden = true
            }
            
            mutableData.setObject(btn, forKey: "button" as NSCopying)
            mutableData.setObject(v, forKey: "bottomV" as NSCopying)
            titleButtonsArray.replaceObject(at: index, with: NSDictionary(dictionary: mutableData))
        }
        
        shimmerTableView.reloadData()
    }
    
    func getCustomeSizeOfString(str:String,font:UIFont) -> CGSize {
        
        let size = (str.size(withAttributes: [NSAttributedStringKey.font: UIFont(name: font.fontName , size: font.pointSize)!]))
        return size
        
    }
    
}

extension LaundryHomePageVC: ZSegmentedControlSelectedProtocol {
    func segmentedControlSelectedIndex(_ index: Int, animated: Bool, segmentedControl: ZSegmentedControl) {
        selectedCategory = index
        isForScrolling = false
        shimmerTableView.contentOffset = CGPoint(x: 0, y: 0)
        
        shimmerTableView.reloadData()
        
        if ((self.allItemsDataArray[selectedCategory] as! MainCategoryModel).subCategories).count > 0 {
        shimmerTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        self.view.bringSubview(toFront: viewCartV)
    }
}
