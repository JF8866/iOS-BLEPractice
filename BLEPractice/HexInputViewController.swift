//
//  HexKeyboardViewController.swift
//  BLEPractice
//
//  Created by 贾捷飞 on 2021/12/11.
//

import UIKit
import CoreGraphics


protocol HexInputViewControllerDelegate {
    func hexInputDone(hexString: String)
}

//16进制输入页面
class HexInputViewController: UIViewController, JFButtonDelegate {
    let TAG = "HexInputViewController"
    let KEY_TITLES = [
        "A", "B", "C",
        "D", "E", "F",
        "1", "2", "3",
        "4", "5", "6",
        "7", "8", "9",
        "DEL", "0", "DONE",
    ]
    
    @IBOutlet var hexTextField: JFTextField!
    
    var hexDelegate: HexInputViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //输入框使用自定义的键盘
        hexTextField.inputView = self.inputView
        //自动弹出键盘
        hexTextField.becomeFirstResponder()
    }
    
    override var inputView: UIView? {
        get {
            //自定义键盘View
            
            //获取屏幕宽度，用于计算每列按键的宽度
            let screenWidth = UIApplication.shared.statusBarFrame.width
            //按键的宽高
            let keyViewWidth = screenWidth / 3
            let keyViewHeight = 54
            
            //创建6行3列的按键
            let rows = 6
            let cols = 3
            let count = rows * cols
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: Int(screenWidth), height: keyViewHeight * rows))
            
            for i in 0..<count {
                let button = JFButton(frame: CGRect(x: CGFloat(i % cols) * keyViewWidth, y: CGFloat(i / cols * keyViewHeight), width: keyViewWidth, height: CGFloat(keyViewHeight)))
                var titleColor: UIColor
                switch i {
                case 15://删除键显示红色
                    titleColor = UIColor.systemRed
                    break
                case 17://完成键显示蓝色
                    titleColor = UIColor.systemBlue
                    break
                default:
                    titleColor = UIColor.black
                    break
                }
                button.setTitle("\(KEY_TITLES[i])", for: .normal)
                button.setTitleColor(titleColor, for: .normal)
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                button.backgroundColor = UIColor.white
                button.withContinuousPressedEvent = i != 17 //DONE 键只有点击事件
                button.delegate = self //设置点击事件的委托
                view.addSubview(button)
            }
            return view
        }
    }
    
    //按键按住不放，持续触发的事件
    func continuousPressedEvent(_ sender: JFButton) {
        //print("\(#function)")
        handleButtonClick(sender)
    }
    
    //按键点击事件
    func clickEvent(_ sender: JFButton) {
        //print("\(#function)")
        handleButtonClick(sender)
    }
    
    func handleButtonClick(_ button: UIButton) {
        if let title = button.currentTitle {
            //print("\(DataUtil.currentTime()) - \(#function) input: \(title)")
            switch title {
            case KEY_TITLES[15]://“删除”键
                //print("删除")
                hexTextField.updateText(text: "")
                break
            case KEY_TITLES[17]://“完成”键
                print("完成")
                if let text = hexTextField.text {
                    hexDelegate?.hexInputDone(hexString: text)
                }
                //返回上一界面
                navigationController?.popViewController(animated: true)
                break
            default:
                hexTextField.updateText(text: title)
                break
            }
        }
    }
}
