//
//  TimeSlotsVC.swift
//  My MM
//
//  Created by Kishore on 14/03/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class TimeSlotsVC: UIViewController {

    
    @IBOutlet weak var pageTitleLbl: UILabel!
    var isFirstScroll = true
    
    var numberOfTimeCell : CGFloat { if UIDevice.current.userInterfaceIdiom == .pad
    {   return 4    }
    else{        return 2 }
    }
    
    @IBOutlet weak var topView: UIView!
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var mainCollectionview: UICollectionView!
    var headerCollectionView : UICollectionView!
    var timeSlotsDataArray = NSMutableArray.init()
    var isForDeliveryTime = false
    var selectedIndex = 0
     var pickupDateForJson = ""
    
     @IBOutlet weak var serverErrorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageTitleLbl.text = "y_timeslots_title".getLocalizedValue()
        
        self.serverErrorView.isHidden = true
        mainCollectionview.register(UINib(nibName: "TimeSlotsCVCell", bundle: nil), forCellWithReuseIdentifier: "TimeSlotsCVCell")
        
      
        CallApi()
        // Do any additional setup after loading the view.
    }
   
    //MARK: -Call API
    func CallApi() -> Void{
        
        let dateFormat = DateFormatter()
        dateFormat.locale = Locale(identifier: "EN")
        dateFormat.dateFormat = "yyyy-MM-dd"
        var date = ""
        if isForDeliveryTime {
            date = selectedPickupDateForJSON
        }
        else
        {
            date = dateFormat.string(from: Date())
        }
        let apiName = APINAME().GET_TIME_SLOTS_LIST + "?from_date=\(date)&include_empty_date=false&timezone=\(localTimeZoneName)"
        
       WebService.requestGetUrl(strURL: apiName, params: NSDictionary.init(), is_loader_required: true, success: { (response) in
            print(response)
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
        
        
            if response["status_code"] as! NSNumber == 1
            {
                self.timeSlotsDataArray = ((response["data"] as! NSArray).mutableCopy() as! NSMutableArray)
                DispatchQueue.main.async {
                     self.mainCollectionview.collectionViewLayout.invalidateLayout()
                    self.mainCollectionview.reloadData()
                   
                }
                print("array is ",self.timeSlotsDataArray)
            }
        else
            {
                COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
                self.navigationController?.popViewController(animated: true)
        }
            
        }) { (failure) in
            
            self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
            

        }
        
        
    }
    
    
    
}

extension TimeSlotsVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.timeSlotsDataArray.count > 0 {
            if collectionView == headerCollectionView {
                return self.timeSlotsDataArray.count
            }
            else
            {
                return ((self.timeSlotsDataArray[selectedIndex] as! NSDictionary)["slots"] as! NSArray).count
            }
        }
        else
        {
            return 0
        }
    
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == headerCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectionCollectionCell", for: indexPath) as! SelectionCollectionCell
            
            let dataDic = (self.timeSlotsDataArray[indexPath.row] as! NSDictionary)
            cell.backV.layer.borderWidth = 1
            
            DispatchQueue.main.async {
                if indexPath.row == self.selectedIndex
                {
                    cell.backV.layer.borderColor = MAIN_COLOR.cgColor
                    cell.backV.backgroundColor = MAIN_COLOR
                    cell.selectionTypeLbl.textColor = .white
                }
                else
                {
                    cell.backV.layer.borderColor = UIColor.lightGray.cgColor
                    cell.backV.backgroundColor = .white
                    cell.selectionTypeLbl.textColor = .black
                }
            }
            
           
            cell.backV.layer.cornerRadius = 20
            cell.selectionTypeLbl.font = UIFont(name: SEMIBOLD, size: 14)
            cell.imageV.isHidden = true
            cell.selectionTypeLbl.text =   (dataDic.object(forKey: "display_title") as! String)  
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeSlotsCVCell", for: indexPath) as! TimeSlotsCVCell
             let dataDic = (((self.timeSlotsDataArray[selectedIndex] as! NSDictionary)["slots"] as! NSArray)[indexPath.row] as! NSDictionary)
            cell.grayView.layer.cornerRadius = 2
            cell.dateLbl.text = (dataDic["show_time"] as! String)
            return cell
        }
        
    }
    



    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if collectionView == headerCollectionView {
             return UICollectionReusableView.init()
        }

        mainCollectionview.register(UINib(nibName: "TimeSlotsCRV", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "TimeSlotsCRV")
        
        
        let headerView = mainCollectionview.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "TimeSlotsCRV", for: indexPath) as! TimeSlotsCRV
        headerCollectionView = headerView.headerCollectionView
         headerCollectionView.register(UINib(nibName: "SelectionCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SelectionCollectionCell")
       
        headerCollectionView.delegate = self
        headerCollectionView.dataSource = self
        headerCollectionView.reloadData()
        if Language.isRTL && self.isFirstScroll && timeSlotsDataArray.count > 0 {
            
                headerCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .right, animated: false)
           isFirstScroll = false
        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == mainCollectionview
        {
            return CGSize(width: self.view.frame.size.width, height: 110)
        }
        return CGSize.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if collectionView == headerCollectionView {
            return CGSize(width: 140, height: 60)
        }
        else
        {
            let width = (self.view.frame.size.width - 60)/numberOfTimeCell
            
          return CGSize(width: width, height: 50)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == headerCollectionView {
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == headerCollectionView {
            selectedIndex = indexPath.row
            headerCollectionView.reloadData()
            mainCollectionview.reloadData()
        }
        else
        {
             let dataDic = (self.timeSlotsDataArray[selectedIndex] as! NSDictionary)
            let timeSlotsDataDic = ((dataDic["slots"] as! NSArray)[indexPath.row] as! NSDictionary)
            
            if isForDeliveryTime {
            selectedTimeForDelivery = (timeSlotsDataDic["show_time"] as! String)
            selectedDeliveryDate =  (dataDic.object(forKey: "date") as! String) + ", " + selectedTimeForDelivery
            }
            else
            {
                selectedDeliveryDate = ""
                selectedTimeForDelivery = ""
                selectedPickupDate =  (dataDic.object(forKey: "date") as! String) + ", " + (timeSlotsDataDic["show_time"] as! String)
                selectedPickupDateForJSON = (dataDic.object(forKey: "date") as! String)
            }
            print(dataDic)
             self.navigationController?.popViewController(animated: true)
        }
        
    }
    
}


