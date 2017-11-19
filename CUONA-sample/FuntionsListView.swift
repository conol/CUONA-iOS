//
//  FuntionsListView.swift
//  CUONA-sample
//
//  Created by mizota takaaki on 2017/11/17.
//  Copyright © 2017 conol, Inc. All rights reserved.
//

import UIKit

class FuntionsListView: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return titles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath)

        let index = indexPath.row
        cell.textLabel?.text = titles[index] as String?
        cell.detailTextLabel?.text = details[index] as String?
        cell.imageView?.image = UIImage(named: "\(icons[index])")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let back = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = back
        
        let view = storyboard?.instantiateViewController(withIdentifier: "\(views[indexPath.row])")
        view?.title = titles[indexPath.row]
        navigationController?.pushViewController(view!, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80
    }
}
