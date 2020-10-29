//
//  SettingViewController.swift
//  SearchAED
//
//  Created by sapere4ude on 2020/10/29.
//

import UIKit

class SettingViewController: UIViewController {

    let menu = ["AED 사용법 영상보기", "버전 정보", "개발자 정보"]
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SettingTableViewCell

        cell.settingLabel.text = menu[indexPath.row]
        return cell
    }
    
    
}
