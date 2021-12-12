//
//  JFButton.swift
//  BLEPractice
//
//  Created by 贾捷飞 on 2021/12/12.
//

import UIKit

protocol JFButtonDelegate : NSObjectProtocol {
    func continuousPressedEvent(_ sender: JFButton)
    func clickEvent(_ sender: JFButton)
}

//自定义Button，实现按住持续触发长按事件
class JFButton: UIButton {
    
    var timer: Timer? = nil
    var count = 0
    var delegate: JFButtonDelegate? = nil
    var withContinuousPressedEvent = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.masksToBounds = true//允许绘制
        //self.layer.cornerRadius = 4//边框弧度
        self.layer.borderColor = UIColor.gray.cgColor//边框颜色
        self.layer.borderWidth = 0.3//边框的宽度
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func startTimer() {
        if timer == nil {
            //TimeInterval是 Double 类型，单位是秒
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {(t) in
                //print("Timer running... \(self.count)")
                self.count += 1
                if self.count >= 5 {//0.5秒触发持续长按
//                    OperationQueue.main.addOperation {
//                        //主线程执行
//                    }
                    self.delegate?.continuousPressedEvent(self)
                }
            })
        }
    }
    
    func stopTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        count = 0
        if withContinuousPressedEvent {
            startTimer()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopTimer()
        if !withContinuousPressedEvent || count < 5 {//0.5秒以内相当于点击
            delegate?.clickEvent(self)
        }
    }
}
