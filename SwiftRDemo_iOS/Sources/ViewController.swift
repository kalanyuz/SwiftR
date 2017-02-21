//
//  ViewController.swift
//  SwiftPlot_iOS
//
//  Created by Kalanyu Zintus-art on 1/5/16.
//  Copyright © 2016 Koikelab. All rights reserved.
//

import UIKit
import SwiftR


class ViewController: UIViewController, SRSplashViewDelegate {

//    private var sensorModule = TPHEMGSensor()
//    private var jointEstimator = KLJointAngleEstimator()
    

    //TODO: make this setup able when used in code
    @IBOutlet weak var graphView: SRPlotView! {
        didSet {
            graphView.title = "Test 1"
            graphView.totalSecondsToDisplay = 10.0
            graphView.totalChannelsToDisplay = 6
            //axe padding
            graphView.samplingRate = 60
            
   
        }
    }
    
    @IBOutlet weak var secondGraphView: SRPlotView! {
        didSet {
            secondGraphView.title = "Test 2"
            secondGraphView.totalSecondsToDisplay = 10.0
            secondGraphView.totalChannelsToDisplay = 6
            //axe padding
            secondGraphView.samplingRate = 60
            
            secondGraphView.yTicks[0] = "Flexor 1"
            secondGraphView.yTicks[1] = "Flexor 2"
            secondGraphView.yTicks[2] = "Flexor 3"
            secondGraphView.yTicks[3] = "Extensor 1"
            secondGraphView.yTicks[4] = "Extensor 2"
            secondGraphView.yTicks[5] = "Extensor 3"
        }
    }
    
    @IBOutlet weak var thirdGraphView: SRPlotView! {
        didSet {
            thirdGraphView.title = "Test 3"
            thirdGraphView.totalSecondsToDisplay = 10.0
            thirdGraphView.totalChannelsToDisplay = 6
            //axe padding
            thirdGraphView.samplingRate = 60
            
            thirdGraphView.yTicks[0] = "Flexor 1"
            thirdGraphView.yTicks[1] = "Flexor 2"
            thirdGraphView.yTicks[2] = "Flexor 3"
            thirdGraphView.yTicks[3] = "Extensor 1"
            thirdGraphView.yTicks[4] = "Extensor 2"
            thirdGraphView.yTicks[5] = "Extensor 3"
        }
    }
    
    var count = 0
    
	@IBOutlet weak var backgroundView: SRSplashBGView! {
        didSet {
            backgroundView.initLayers()
            backgroundView.delegate = self
        }
    }
    
    fileprivate var anotherDataTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        anotherDataTimer = Timer(timeInterval:1/60, target: self, selector: #selector(ViewController.addData2), userInfo: nil, repeats: true)
        RunLoop.current.add(anotherDataTimer!, forMode: RunLoopMode.commonModes)
        // Do any additional setup after loading the view, typically from a nib.
        self.view.layer.backgroundColor = UIColor.red.cgColor
        
    }

    
    func addData2() {
		
		count += 1
        let cgCount = sin((Double(count) * 1/60))
        
		graphView.addData([cgCount, cgCount, cgCount, cgCount, cgCount , cgCount])
		secondGraphView.addData([cgCount, cgCount, cgCount, cgCount, cgCount , cgCount])
		thirdGraphView.addData([cgCount, cgCount, cgCount, cgCount, cgCount , cgCount])
    }
    //MARK: Implementations
//    func systemStartup() {
//        loadingView.fade(toAlpha: 0)
//    }
    
    //MARK: NSSPlashViewDelegate
    func splashAnimationEnded(startedFrom from: SplashDirection) {
        //        switch self.mode {
        //        case .TV:
        //            tvIconView.fade(toAlpha: 1)
        //        case .Robot:
        //            kumamonIconView.fade(toAlpha: 1)
        //        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	

}

