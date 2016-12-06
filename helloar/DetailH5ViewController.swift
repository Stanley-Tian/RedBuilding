//
//  DetailH5ViewController.swift
//  helloar
//
//  Created by 史丹利复合田 on 2016/12/6.
//  Copyright © 2016年 VisionStar Information Technology (Shanghai) Co., Ltd. All rights reserved.
//

import UIKit

class DetailH5ViewController: UIViewController {

    @IBOutlet weak var mainWebView: UIWebView!
    var targetName:String?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(targetName!)
        let myurl = URL(string: targetName!)
        let requestObj = URLRequest(url: myurl!)
        mainWebView.loadRequest(requestObj)
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
