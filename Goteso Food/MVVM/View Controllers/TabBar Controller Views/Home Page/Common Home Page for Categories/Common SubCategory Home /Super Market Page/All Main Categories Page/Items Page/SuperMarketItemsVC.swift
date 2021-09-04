//
//  SuperMarketItemsVC.swift
//  My MM
//
//  Created by Kishore on 18/12/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import CRRefresh
import Shimmer
import NotificationCenter
import MaterialComponents.MaterialBottomSheet

class SuperMarketItemsVC: UIViewController {
    
var refreshControl = UIRefreshControl()
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBAction func filterButton(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ItemsSortAndFilterVC") as! ItemsSortAndFilterVC
        let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
        let size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height - 80)
        bottomSheet.contentViewController.preferredContentSize = size
        self.present(bottomSheet, animated: true, completion: nil)    }
    
    @IBAction func viewBasketButton(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBOutlet weak var serverErrorView: UIView!
    
    @IBOutlet weak var noDataFoundLbl: UILabel!
    @IBOutlet weak var yourBasketLbl: UILabel!
    @IBOutlet weak var viewBasketButton: UIButton!
    @IBOutlet weak var numberOfCartItemsLbl: UILabel!
    @IBOutlet weak var blurV: UIView!
    @IBOutlet weak var noDataView: UIView!
    var selectedIndex = 0
    var categoryTitleDataArray = NSMutableArray.init()
    var mainCategoryModel = MainCategoryModel()
    var allItemsDataArray = NSMutableArray.init()
    var currentPage = 1
    var total_page = 0
    var to_page = 0
    var shimmerView:FBShimmeringView!
    var isShimmerOn = true
    var segmentedControl1: ZSegmentedControl!
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func basketButton(_ sender: CustomBadgeButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBOutlet weak var basketButton: CustomBadgeButton!
    @IBAction func searchButton(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchItemVC") as! SearchItemVC
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
        
    }
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noDataFoundLbl.text = "e_item_title".getLocalizedValue()
        yourBasketLbl.text = "y_items_basket".getLocalizedValue()
        if Language.isRTL {
            numberOfCartItemsLbl.textAlignment = .left
        }
        else
        {
            numberOfCartItemsLbl.textAlignment = .right
        }
        
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        let nib = UINib(nibName: "ItemTableCellWithAddButton", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ItemTableCellWithAddButton")
        let subCategoryModel = mainCategoryModel.subCategories[selectedIndex]
        getItemsDataAPI(category_id: subCategoryModel.id, loader: false, page: 1)
        self.tableView.tableFooterView = UIView(frame: .zero)
         NotificationCenter.default.addObserver(self, selector: #selector(itemInstructionViewNotificaionAction(notification:)), name: NSNotification.Name.init("itemInstructionNotificaion"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(filterNotification(notification:)), name: NSNotification.Name?.init(NSNotification.Name.init("itemFilterNotification")), object: nil)
        self.titleLbl.text = mainCategoryModel.title
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        self.addRefreshFunctionality()
        tableView.addSubview(refreshControl)
        tableView.estimatedRowHeight = 50
        addRefreshFunctionality()
        for value in mainCategoryModel.subCategories {
            categoryTitleDataArray.add(value.title)
        }
        self.filterButton.isHidden = true
        setupForSegmentedControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
          self.filterButton.isHidden = true
        if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "0" {
            self.bottomViewHeight.constant = 0
        }
        else
        {
            self.bottomViewHeight.constant = 44
        }
       self.tableView.reloadData()
        if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "0" {
            basketButton.badgeValue = ""
        }
        else
        {
            basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
        }
        if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "1"
        {
            self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_item".getLocalizedValue()
        }
        else
        {
            self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_items".getLocalizedValue()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    //MARK: -Add Pull To Down and Pull To Up Refresh
    func addRefreshFunctionality()  {
        
//        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
//            self?.getItemsDataAPI(category_id: category_id, loader: false, page: 1)
//            self?.tableView.cr.resetNoMore()
//        }
//
        tableView.cr.addFootRefresh(animator: NormalFooterAnimator()) {
            [weak self] in
            let category_id = self!.mainCategoryModel.subCategories[self!.selectedIndex].id
            if (self?.to_page)! == (self?.total_page)!
            {
                self?.tableView.cr.noticeNoMoreData()
                return
            }
             self?.getItemsDataAPI(category_id: category_id, loader: false, page: (self?.currentPage)!)
           
        }
    }
    
    //MARK: Get All Items
    
    func getItemsDataAPI(category_id:String,loader:Bool,page:Int)  {
        let api_name = APINAME().ITEM_API + "?page=\(page)&category=\(category_id)"
        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: loader, success: { (response) in
            print(response)
            
             
            
            
            
            if response["status_code"] as! NSNumber == 1
            {
                self.isShimmerOn = false
                self.tableView.isScrollEnabled = true
                self.noDataView.isHidden = true
                
                if page == 1
                {
                    
                    self.allItemsDataArray.removeAllObjects()
                    self.currentPage = 1
                }
                
               let dataArray = ((response["data"] as! NSDictionary).object(forKey: "data") as! NSArray)
                
                if dataArray.count == 0
                {
                    self.noDataView.isHidden = false
                    self.tableView.reloadData()
                    self.tableView.cr.endHeaderRefresh()
                    self.tableView.cr.endFooterRefresh()
                    
                    return
                }
                
                self.total_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "total") as! NSNumber)
                self.to_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "to") as! NSNumber)
                
                for subCategoryItems in dataArray as! [NSDictionary]
                {
                    let itemModel = ItemModel()
                    itemModel.id = COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_id"] as AnyObject).1
                    itemModel.title = COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_title"] as AnyObject).1
                    itemModel.price = COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_price"] as AnyObject).1
                    itemModel.discount = COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_discount"] as AnyObject).1
                    itemModel.item_stock_count = COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_stock_count"] as AnyObject).1
                    itemModel.store_id = COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["store_id"] as AnyObject).1
                    itemModel.active_status = COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_active_status"] as AnyObject).1
                    itemModel.unit = COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["unit"] as AnyObject).1
                   
                    itemModel.variants = ((subCategoryItems["variants"] as! NSArray).mutableCopy() as! NSMutableArray)
                   
                    itemModel.photo = COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["photo"] as AnyObject).1
                    itemModel.thumb_photo = COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["thumb_photo"] as AnyObject).1
                    itemModel.item_description = COMMON_FUNCTIONS.checkForNull(string: subCategoryItems["item_description"] as AnyObject).1
                    self.allItemsDataArray.add(itemModel)
                    
                }
                
                if (((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "next_page_url") as? String) != nil
                {
                    self.currentPage += 1
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                     self.refreshControl.endRefreshing()
                    //self.tableView.cr.endHeaderRefresh()
                    self.tableView.cr.endFooterRefresh()
                    
                }
                
            }
            else{
                
                if self.shimmerView.isShimmering
                {
                    self.shimmerView.isShimmering = false
                    self.isShimmerOn = false
                }
                self.allItemsDataArray.removeAllObjects()
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                // self.tableView.cr.endHeaderRefresh()
                self.tableView.cr.endFooterRefresh()
                self.noDataView.isHidden = false
                
            }
        }) { (failure) in
            
        }
        
        
    }
    
    
    
    //MARK: - Selector Methods//////////
    
    //MARK: Selectors
    
    
    @objc func tapGestureRecognization(_ sender: UITapGestureRecognizer?){
        
        let tag_value = sender?.view?.tag
        
        let viewController: ItemDetailsPopUpVC = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetailsPopUpVC") as! ItemDetailsPopUpVC
        viewController.item_id = String(format: "%i", tag_value!)
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        self.present(bottomSheet, animated: true, completion: nil)
        
    }
    
    @objc func refresh(_ sender:AnyObject) {
        self.tableView.cr.resetNoMore()
        let category_id =  mainCategoryModel.subCategories[selectedIndex].id
        self.getItemsDataAPI(category_id: category_id, loader: true, page: 1)
    }
    
    @objc func filterNotification(notification:Notification)
    {
        if notification.userInfo != nil {
            itemFilterURL = notification.userInfo!["url"] as! String
           
            isShimmerOn = true
             let category_id = mainCategoryModel.subCategories[selectedIndex].id
            self.getItemsDataAPI(category_id: category_id, loader: true, page: 1)
            
        }
    }
    
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
        
       
        if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "1"
        {
            self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_item".getLocalizedValue()
             basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
        }
        else
        {
            self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_items".getLocalizedValue()
             basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
        }
        if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "0" {
             basketButton.badgeValue = ""
            self.bottomViewHeight.constant = 0
        }
        else
        {
            self.bottomViewHeight.constant = 44
        }
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
    
    //MARK: Add Button
    
    @objc func addButton(_ sender: UIButton?,event: AnyObject?){
        let touches: Set<UITouch>
        touches = (event?.allTouches!)!
        let touch:UITouch = (touches.first)!
        let touchPosition:CGPoint = touch.location(in: self.tableView)
        let indexPath:NSIndexPath = self.tableView.indexPathForRow(at: touchPosition)! as NSIndexPath
        let cell  = self.tableView.cellForRow(at: indexPath as IndexPath) as! ItemTableCellWithAddButton
        let itemModel = (allItemsDataArray[indexPath.row] as! ItemModel)
        if (productCartArray.count) > 0 {
            let old_store_id = (productCartArray.object(at: 0) as! ItemModel).store_id
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
                    self.bottomViewHeight.constant = 0
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
                        self.bottomViewHeight.constant = 0
                    }
                    else if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "1" && self.bottomViewHeight.constant != 44
                    {
                         self.bottomViewHeight.constant = 44
                        self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_item".getLocalizedValue()
                        self.basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
                    }
                    else
                    {
                        self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_items".getLocalizedValue()
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
        
        if  COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "0" {
            basketButton.badgeValue = ""
            self.bottomViewHeight.constant = 0
        }
       else if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "1" && self.bottomViewHeight.constant != 44
        {
            self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_item".getLocalizedValue()
            basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
            self.bottomViewHeight.constant = 44
        }
        else
        {
            self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_items".getLocalizedValue()
            basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
        }
        
      
    }
    
    //MARK: Plus Button
    
    @objc func plusButton(_ sender: UIButton?,event: AnyObject?) {
        let touches: Set<UITouch>
        touches = (event?.allTouches!)!
        let touch:UITouch = (touches.first)!
        let touchPosition:CGPoint = touch.location(in: self.tableView)
        let indexPath:NSIndexPath = self.tableView.indexPathForRow(at: touchPosition)! as NSIndexPath
        let cell  = self.tableView.cellForRow(at: indexPath as IndexPath) as! ItemTableCellWithAddButton
        let itemModel = (allItemsDataArray[indexPath.row] as! ItemModel)
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
        let touchPosition:CGPoint = touch.location(in: self.tableView)
        let indexPath:NSIndexPath = self.tableView.indexPathForRow(at: touchPosition)! as NSIndexPath
        let cell  = self.tableView.cellForRow(at: indexPath as IndexPath) as! ItemTableCellWithAddButton
        let itemModel = (allItemsDataArray[indexPath.row] as! ItemModel)
        
        if itemModel.variants.count > 0 //Variants   Exist
        {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
            self.navigationController?.pushViewController(viewController, animated: true)
            
        }
        else
        {
            let itemId = itemModel.id
            var (isMatched,itemCount,index) = COMMON_FUNCTIONS.ifProductAlreadyInCart(productID: itemId)
            
            if  isMatched == true {
                let  tmpItemModel = (productCartArray.object(at: index) as! ItemModel)
                itemCount -= 1
                if itemCount < 1
                {
                    productCartArray.removeObject(at: index)
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
                self.bottomViewHeight.constant = 0
            }
            else if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "1" && self.bottomViewHeight.constant != 44
            {
                self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_item".getLocalizedValue()
                self.bottomViewHeight.constant = 44
                 
            }
            else
            {
                 self.numberOfCartItemsLbl.text = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() +  " " + "z_items".getLocalizedValue()
            }
            self.basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
            cell.totalQuantityLbl.text = String(COMMON_FUNCTIONS.cartItemCount(productID: itemId))
           
        }
        
    }
    
    //MARK: - Setup For TableView And Segment Control
    
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
        segmentedControl1 = ZSegmentedControl(frame: CGRect(x: 0, y: self.topView.frame.size.height + self.topView.frame.origin.y + extraHeight - 2, width: width, height: 40))
        segmentedControl1.textFont = UIFont(name: REGULAR_FONT, size: 16)!
        segmentedControl1.backgroundColor = .white
        segmentedControl1.textSelectedColor = MAIN_COLOR
        segmentedControl1.delegate = self
        segmentedControl1.setTitles(categoryTitleDataArray as! [String], style: .adaptiveSpace(20))
        segmentedControl1.setSilder(backgroundColor: MAIN_COLOR, position: .bottomWithHight(1), widthStyle: .adaptiveSpace(0))
        segmentedControl1.selectedIndex = selectedIndex
        self.view.addSubview(segmentedControl1)
    }
    
    
}

extension SuperMarketItemsVC: ZSegmentedControlSelectedProtocol {
    func segmentedControlSelectedIndex(_ index: Int, animated: Bool, segmentedControl: ZSegmentedControl) {
        let category_id = mainCategoryModel.subCategories[index].id  
        isShimmerOn = true
        selectedIndex = index
        self.tableView.cr.resetNoMore()
        self.getItemsDataAPI(category_id: category_id, loader: true, page: 1)
    }
}

extension SuperMarketItemsVC : UITableViewDataSource, UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
            let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
            headerView.backgroundColor = UIColor.white
            let infoLabel:UILabel = UILabel(frame: CGRect(x: 16, y: 14, width: self.view.frame.size.width - 32, height: 24))
           // infoLabel.font = UIFont(name: REGULAR_FONT, size: 16)
        
        infoLabel.font = UIFont(name: ITALIC, size: 16)
        if allItemsDataArray.count == 1 {
            infoLabel.text = "\(allItemsDataArray.count) " + " " + "z_item".getLocalizedValue()
        }
        else
        {
            infoLabel.text = "\(allItemsDataArray.count) " + " " + "z_items".getLocalizedValue()
        }
        
            infoLabel.textColor = UIColor.lightGray
            headerView.addSubview(infoLabel)
            return headerView
       
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if isShimmerOn
        {
            let deviceHeight = self.view.frame.size.height
            return  Int(deviceHeight / 72)
        }
        else
        {
            if allItemsDataArray.count > 0 {
                return allItemsDataArray.count
            }
        }
       
        return 0
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
        
        if let sm = shimmerView
        {
            sm.isShimmering = false
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableCellWithAddButton", for: indexPath) as! ItemTableCellWithAddButton
        let itemModel = allItemsDataArray[indexPath.row] as! ItemModel
     //   DispatchQueue.main.async {
        
       //}
        let imageUrl =  URL(string: IMAGE_BASE_URL + "item/" + itemModel.thumb_photo)
        cell.itemImageV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "empty_item"), options: .refreshCached, completed: nil)
        cell.itemNameLbl.text =  itemModel.title
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
        else
        {
            cell.separatorView.isHidden = false
        }
         cell.setLabelHeight(string: itemModel.title)
        return cell
        
    }
    func heightForLabel(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
}
