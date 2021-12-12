//
//  DeviceConnectViewController.swift
//  BLEPractice
//
//  Created by 贾捷飞 on 2021/12/7.
//

import UIKit
import CoreBluetooth

//设备连接页面
class DeviceConnectViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource, HexInputViewControllerDelegate {
    
    let TAG = "DeviceConnectViewController"
    
    @IBOutlet weak var gattTableView: UITableView!
    
    
    var manager: CBCentralManager!
    var device: CBPeripheral! {
        didSet {
            navigationItem.title = device.name
        }
    }
    var gattServices = [CBService]()
    var gattCharacteristics = [String:[CBCharacteristic]]()
    var currentCharacteristic: CBCharacteristic? = nil
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //print("\(TAG) \(#function)")
        switch central.state {
        case .poweredOn:
            print("蓝牙已打开")
            break
        case .poweredOff:
            print("蓝牙已关闭")
            break
        default:
            print("\(TAG) \(#function) \(central.state)")
            break
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("\(TAG) 已连接设备")
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("\(TAG) 连接失败 \(String(describing: error))")
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("\(TAG) 连接已断开 \(String(describing: error))")
    }
    
    
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        //-------
        switch event {
        case .peerDisconnected:
            print("peerDisconnected")
        case .peerConnected:
            print("peerConnected")
        default:
            print("unknown event: \(event)")
            break
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        //发现服务
        print("\(TAG) 发现服务")
        if let services = peripheral.services {
            for service in services {
                //没搞懂怎么会有重复的service，这里判断一下
                if !gattServices.contains(where: { (cbService) -> Bool in
                    cbService.uuid.uuidString == service.uuid.uuidString
                }) {
                    gattServices.append(service)
                    gattCharacteristics[service.uuid.uuidString] = []
                    gattTableView.insertSections(IndexSet(integer: gattServices.count - 1), with: .none)
                    print("service: \(service)")
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            gattTableView.beginUpdates()//开始更新 TableView
            var indexPaths = [IndexPath]()
            for characteristic in characteristics {
                gattCharacteristics[service.uuid.uuidString]?.append(characteristic)
                if let characteristicArray = gattCharacteristics[service.uuid.uuidString] {
                    if let section = gattServices.firstIndex(of: service) {
                        let indexPath = IndexPath(row: characteristicArray.count - 1, section: section)
                        indexPaths.append(indexPath)
                    }
                }
                print("characteristic: \(characteristic)")
                peripheral.discoverDescriptors(for: characteristic)
            }
            print("gattCharacteristics[\(service.uuid.uuidString)].count=\(gattCharacteristics[service.uuid.uuidString]!.count)")
            gattTableView.insertRows(at: indexPaths, with: .none)
            gattTableView.endUpdates()//结束更新 TableView
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if let descriptors = characteristic.descriptors {
            for descriptor in descriptors {
                print("descriptor: \(descriptor)")
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //收到数据
        let data = characteristic.value
        print("收到数据 uuid=\(characteristic.uuid.uuidString), data=\(DataUtil.dataToHexString(data: data)) / \(DataUtil.dataToString(data: data))")
        gattTableView.reloadData()//刷新以显示收到的数据
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        //Notify状态变化
        print("\(#function) \(characteristic.uuid.uuidString) \(error)")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        device.delegate = self
        
        gattTableView.delegate = self
        gattTableView.dataSource = self
        
        
        //连接设备
        manager.connect(device, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: true])
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        print("\(TAG) \(#function)")
        //manager.cancelPeripheralConnection(device)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return gattServices.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let service = gattServices[section]
        if service.uuid.description.isEmpty {
            return "Unknown Service"
        }
        return service.uuid.description
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let service = gattServices[section]
        return gattCharacteristics[service.uuid.uuidString]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = gattTableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath) as! GattServiceCell
        //每次先移除事件再添加，防止重复添加
        cell.btnRead.removeTarget(self, action: #selector(DeviceConnectViewController.cellButtonReadClicked(_:)), for: .touchUpInside)
        cell.btnWrite.removeTarget(self, action: #selector(DeviceConnectViewController.cellButtonWriteClicked(_:)), for: .touchUpInside)
        cell.switchNotify.removeTarget(self, action: #selector(DeviceConnectViewController.cellButtonNotifyClicked(_:)), for: .valueChanged)
        
        let service = gattServices[indexPath.section]
        if let characteristic = gattCharacteristics[service.uuid.uuidString]?[indexPath.row] {
            //根据属性显示对应按钮
            let properties = characteristic.properties
            cell.btnRead.isHidden = !properties.contains(CBCharacteristicProperties.read)
            cell.btnWrite.isHidden = !properties.contains(CBCharacteristicProperties.write) && !properties.contains(CBCharacteristicProperties.writeWithoutResponse)
            let isShowNotify = properties.contains(CBCharacteristicProperties.notify)
            cell.labelNotify.isHidden = !isShowNotify
            cell.switchNotify.isHidden = !isShowNotify
            
            cell.labelName.isHidden = characteristic.uuid.description == characteristic.uuid.uuidString
            cell.labelName.text = characteristic.uuid.description
            cell.labelUUID.text = characteristic.uuid.uuidString
            cell.labelProperties.text = descProperties(properties: characteristic.properties)
            cell.switchNotify.isOn = characteristic.isNotifying
            if let hexValue = DataUtil.dataToHexString(data: characteristic.value),
               let asciiValue = DataUtil.dataToString(data: characteristic.value) {
                cell.labelValue.text = "\(hexValue) / \(asciiValue)"
            } else {
                cell.labelValue.text = ""
            }
            
            
            //按钮添加点击事件
            cell.btnRead.addTarget(self, action: #selector(DeviceConnectViewController.cellButtonReadClicked(_:)), for: .touchUpInside)
            cell.btnWrite.addTarget(self, action: #selector(DeviceConnectViewController.cellButtonWriteClicked(_:)), for: .touchUpInside)
            cell.switchNotify.addTarget(self, action: #selector(DeviceConnectViewController.cellButtonNotifyClicked(_:)), for: .valueChanged)
        }
        return cell
    }
    
    
    
    
    @objc func cellButtonReadClicked(_ button: UIButton) {
        print("\(#function)")
        if let characteristic = getItem(button) {
            device.readValue(for: characteristic)
        }
    }
    @objc func cellButtonWriteClicked(_ button: UIButton) {
        print("\(#function)")
        //点击Write按钮的时候会跳转到16进制输入界面，这里记录一下操作的characteristic，用于输入完成时返回本页面发送数据
        currentCharacteristic = getItem(button)
    }
    @objc func cellButtonNotifyClicked(_ button: UISwitch) {
        print("\(#function)")
        if let characteristic = getItem(button) {
            device.setNotifyValue(button.isOn, for: characteristic)
        }
    }
    
    
    func getItem(_ button: UIView) -> CBCharacteristic? {
        //查找 button 对应的 UITableViewCell
        var cell:UIView? = button.superview
        repeat {
            cell = cell?.superview
        } while !(cell is UITableViewCell)
        //获取 UITableViewCell 对应的 indexPath
        if let indexPath = gattTableView.indexPath(for: cell as! UITableViewCell) {
            print("section=\(indexPath.section), row=\(indexPath.row)")
            let service = gattServices[indexPath.section]
            return gattCharacteristics[service.uuid.uuidString]?[indexPath.row]
        }
        return nil
    }
    
    
    func descProperties(properties: CBCharacteristicProperties) -> String {
        var propertiesArray = [String]()
        if properties.contains(CBCharacteristicProperties.broadcast) {
            propertiesArray.append("broadcast")
        }
        if properties.contains(CBCharacteristicProperties.read) {
            propertiesArray.append("read")
        }
        if properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
            propertiesArray.append("writeWithoutResponse")
        }
        if properties.contains(CBCharacteristicProperties.write) {
            propertiesArray.append("write")
        }
        if properties.contains(CBCharacteristicProperties.notify) {
            propertiesArray.append("notify")
        }
        if properties.contains(CBCharacteristicProperties.indicate) {
            propertiesArray.append("indicate")
        }
        
        return propertiesArray.joined(separator: " ")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowHexViewController"?:
            let hexViewController = segue.destination as! HexInputViewController
            //跳转页面前设置委托
            hexViewController.hexDelegate = self
            break
        default:
            break
        }
    }
    
    
    func hexInputDone(hexString: String) {
        //输入完成，发送数据
        print("\(TAG) \(#function) - \(hexString)")
        if let characteristic = currentCharacteristic, hexString != "" {
            let data = DataUtil.hexToData(hexStr: hexString)
            var type: CBCharacteristicWriteType
            if characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
                type = .withoutResponse
            } else {
                type = .withResponse
            }
            device.writeValue(data, for: characteristic, type: type)
        }
    }
    
}
