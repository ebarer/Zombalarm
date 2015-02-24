//
//  DebugViewController.swift
//  SmartLock iOS Application
//
//  Created by Elliot Barer on 2014-10-09.
//  Copyright (c) 2014 Elliot Barer. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    var zmbalrm = Zombalarm()
    private var myContext = 0
    
    // UI Elements
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var zombieImage: UIImageView!

    
    // When application loads, and when view appears or disappears
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        
        zombieImage.hidden = true;
        
        // Start Bluetooth Central Manager
        zmbalrm.startUpCentralManager()
        
        // Watch for changes in "activity" from SmartLock model
        zmbalrm.addObserver(self, forKeyPath: "activity", options: .New, context: &myContext)
    }
    
    override func viewDidAppear(animated: Bool) {
        zmbalrm.discoverDevices()
    }
    
    override func viewDidDisappear(animated: Bool) {
    }
    
    // Set status bar to light
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // Update lockControl text with activity changes in SmartLock model (MVC)
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &myContext {
            activityLabel.text = "\(zmbalrm.activity)\n"
            
            if (zmbalrm.activity == "Base secured") {
                zombieImage.hidden = true;
            } else {
                zombieImage.hidden = false;
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

}