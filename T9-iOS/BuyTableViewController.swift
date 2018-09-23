//
//  BuyTableViewController.swift
//  T9-iOS
//
//  Created by Hrt on 2018/09/22.
//  Copyright © 2018年 HINOMORI HIROYA. All rights reserved.
//

import UIKit

class BuyTableViewController: UITableViewController, UITextFieldDelegate {

    var selectedImage:UIImage?
    var btc:BitcoinController?
    
    @IBOutlet var buyContentsViews: [BuyContentsView]!

    override func viewDidLoad() {
        super.viewDidLoad()

        buyContentsViews[0].setImage(name: "image0")
        buyContentsViews[1].setImage(name: "image1")
        buyContentsViews[2].setImage(name: "image2")
        buyContentsViews[3].setImage(name: "image3")

        btc = BitcoinController()
        btc?.initalize()

        for i in 0..<buyContentsViews.count {
            buyContentsViews[i].contentsID = i.description
            btc?.checkAuth(contentsID: i.description, responseHandler: { (auth) in
                print("\(i) \(auth)")
                buyContentsViews[i].isPurchased = auth
            })
        }

//        for i in 0..<10 {
//            btc?.checkAuth(contentsID: i.description, responseHandler: { (auth) in
//                print("\(i) \(auth)")
//            })
//        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

   
    override func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        if buyContentsViews[indexPath.row].isPurchased {
            selectedImage = buyContentsViews[indexPath.row].imageView.image
            performSegue(withIdentifier: "toContentsViewController",sender: nil)
        } else {
            let alertController = UIAlertController(title: "",message: "譲渡されてません", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            }
            //let cancelButton = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(okAction)
            //alertController.addAction(cancelButton)
            present(alertController,animated: true,completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toContentsViewController") {
            let vc: ContentsViewController = (segue.destination as? ContentsViewController)!
            vc.contentsImage = selectedImage
        }
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
