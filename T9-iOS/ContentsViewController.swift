//
//  ContentsViewController.swift
//  T9-iOS
//
//  Created by Hrt on 2018/09/23.
//  Copyright © 2018年 HINOMORI HIROYA. All rights reserved.
//

import UIKit

class ContentsViewController: UIViewController {

    var contentsImage:UIImage?
    @IBOutlet weak var contentsImageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentsImageView.image = contentsImage

        //button.backgroundColor = UIColor.blue
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.cornerRadius = 10.0
        button.setTitleColor(.blue,for: UIControlState.normal)
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
