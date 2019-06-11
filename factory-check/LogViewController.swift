//
//  LogViewController.swift
//  factory-check
//
//  Created by mizota takaaki on 2019/06/11.
//  Copyright © 2019 conol, Inc. All rights reserved.
//

import UIKit

class LogViewController: UITableViewController {
    
    var logs:[[String:Any]]?
    var dateLabel:UILabel?
    var ImageView:UIImageView?
    var titleLabel:UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logs = ud.array(forKey: "logs") as? [[String:Any]]
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return logs?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "log", for: indexPath) as! LogViewCell
        let dict = logs?[indexPath.row]
        
        if logs == nil {
            cell.textLabel?.text = "ログデータがありません"
            cell.textLabel?.textColor = .gray
            cell.textLabel?.textAlignment = .center
            
        } else {
            cell.datetime.text = dict?["time"] as? String
            cell.ImageView.image = UIImage(named: dict?["type"] as! String)
            cell.message.text = dict?["message"] as? String
            
            let data = dict?["data"] as! String
            if data != "" {
                cell.message.text = data
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
