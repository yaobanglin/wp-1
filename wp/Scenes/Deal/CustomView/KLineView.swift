//
//  KLineView.swift
//  wp
//
//  Created by 木柳 on 2016/12/26.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class KLineView: UIView {
    @IBOutlet weak var miuCharts: LineChartView!
    @IBOutlet weak var miu15Charts: CombinedChartView!
    @IBOutlet weak var hourCharts: CombinedChartView!
    @IBOutlet weak var dayCharts: CombinedChartView!
    var selectIndex: NSInteger!{
        didSet{
            switch selectIndex {
            case 1:
                bringSubview(toFront: self.miuCharts)
                break
            case 2:
                bringSubview(toFront: self.miu15Charts)
                break
            case 3:
                bringSubview(toFront: self.hourCharts)
                break
            case 4:
                bringSubview(toFront: self.dayCharts)
                break
            default:
                bringSubview(toFront: self.miuCharts)
            }
        }
    }
    
    enum KType: Int {
        case miu = 1   //1分钟
        case miu5 = 2  //5分钟
        case miu15 = 3 //15分钟
        case miu30 = 4 //30分钟
        case miu60 = 5 //60分钟
        case day = 6   //日K线
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selectIndex = 1
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DealModel.share().cacheKTimelimeModels()
        initChartView()
        requestLineChartData()
    }

    //MARK: --Charts
    func initChartView() {
        
        for charts in self.subviews {
            if charts.isKind(of:BarLineChartViewBase.self) {
                let chartsView = charts as! BarLineChartViewBase
                chartsView.legend.setCustom(entries: [])
                chartsView.noDataText = "暂无数据"
                chartsView.xAxis.labelPosition = .bottom
                chartsView.xAxis.drawGridLinesEnabled = false
                chartsView.xAxis.axisMinimum = 0
                chartsView.xAxis.labelFont = UIFont.systemFont(ofSize: 0)
                chartsView.leftAxis.labelFont = UIFont.systemFont(ofSize: 0)
                chartsView.leftAxis.gridColor = UIColor.init(rgbHex: 0xf2f2f2)
                chartsView.rightAxis.gridColor = UIColor.init(rgbHex: 0xf2f2f2)                
            }
        }
        
        dayCharts.xAxis.axisMaximum = 30
//        dayCharts.rightAxis.axisMinimum = 0
//        dayCharts.leftAxis.axisMinimum = 0
        
        hourCharts.xAxis.axisMaximum = 24
//        hourCharts.rightAxis.axisMinimum = 0
//        hourCharts.leftAxis.axisMinimum = 0
        
        miu15Charts.xAxis.axisMaximum = 96
//        miu15Charts.rightAxis.axisMinimum = 0
//        miu15Charts.leftAxis.axisMinimum = 0
        
        
        miuCharts.xAxis.axisMaximum = 60*24
    }
    func refreshKLine() {
        initMiuLChartsData()
        initMiu15KChartsData()
        initMiu60KChartsData()
        initDayKChartsData()
    }
    //MARK: --分时图
    func initMiuLChartsData() {
        DealModel.share().queryTimelineModels(page: 1) { [weak self](result) -> ()? in
            if let models: [KChartModel] = result as? [KChartModel] {
                if models.count == 0 {
                    let _ = self?.delay(5, task: { [weak self] in
                        self?.initMiuLChartsData()
                    })
                }
                self?.initLineChartData(models: models)
            }
            return nil
        }
    }
    //MARK: --15分钟
    func initMiu15KChartsData() {
        DealModel.share().query15kModels { [weak self](result) -> ()? in
            if let models: [KChartModel] = result as? [KChartModel] {
                if models.count == 0 {
                    let _ = self?.delay(10, task: { [weak self] in
                        self?.initMiu15KChartsData()
                    })
                }
                self?.refreshCandleStickData(type: .miu15, models: models)
            }
            return nil
        }
        
        let _ = delay(60*15, task: { [weak self] in
            self?.initMiu15KChartsData()
        })
    }
    //MARK: --60分钟
    func initMiu60KChartsData() {
        DealModel.share().queryHourKModels { [weak self](result) -> ()? in
            if let models: [KChartModel] = result as? [KChartModel] {
                if models.count == 0 {
                    let _ = self?.delay(10, task: { [weak self] in
                        self?.initMiu60KChartsData()
                    })
                }
                self?.refreshCandleStickData(type: .miu60, models: models)
            }
            return nil
        }
        let _ = delay(60*60, task: { [weak self] in
            self?.initMiu60KChartsData()
        })
    }
    //MARK: --日K线
    func initDayKChartsData() {
        DealModel.share().queryDayKModels { [weak self](result) -> ()? in
            if let models: [KChartModel] = result as? [KChartModel] {
                if models.count == 0 {
                    let _ = self?.delay(60, task: { [weak self] in
                        self?.initDayKChartsData()
                    })
                }
                self?.refreshCandleStickData(type: .day, models: models)
            }
            return nil
        }
        let _ = delay(60*60*24, task: { [weak self] in
            self?.initDayKChartsData()
        })
    }
    //请求分时数据
    func requestLineChartData(){
        let _ = delay(60) { [weak self] in
            self?.requestLineChartData()
        }
        let param = KChartParam()
        if let model: ProductModel = DealModel.share().selectProduct{
            param.goodType = model.typeCode
            param.exchangeName = model.exchangeName
            param.platformName = model.platformName
        }
        
        AppAPIHelper.deal().timeline(param: param, complete: {(result) -> ()? in
            if let models: [KChartModel] = result as? [KChartModel]{
                DealModel.share().cacheTimelineModels(models: models, goodType:param.goodType)
            }
            return nil
        }, error: { [weak self](error) ->()? in
            let _ = self?.delay(5, task: { [weak self] in
                self?.requestLineChartData()
            })
            return nil
        })
        
    }
    //刷新折线
    func initLineChartData(models: [KChartModel]) {
        if models.count == 0 {
            return
        }
        
        var entrys: [ChartDataEntry] = []
        for (i, model) in models.enumerated()  {
            let entry = ChartDataEntry.init(x: Double(i), y: model.currentPrice)
            entrys.append(entry)
        }
        
        let set: LineChartDataSet = LineChartDataSet.init(values: entrys, label: "折线图")
        set.colors = [UIColor.init(rgbHex: 0x666666)]
        set.circleRadius = 0
        set.circleHoleRadius = 0
        set.mode = .cubicBezier
        set.valueFont = UIFont.systemFont(ofSize: 0)
        let fill = Fill.init(color: UIColor.init(rgbHex: 0x999999))
        
        set.fill = fill
        set.fillColor = UIColor.red
        let data: LineChartData  = LineChartData.init(dataSets: [set])
        miuCharts.data = data
        let combinData: CombinedChartData = CombinedChartData.init()
        combinData.lineData = data
        
        
    }
    //请求K线数据
//    func requestKChartData(_ type: KType, chartComplete: CompleteBlock?){
//        let param = KChartParam()
//        if let model: ProductModel = DealModel.share().selectProduct{
//            param.goodType = model.typeCode
//            param.exchangeName = model.exchangeName
//            param.platformName = model.platformName
//            param.chartType = type.rawValue
//        }
//        
//        AppAPIHelper.deal().kChartsData(param: param, complete: {(result) -> ()? in
//            if let models: [KChartModel] = result as? [KChartModel]{
//                chartComplete!(models as AnyObject?)
//            }
//            return nil
//        }, error: nil)
//        
//    }
    //刷新K线
    func refreshCandleStickData(type: KType, models: [KChartModel]) {
        if models.count == 0 {
            return
        }
        
        var entrys: [ChartDataEntry] = []
        for (index, model) in models.enumerated(){
            let location = Double(index+1)
            let entry = convertModelToCandleDataEntry(model: model, location:location)
            entrys.append(entry)
        }
        let set: CandleChartDataSet = CandleChartDataSet.init(values: entrys, label: nil)
        set.increasingColor = UIColor.init(rgbHex: 0xE9573f)
        set.decreasingColor = UIColor.init(rgbHex: 0x009944)
        set.increasingFilled = true
        set.shadowColorSameAsCandle = true
        set.formLineWidth = 5
        set.valueFont = UIFont.systemFont(ofSize: 0)
        let dataSets: [IChartDataSet] = [set]
        let data: CandleChartData = CandleChartData.init(dataSets: dataSets)
        let combinData: CombinedChartData = CombinedChartData.init()
        combinData.candleData = data
        switch type {
        case .day:
            dayCharts.data = combinData
            break
        case .miu60:
            hourCharts.data = combinData
            break
        case .miu15:
            miu15Charts.data = combinData
            break
        default:
            return
        }
        
    }
    
    func convertModelToCandleDataEntry(model: KChartModel, location:Double) -> CandleChartDataEntry {
        let entry = CandleChartDataEntry.init(x:location, shadowH: model.highPrice, shadowL: model.lowPrice, open: model.openingTodayPrice, close: model.closedYesterdayPrice)
        
        return entry
    }
    
    func convertModelToLineDataEntry(model: KChartModel, location:Double) -> ChartDataEntry {
        let entry = ChartDataEntry.init(x: location, y: model.currentPrice)
        return entry
    }
}
