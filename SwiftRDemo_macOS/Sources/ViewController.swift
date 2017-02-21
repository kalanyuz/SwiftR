//
//  ViewController.swift
//  SMKTunes
//
//  Created by Kalanyu Zintus-art on 10/21/15.
//  Copyright © 2015 Kalanyu. All rights reserved.
//

import Cocoa
import SwiftR

@IBDesignable class ViewController: NSViewController {

    @IBOutlet weak var graphView1: SRMergePlotView! {
        didSet {
            graphView1.title = "Filtered"
            graphView1.totalSecondsToDisplay = 10.0
        }
    }
	
    @IBOutlet weak var graphView2: SRPlotView! {
        didSet {
            graphView2.title = "Split"
            graphView2.totalSecondsToDisplay = 10.0
        }
    }
	
	@IBOutlet weak var graphView4: SRPlotView! {
		didSet {
			graphView4.title = "Split"
			
		}
	}
    @IBOutlet weak var graphView3: SRMergePlotView! {
        didSet {
            graphView3.title = "Raw"
            graphView3.totalSecondsToDisplay = 10.0
        }
    }
	
    @IBOutlet weak var backgroundView: SRSplashBGView! {
        didSet {
            backgroundView.splashFill(toColor: NSColor(red: 241/255.0, green: 206/255.0, blue: 51/255.0, alpha: 1), .left)
        }
    }
	
    fileprivate let loadingView = SRSplashBGView(frame: CGRect.zero)
    fileprivate var loadingLabel = NSTextLabel(frame: CGRect.zero)
    fileprivate var loadingText = "Status : Now Loading.." {
        didSet {
            loadingLabel.stringValue = self.loadingText
            loadingLabel.sizeToFit()
        }
    }
	
    fileprivate let progressIndicator = NSProgressIndicator(frame: CGRect.zero)
	
	fileprivate var anotherDataTimer: Timer?
	var count = 0

    fileprivate var fakeLoadTimer: Timer?
    fileprivate var samplingRate = 1000;

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //prepare loading screen
        loadingView.frame = self.view.frame
        progressIndicator.frame = CGRect(origin: CGPoint(x: 50, y: 50), size: CGSize(width: 100, height: 100))
        progressIndicator.style = .spinningStyle
        loadingLabel.frame = CGRect(origin: CGPoint(x: progressIndicator.frame.origin.x + progressIndicator.frame.width, y: 0), size: CGSize(width: 100, height: 100))
        loadingLabel.stringValue = loadingText
		loadingLabel.font = NSFont.boldSystemFont(ofSize:15)
        loadingLabel.sizeToFit()
        loadingLabel.frame.origin.y = progressIndicator.frame.origin.y + (progressIndicator.frame.width/2) - (loadingLabel.frame.height/2)
        loadingLabel.lineBreakMode = .byTruncatingTail
        
        
        loadingView.addSubview(loadingLabel)
        loadingView.addSubview(progressIndicator)
        progressIndicator.startAnimation(nil)
        loadingView.wantsLayer = true
        loadingView.layer?.backgroundColor = NSColor.white.cgColor
        
        loadingView.autoresizingMask = [.viewHeightSizable, .viewWidthSizable]
        self.view.addSubview(loadingView)

        
		anotherDataTimer = Timer(timeInterval:1/60, target: self, selector: #selector(ViewController.addData), userInfo: nil, repeats: true)
        RunLoop.current.add(anotherDataTimer!, forMode: RunLoopMode.commonModes)

		fakeLoadTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: {x in self.systemStartup()})

		graphView1.totalChannelsToDisplay = 6
        graphView2.totalChannelsToDisplay = 6
		graphView4.totalChannelsToDisplay = 6
        graphView3.totalChannelsToDisplay = 6

    }
    
    override func viewWillDisappear() {
        
    }
    
    func systemStartup() {
        loadingView.fade(toAlpha: 0)
    }

    
    func addData() {
        count += 1
        let cgCount = sin(Double(count) * 1/60)
        graphView1.addData([cgCount, cgCount, cgCount, cgCount, cgCount , cgCount])
        graphView2.addData([cgCount, cgCount, cgCount, cgCount, cgCount , cgCount])
        graphView3.addData([cgCount, cgCount, cgCount, cgCount, cgCount , cgCount])
		graphView4.addData([cgCount, cgCount, cgCount, cgCount, cgCount , cgCount])


    }

}

