//
//  BleDevice.swift
//  BLEPractice
//
//  Created by 贾捷飞 on 2021/12/12.
//

import Foundation
import CoreBluetooth

class BleDevice: NSObject {
    var peripheral: CBPeripheral
    var advertisementData: [String : Any]
    var rssi: Int
    
    init(peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.rssi = Int.init(truncating: rssi)
        super.init()
        self.updateRssi(rssi: rssi)
    }
    
    func updateRssi(rssi: NSNumber) {
        self.rssi = Int.init(truncating: rssi)
        if self.rssi == 127 {
            self.rssi = -127
        }
    }
    
    func deviceName() -> String {
        var name = peripheral.name
        if name == nil {
            name = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        }
        
        if name == nil {
            return "Unknown Device"
        }
        return name!
    }
    
    func manufacturerDataHex() -> String {
        if let data = advertisementData[CBAdvertisementDataManufacturerDataKey] {
            if let hexValue = DataUtil.dataToHexString(data: data as? Data) {
                return hexValue
            }
        }
        return ""
    }
    
    func servicesString() -> String {
        if let services = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            if services.count == 1 {
                return "1 service"
            }
            return "\(services.count) services"
        }
        return "No services"
    }
    
    static func == (lhs: BleDevice, rhs: BleDevice) -> Bool {
        return lhs.peripheral.identifier.uuidString == rhs.peripheral.identifier.uuidString
    }
}
