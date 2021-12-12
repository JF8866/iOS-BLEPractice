//
//  BleScanViewController.swift
//  BLEPractice
//
//  Created by 贾捷飞 on 2021/12/12.
//

import UIKit
import CoreBluetooth

class BleScanViewController: UIViewController, UITableViewDelegate, CBCentralManagerDelegate {
    let TAG = "BleScanViewController"
    
    var manager: CBCentralManager!
    var bluetoothEnabled = false
    var deviceStore = BleDeviceStore()
    
    
    @IBOutlet var tableView: UITableView!
    @IBAction func sortByRssi(_ sender: UIBarButtonItem) {
        //按信号强度排序
        deviceStore.sortByRssi()
        tableView.reloadData()
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("\(TAG) \(#function)")
        switch central.state {
        case .poweredOn:
            print("蓝牙已打开")
            bluetoothEnabled = true
            startScan()
            break
        case .poweredOff:
            print("蓝牙已关闭")
            bluetoothEnabled = false
            break
        default:
            print("\(TAG) \(#function) \(central.state)")
            break
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("\(TAG) 连接已断开")
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 动态计算Cell的高度，按一行最多51个字符，IB中显示厂商数据的 Label 设置的字体大小为14，单行高度17即可显示
        let device = deviceStore.devices[indexPath.row]
        let mfrDataHex = device.manufacturerDataHex()
        var lines = mfrDataHex.count / 51
        if mfrDataHex.count % 51 > 0 {
            lines += 1
        }
        return CGFloat(62 + lines * 17)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = deviceStore
        addRefreshHeader()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("\(TAG) \(#function)")
        //在这个方法设置委托，是因为连接页面也会设置 manager 的委托，当前页面可见时再设置回来
        manager.delegate = self
        if let device = deviceStore.currentDevice {
            print("\(TAG) \(#function) 断开连接")
            manager.cancelPeripheralConnection(device.peripheral)
        }
        //页面可见时扫描设备
        if bluetoothEnabled {
            startScan()
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        print("\(TAG) \(#function)")
        //页面不可见时停止扫描设备
        manager.stopScan()
        print("DeviceScanViewController 停止扫描")
    }
 
    // 开源库：https://github.com/CoderMJLee/MJRefresh
    private func addRefreshHeader() {
        MJRefreshNormalHeader { [weak self] in
            //清空TableView
            self?.clearTableView()
            self?.startScan()
            
            print("DeviceScanViewController 开始扫描")
            Thread.sleep(forTimeInterval: 0.3)
            self?.tableView.mj_header?.endRefreshing()
        }
        .autoChangeTransparency(true)
        .link(to: tableView)
    }
    
    private func clearTableView() {
        if(!deviceStore.devices.isEmpty) {
            tableView.beginUpdates()
            var indexPaths = [IndexPath]()
            for i in deviceStore.devices.indices {
                indexPaths.append(IndexPath(row: i, section: 0))
            }
            deviceStore.devices = [BleDevice]()
            tableView.deleteRows(at: indexPaths, with: .none)
            tableView.endUpdates()
        }
    }
    
    
    //扫描设备
    private func startScan() {
        manager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //发现设备
        //print("device name: \(String(describing: peripheral.name)), device id: \(peripheral.identifier)")
        let device = BleDevice(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
        
        if let item = deviceStore.findDevice(device: device) {
            item.updateRssi(rssi: RSSI)
            tableView.reloadData()
        } else {
            //添加到 TableVIew
            if let index = deviceStore.addDevice(device: device) {
                let indexPath = IndexPath(row: index, section: 0)
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowDeviceConnect"?:
            if let selectedIndexPath = tableView.indexPathsForSelectedRows?.first {
                let deviceConnectViewController = segue.destination as! DeviceConnectViewController
                let dveice = deviceStore.devices[selectedIndexPath.row]
                deviceConnectViewController.device = dveice.peripheral
                deviceConnectViewController.manager = manager
                //记录设备，用于断开连接
                deviceStore.currentDevice = dveice
                print("跳转 \(manager)")
            }
            break
        default:
            break
        }
    }
}
