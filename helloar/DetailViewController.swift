//
//  DetailViewController.swift
//  helloar
//
//  Created by 史丹利复合田 on 2016/10/12.
//  Copyright © 2016年 VisionStar Information Technology (Shanghai) Co., Ltd. All rights reserved.
//

import UIKit
import AVFoundation

class DetailViewController: UIViewController {
    
    var isPlaying:Bool = false
    var audioPlayer = AVAudioPlayer()
    var timer:Timer!
    var targetError = false
    @IBOutlet weak var nameLabel: UILabel!
    var targetName:String?
    
    @IBOutlet weak var briefTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var playOrPauseButton: UIButton!
    
    @IBAction func clickPlayOrPauseButton(_ sender: UIButton) {
        if isPlaying{
            audioPlayer.pause()
            isPlaying = false
            playOrPauseButton.setImage(UIImage(named:"play"), for: .normal)
        }else{
            audioPlayer.play()
            isPlaying = true
            playOrPauseButton.setImage(UIImage(named:"pause"), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //title = targetName
        targetError = false
        nameLabel.text = targetName
        // Do any additional setup after loading the view.
        //PlistManager.sharedInstance.startPlistManager()
        let path = Bundle.main.bundlePath
        let plistName = "resources.plist"
        let finalPath = (path as NSString).appendingPathComponent(plistName) as NSString
        let cells = NSDictionary(contentsOfFile:finalPath as String)
        
        
        if cells?[targetName!] == nil{
            targetError = true
            return
        }
 
        let currentTarget = cells?[targetName!] as! NSDictionary

        self.title = currentTarget.object(forKey: "name") as? String
        self.briefTextView.text = currentTarget.object(forKey: "brief") as! String!
        self.nameLabel.text = currentTarget.object(forKey: "name") as? String
        self.imageView.image = UIImage(named:currentTarget.object(forKey: "photo") as! String)
        
        let audioPath = Bundle.main.url(forResource: currentTarget.object(forKey: "audio") as! String?, withExtension: "mp3")

        do{
            try audioPlayer = AVAudioPlayer(contentsOf: audioPath!)
            audioPlayer.play()
            isPlaying = true
            playOrPauseButton.setImage(UIImage(named:"pause"), for: .normal)

        }catch{
            print("audio载入出错")
        }
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
