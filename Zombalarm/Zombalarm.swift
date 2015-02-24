//
//  Zombalarm.swift
//  Zombalarm
//
//  Created by Elliot Barer on 2015-02-13.
//  Copyright (c) 2015 Elliot Barer. All rights reserved.
//

import UIKit
import CoreBluetooth

class Zombalarm: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    
    //*******************************************************
    // Class members
    //*******************************************************
    
    var centralManager:CBCentralManager!				// Bluetooth central manager (iOS Device)
    var zombalarm:CBPeripheral!							// Bluetooth peripheral device (Zombalarm)
    var rxCharacteristic:CBCharacteristic!				// Bluetooth RX characteristic
    var txCharacteristic:CBCharacteristic!				// Bluetooth TX characteristic
    
    var bluetoothState:Bool!							// Bluetooth status
	var securityTimer:NSTimer!							// Connection timeout timer
    dynamic var activity:String!						// Lock activity
    dynamic var debugActivity:String!					// Lock activity (debug)
    
    // UUIDs for SmartLock UART Service and Characteristics (RX/TX)
    var zombalarmNSUUID:NSUUID!
    let uartServiceUUID = CBUUID(string:"6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    let txCharacteristicUUID = CBUUID(string:"6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    let rxCharacteristicUUID = CBUUID(string:"6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    
    override init() {
        super.init()
        bluetoothState = false
    }
    
    
    
    //*******************************************************
    // Central Manager (iPhone) Functions
    //*******************************************************
    
    // Initializes the central manager with a specified delegate.
    func startUpCentralManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        output("Started")
    }
    
    // Invoked when the central manager’s state is updated.
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        switch (central.state) {
        case .PoweredOff:
            bluetoothState = false
            output("Bluetooth Off")
        case .PoweredOn:
            bluetoothState = true
            output("Bluetooth On")
            discoverDevices()
        default:
            bluetoothState = false
            output("Bluetooth Unknown")
        }
    }
    
    // Scans for Zombalarms by searching for advertisements with UART services.
    func discoverDevices() {
        // Avoid scanning by reconnecting to known good SmartLock
        // If not found, scan for other devices
        if (bluetoothState == true) {
            output("Base secured", UI: true)

            if (zombalarmNSUUID == nil) {
                centralManager.scanForPeripheralsWithServices([uartServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
            }
        }
    }
    
    // Invoked when the central manager discovers a Zombalarm while scanning.
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        // Connect to SmartLock
        output("Zombie attack!", UI: true)
        sendNotification()
		securityTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("resetSearch"), userInfo: nil, repeats: false)
    }
    
    // Reset system and wait for response from other Zombalarms
    func resetSearch() {
        securityTimer.invalidate()
        zombalarmNSUUID = nil
        discoverDevices()
    }
    
    // Local notification
    func sendNotification() {
        var localNotification:UILocalNotification = UILocalNotification()
        localNotification.alertBody = "Zombie attack!"
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 0)
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        output("Notification fn.")
    }
    
    
    //*******************************************************
    // Debug Functions
    //*******************************************************
    
    func output(description: String, UI: Bool = false) {
        let timestamp = generateTimeStamp()
        
        if (UI.boolValue == true) {
            activity = "\(description)"
        }
        
        println("[\(timestamp)] \(description)")
        debugActivity = "\(description)"
    }
    
    func generateTimeStamp() -> NSString {
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .NoStyle, timeStyle: .MediumStyle)
        return timestamp
    }
    
}