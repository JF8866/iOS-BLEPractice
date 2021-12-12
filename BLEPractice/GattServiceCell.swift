//
//  GattServiceCell.swift
//  BLEPractice
//
//  Created by 贾捷飞 on 2021/12/7.
//

import UIKit

class GattServiceCell: UITableViewCell {
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelUUID: UILabel!
    @IBOutlet var labelProperties: UILabel!
    @IBOutlet var labelValue: UILabel!
    @IBOutlet var btnRead: UIButton!
    @IBOutlet var btnWrite: UIButton!
    @IBOutlet var labelNotify: UILabel!
    @IBOutlet var switchNotify: UISwitch!
}
