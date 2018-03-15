//
//  ViewController.swift
//  BLECentral
//
//  Created by 電気なまず on 2017/11/18.
//  Copyright © 2017年 Masanori Nakano. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController,
    CBCentralManagerDelegate,
    CLLocationManagerDelegate {
    
    @IBOutlet private weak var logTV: UITextView!

    private let centralMgr: CBCentralManager
    private let locationMgr: CLLocationManager = CLLocationManager()
    
    private let proximityUUID: UUID = UUID(uuidString: "605391ce-48c0-4118-aa61-daeb5fdf99f1")!
//    private let proximityUUID: UUID = UUID(uuidString: "eb340d6d-22b4-4481-9304-aa107417097c")!
    
    // MARK: - UIViewController
    
    required init?(coder aDecoder: NSCoder) {
        centralMgr = CBCentralManager(delegate: nil,
                                      queue: nil,
                                      options: nil)
        super.init(coder: aDecoder)
        
        centralMgr.delegate = self
        locationMgr.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways:
            addLog("status authorizedAlways")

        case .authorizedWhenInUse:
            addLog("status authorizedWhenInUse")

        case .denied:
            addLog("status denied")

        case .notDetermined:
            addLog("status notDetermined")
            locationMgr.requestWhenInUseAuthorization()
            

        case .restricted:
            addLog("status restricted")
        }
    }
    
    // MARK: - Private
    
    private func addLog(_ text: String) {
        var isScroll = false
        let max = logTV.contentSize.height - logTV.frame.height
        if max <= 0.0 {
            isScroll = true
        } else if logTV.contentOffset.y == max {
            isScroll = true
        }
        
        if var oldText: String = logTV.text {
            if 0 < oldText.count {
                oldText.append("\n")
            }
            
            oldText.append(text)
            
            logTV.text = oldText
        } else {
            logTV.text = text
        }

        if isScroll {
            DispatchQueue.main.async {
                if self.logTV.contentSize.height <= self.logTV.frame.height {
                    return
                }
                
                var contentOffset = self.logTV.contentOffset
                contentOffset.y = self.logTV.contentSize.height - self.logTV.frame.height
                self.logTV.contentOffset = contentOffset
            }
        }
    }
    
    private func beaconRegion() -> CLBeaconRegion {
        let identifier: String = "jp.co.denkinamazu.BLEPeripheral"
        let beaconRegion: CLBeaconRegion = CLBeaconRegion(proximityUUID: proximityUUID,
                                                          identifier: identifier)
        return beaconRegion
    }
    
    // MARK: - Action
    
    private var isMonitoring: Bool = false
    @IBAction private func startMonitoring(_ sender: UIButton) {
        let region: CLBeaconRegion = beaconRegion()
        
        
//        addLog("  " + region.proximityUUID.uuidString)
//        addLog("  " + region.identifier)
        
        if isMonitoring {
            addLog("モニタリング停止")
            locationMgr.stopMonitoring(for: region)
            sender.setTitle("モニタリング開始", for: .normal)
        } else {
            addLog("モニタリング開始")
            locationMgr.startMonitoring(for: region)
            sender.setTitle("モニタリング停止", for: .normal)
        }
        
        isMonitoring = !isMonitoring
    }

    private var isRanging: Bool = false
    @IBAction private func startRainging(_ sender: UIButton) {
        let region: CLBeaconRegion = beaconRegion()
        
        if isRanging {
            addLog("レンジング停止")
            locationMgr.stopRangingBeacons(in: region)
            sender.setTitle("レンジング開始", for: .normal)
        } else {
            addLog("レンジング開始")
            locationMgr.startRangingBeacons(in: region)
            sender.setTitle("レンジング停止", for: .normal)
        }

        isRanging = !isRanging
    }
    
    @IBAction private func startScan(_ sender: UIButton) {
        if centralMgr.isScanning {
            addLog("スキャン停止")
            centralMgr.stopScan()
            sender.setTitle("スキャン開始", for: .normal)
        } else {
            switch centralMgr.state {
            case .poweredOff: addLog("BluetoothをONにしてね")
            case .resetting: addLog("Bluetoothをリセット中")
            case .unauthorized: addLog("Bluetoothが許可されてない")
            case .unknown: addLog("Bluetoothが不明な不具合")
            case .unsupported: addLog("Bluetoothもってねよ")
                
            case .poweredOn:
                addLog("スキャン開始")
                centralMgr.scanForPeripherals(withServices: nil,
                                              options: nil)
                sender.setTitle("スキャン停止", for: .normal)
            }
        }
        
        //scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]? = nil)
    }
    
    @IBAction private func clearLog(_ sender: UIButton) {
        logTV.text = ""
    }
    
    // MARK: - CBCentralManagerDelegate

    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            addLog("centralManagerDidUpdateState poweredOff")
            
        case .poweredOn:
            addLog("centralManagerDidUpdateState poweredOn")
            
        case .resetting:
            addLog("centralManagerDidUpdateState resetting")
            
        case .unauthorized:
            addLog("centralManagerDidUpdateState unauthorized")
            
        case .unknown:
            addLog("centralManagerDidUpdateState unknown")
            
        case .unsupported:
            addLog("centralManagerDidUpdateState unsupported")
        }
    }
    
    internal func centralManager(_ central: CBCentralManager,
                                 didDiscover peripheral: CBPeripheral,
                                 advertisementData: [String : Any],
                                 rssi RSSI: NSNumber) {
        
        //kCBAdvDataServiceUUIDs
        
        addLog("didDiscover")
        addLog("  " + peripheral.identifier.uuidString)
        addLog("  " + RSSI.intValue.description)
        
        if let name = peripheral.name {
            addLog("  " + name)
        }
        
//         + advertisementData.description
    }

//    optional public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any])
//    optional public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
//    optional public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?)
//    optional public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?)
    
    // MARK: - CLLocationManagerDelegate
    
    internal func locationManager(_ manager: CLLocationManager,
                                  didRangeBeacons beacons: [CLBeacon],
                                  in region: CLBeaconRegion) {
        if beacons.count == 0 {
            return
        }
        
        addLog("didRangeBeacons")
        for beacon in beacons {
            addLog("  " + beacon.proximityUUID.uuidString)
            addLog("  " + beacon.rssi.description)
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager,
                                  rangingBeaconsDidFailFor region: CLBeaconRegion,
                                  withError error: Error) {
        addLog("rangingBeaconsDidFailFor " + error.localizedDescription)
    }
    
    // MARK: -

    internal func locationManager(_ manager: CLLocationManager,
                                  didEnterRegion region: CLRegion) {
        addLog("didEnterRegion")
    }
    
    internal func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        addLog("didExitRegion")
    }
    
    // MARK: -
    
    internal func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        addLog("didStartMonitoringFor")
    }
    
    internal func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        addLog("monitoringDidFailFor " + error.localizedDescription)
    }
    
    internal func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        let region: CLBeaconRegion = region as! CLBeaconRegion
        
        switch state {
        case .inside:
            addLog("didDetermineState inside")
            addLog("  " + region.proximityUUID.uuidString)
            
        case .outside:
            addLog("didDetermineState outside")
            addLog("  " + region.proximityUUID.uuidString)
            
        case .unknown:
            addLog("didDetermineState unknown")
            addLog("  " + region.proximityUUID.uuidString)
        }
    }
    
    // MARK: -
    
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            addLog("didChangeAuthorization authorizedAlways")
            
        case .authorizedWhenInUse:
            addLog("didChangeAuthorization authorizedWhenInUse")
            
        case .denied:
            addLog("didChangeAuthorization denied")
            
        case .notDetermined:
            addLog("didChangeAuthorization notDetermined")
            
        case .restricted:
            addLog("didChangeAuthorization restricted")
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        addLog("didFailWithError " + error.localizedDescription)
    }

//    optional public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
//    optional public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
//    optional public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool
//    optional public
//    optional
//    optional public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager)
//    optional public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager)
//    optional public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?)
//    optional public func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit)
    
}

