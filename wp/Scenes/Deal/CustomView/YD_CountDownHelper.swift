//
//  YD_CountDownHelper.swift
//  TestCountDown
//
//  Created by J-bb on 17/2/9.
//  Copyright © 2017年 J-bb. All rights reserved.
//

import UIKit

class YD_CountDownHelper: NSObject {

    
    static let shared = YD_CountDownHelper()
    var timer:CADisplayLink?
    private var isCountDown = false
    weak var table:MyDealTableView?
    private override init() {}

    func countDown() {
        let cells = table?.visibleCells as? Array<DealListCell>
        guard cells != nil && cells!.count > 0 else {
            return
        }
        for cell in cells! {
            cell.refreshText()
        }
    }
    
    func countDownWithDealTableView(tableView:MyDealTableView) {
        tableView.reloadData()
        table = tableView
        
        perform(#selector(YD_CountDownHelper.start), with: nil, afterDelay: 1.0)
        
    }
    
    func getResidueCount(startTime:Int, totalCount:Int) -> Int {
        return  (startTime + totalCount) - Int(NSDate().timeIntervalSince1970)
    }
    func getTextWithStartTime(startTime:Int, totalCount:Int) -> String{
        
        let count = getResidueCount(startTime: startTime, totalCount: totalCount)
        
        return getTextWithTimeCount(timeCount: count)
    }
    func getTextWithTimeCount(timeCount:Int) -> String {
        
        let hours = timeCount / 3600
        let minutes = (timeCount % 3600) / 60
        let seconds = timeCount % 60
        return String(format: "%.2d:%.2d:%.2ds", hours, minutes, seconds)
    }
    
    func reStart() {
        guard table != nil else {
            return
        }
        table?.dataArray = DealModel.getAllPositionModel()
       table?.reloadData()
        if timer != nil {
            start()
        }
    }
    
    func start() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        timer = CADisplayLink(target: self, selector: #selector(countDown))
        timer?.frameInterval = 60
        timer?.add(to: RunLoop.current, forMode: .commonModes)
        isCountDown = true
    }
    
    func pause() {
        
        isCountDown = false
        timer?.invalidate()
    }
    func stop() {
        isCountDown = false
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
}
