//
//  ViewController.swift
//  Greetings
//
//  Created by youerwei on 2022/5/17.
//

import UIKit

class ViewController: UIViewController {
    
    var label1: UILabel?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white;
        // Do any additional setup after loading the view.
        
        self.setupUI();
    }
    
    func setupUI() {
        let size = CGSize(width: 200, height: 60);
        let origin = CGPoint(x: self.view.frame.size.width / 2 - 100, y: 150);
        let button1 = UIButton(frame: CGRect(origin: origin, size: size));
        button1.isHidden = false;
        button1.backgroundColor = .gray;
        button1.setTitle("Rust FFI Test", for: .normal);
        button1.titleLabel?.textColor = .white;
        button1.layer.cornerRadius = 8;
        button1.addTarget(self, action: #selector(button1Click(_:)), for: .touchUpInside);
        self.view.addSubview(button1);
        
        let origin2 = CGPoint(x: self.view.frame.size.width / 2 - 100, y: 230);
        let button2 = UIButton(frame: CGRect(origin: origin2, size: size));
        button2.isHidden = false;
        button2.backgroundColor = .gray;
        button2.setTitle("Protobuf Network Test", for: .normal);
        button2.titleLabel?.textColor = .white;
        button2.layer.cornerRadius = 8;
        button2.addTarget(self, action: #selector(button2Click(_:)), for: .touchUpInside);
        self.view.addSubview(button2);
        
        let origin3 = CGPoint(x: self.view.frame.size.width / 2 - 150, y: 330);
        self.label1 = UILabel(frame: CGRect(origin: origin3, size: CGSize(width: 300, height: 500)));
        self.label1?.isHidden = false;
        self.label1?.numberOfLines = 0;
        self.view.addSubview(self.label1!);
    }
    
    @objc func button1Click (_ button: UIButton) {
        // you can't capture context in C API callback called by Swift, so it's necessary to convert the context (as self:ViewController here) to a void pointer, and pass it to C API, then get the context back from C API callback
        let ctx = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque());
        async_callback(ctx) { callback_ctx, arg1, arg2 in
            guard let ctx = callback_ctx else {
                return
            }
            let mySelf = Unmanaged<ViewController>.fromOpaque(ctx).takeUnretainedValue();
            mySelf.label1?.text = "arg1: \(arg1), arg2: \(arg2)";
        }
    }
    
    @objc func button2Click (_ button: UIButton) {
        var myReq = MyRequest();
        myReq.groupName = "CJPay";
        myReq.state = .merged;
        myReq.authorName = "youerwei";
        do {
            // serialize
            let reqData = try myReq.serializedData();
            let reqBytes = [UInt8](reqData);
            
            // send request by rust
            let ctx = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque());
            my_request(ctx, reqBytes, Int32(reqBytes.count)) { callback_ctx, resPointer in
                NSLog("async callback")
                guard let ctx = callback_ctx, let res = resPointer else {
                    return
                }
                
                let mySelf = Unmanaged<ViewController>.fromOpaque(ctx).takeUnretainedValue();
                let resData = String(cString: res).data(using: .utf8);
                do {
                    let myRes = try MyResponse(serializedData: resData!);
                    mySelf.label1?.text = myRes.debugDescription;
                }
                catch {
                    print("serialized errror")
                }
            };
            NSLog("async test")
//            let resPointer = my_request(reqBytes, Int32(reqBytes.count));
//
//            // deserialize
//            let resData = String(cString: resPointer!).data(using: .utf8);
//            let myRes = try MyResponse(serializedData: resData!);
//
//            self.label1?.text = myRes.debugDescription;
        }
        catch {
            print("serialized errror")
        }
    }
}

