//
//  BleDeviceStore.swift
//  BLEPractice
//
//  Created by 贾捷飞 on 2021/12/12.
//

import UIKit

//类似 Android ListView 的 Adapter
class BleDeviceStore: NSObject, UITableViewDataSource {
    
    var devices = [BleDevice]()
    var currentDevice: BleDevice? = nil
    
    func sortByRssi() {
        devices = devices.sorted(by: {
            $0.rssi > $1.rssi
        })
    }
    
    func addDevice(device: BleDevice) -> Int? {
        devices.append(device)
        return devices.firstIndex(of: device)
    }
    
    func findDevice(device: BleDevice) -> BleDevice? {
        return devices.first(where: {(bleDevice) -> Bool in
            bleDevice == device
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceListCell", for: indexPath) as! DeviceListCell
        let item = devices[indexPath.row]
        cell.labelName.text = item.deviceName()
        cell.labelDeviceId.text = item.servicesString()//item.peripheral.identifier.description
        cell.labelRssi.text = String(item.rssi)
        cell.labelMfrData.text = item.manufacturerDataHex()
        let imageName = getImageName(rssi: item.rssi)
        cell.imageViewRssi.image = UIImage.init(imageLiteralResourceName: "\(imageName).png")
        return cell
    }
    
    private func getImageName(rssi: Int) -> String {
        switch rssi {
        case -60..<0:
            return "rssi_5"
        case -70..<(-60):
            return "rssi_4"
        case -80..<(-70):
            return "rssi_3"
        case -90..<(-80):
            return "rssi_2"
        case -120..<(-90):
            return "rssi_1"
        default:
            return "rssi_0"
        }
    }
}
