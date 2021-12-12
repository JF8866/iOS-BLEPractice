//
//  JFTextField.swift
//  BLEPractice
//
//  Created by 贾捷飞 on 2021/12/12.
//

import UIKit

class JFTextField: UITextField {
    
    
    //原文链接：https://blog.csdn.net/findhappy117/article/details/79478388
    func updateText(text: String) {
        let beginning = self.beginningOfDocument//文字开始的地方
        let startPosition = self.selectedTextRange?.start//光标开始的位置
        let endPosition = self.selectedTextRange?.end//光标结束的位置
        //获取光标开始位置在文字中所在的index
        let startIndex = self.offset(from: beginning, to: startPosition!)
        //获取光标结束位置在文字中所在的index
        let endIndex = self.offset(from: beginning, to: endPosition!)
        // 将输入框中的文字分成两部分，生成新字符串，判断新字符串是否满足要求
        let originText = self.text
        //从起始位置到当前index
        var beforeString = String(originText!.prefix(startIndex))
        //从光标结束位置到末尾
        let afterString = String(originText!.suffix(originText!.count - endIndex))

        var offset: Int
        
        if text != "" {
            offset = text.count
        } else {
            // 只删除一个字符
            if (startIndex == endIndex) {
                if (startIndex == 0) {
                    return
                }
                offset = -1
                beforeString = String(beforeString.prefix(beforeString.count - 1))
            } else {
                //光标选中多个
                offset = 0;
            }
        }
        let newText = beforeString + text + afterString
        self.text = newText
        
        // 重置光标位置
        let nowPosition = self.position(from: startPosition!, offset: offset)
        let range = self.textRange(from: nowPosition!, to: nowPosition!)
        self.selectedTextRange = range
    }
}
