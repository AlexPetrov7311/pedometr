//
//  ViewController.swift
//  Pedometr
//
//  Created by Alexey Petrov on 13.03.16.
//  Copyright © 2016 Alexey Petrov. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

     var myTimer: NSTimer? = nil
    
    @IBOutlet weak var steps: UILabel!
    @IBOutlet weak var activityState: UILabel!
    
    let activityManager = CMMotionActivityManager()
    let pedoMeter = CMPedometer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "updateInformation", userInfo: nil, repeats: true)
        
    }
    
    func updateInformation(){
        
        NSLog("Timer runnign");
        
        let cal = NSCalendar.currentCalendar()
        
        let comps = cal.components([.Year , .Month , .Day , .Hour , .Minute , .Second], fromDate: NSDate())
        
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        let timeZone = NSTimeZone.systemTimeZone()
        cal.timeZone = timeZone
        
        let midnightOfToday = cal.dateFromComponents(comps)!
        
        
        if(CMMotionActivityManager.isActivityAvailable()){
            self.activityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue()) { data in
                if let data = data{
                    dispatch_async(dispatch_get_main_queue()) {
                        if(data.stationary == true){
                            self.activityState.text = "Stationary"
                        } else if (data.walking == true){
                            self.activityState.text = "Walking"
                        } else if (data.running == true){
                            self.activityState.text = "Running"
                        } else if (data.automotive == true){
                            self.activityState.text = "Automotive"
                        }
                    }
                }
                
            }
        }
        
        if(CMPedometer.isStepCountingAvailable()){
            let fromDate = NSDate(timeIntervalSinceNow: -86400 * 7)
            self.pedoMeter.queryPedometerDataFromDate(fromDate, toDate: NSDate()) { (data, error) in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if(error == nil){
                        NSLog("%@", data!.numberOfSteps)
                        self.steps.text = "\(data!.numberOfSteps)"
                    }
                })
                
            }
            
            self.pedoMeter.startPedometerUpdatesFromDate(midnightOfToday) { (data, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if(error == nil){
                        self.steps.text = "\(data!.numberOfSteps)"
                    }
                })
            }
        }

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

