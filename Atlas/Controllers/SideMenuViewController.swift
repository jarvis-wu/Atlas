//
//  SideMenuViewController.swift
//  Atlas
//
//  Created by Jarvis Wu on 2018-11-04.
//

import UIKit
import PPBadgeViewSwift

class SideMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // hardcoded
    let data = [("My places", "like"), ("Navigation", "route"), ("Find it", "placeholder"), ("Lost & Found", "radar"), ("LocoShare", "share"), ("Settings", "settings"), ("Help", "reading")]
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        registerTableViewCells()
        setupUI()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell") as! SideMenuTableViewCell
        cell.iconImageView.image = UIImage(named: data[indexPath.row].1)
        cell.label.text = data[indexPath.row].0
        // TODO: add badges to cell to indicate notifications, hardcoded now for demonstration
        if indexPath.row == 3 {
            cell.pp.addDot(color: UIColor.red)
            cell.pp.moveBadge(x: -25, y: 35)
        } else if indexPath.row == 6 {
            cell.pp.addDot(color: UIColor.red)
            cell.pp.moveBadge(x: -25, y: 35)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    private func registerTableViewCells() {
        let cell = UINib(nibName: "SideMenuTableViewCell", bundle: nil)
        self.tableView.register(cell, forCellReuseIdentifier: "SideMenuTableViewCell")
    }
    
    private func setupUI() {
        // nothing
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 1:
            self.dismiss(animated: true, completion: nil)
        default:
            print("Table view cell is selected at \(indexPath)")
        }
    }

}
