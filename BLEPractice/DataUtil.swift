//
//  DataUtil.swift
//  BLEPractice
//
//  Created by 贾捷飞 on 2021/12/8.
//

import Foundation

extension String {
    //截取字符串，返回Substring
    func substring(start: Int, length: Int) -> Substring {
        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(startIndex, offsetBy: length)
        return self[startIndex..<endIndex]
    }
}

class DataUtil {
    
    //二进制数据转HEX字符串
    class func dataToHexString(data: Data?, withSpace:Bool = true) -> String? {
        if let arr = data {
            let hexArr = arr.map({ (b) in
                String(format:"%02X", b)
            })
            return hexArr.joined(separator: withSpace ? " ":"")
        }
        return nil
    }
    
    //16进制字符（支持带空格的字符串）串转二进制数据
    class func hexToData(hexStr: String) -> Data {
        var str = hexStr.replacingOccurrences(of: " ", with: "")
        //print(str)
        let length = str.count
        var arrLen = length / 2
        
        if length % 2 == 1 {
            str = "0" + str
            arrLen += 1
        }
        
        var uint8Arr = [UInt8]()
        for i in 0..<arrLen {
            let subStr = str.substring(start: i * 2, length: 2)
            if let byteValue = UInt8(subStr, radix: 16) {
                uint8Arr.append(byteValue)
            }
        }
        return Data(uint8Arr)
    }
    
    //二进制数据转ASCII
    class func dataToString(data: Data?) -> String? {
        if let arr = data {
            if let str = String(data: arr, encoding: .ascii) {
                return str
            }
        }
        return nil
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    class func currentTime() -> String {
        return dateFormatter.string(from: Date())
    }
}
