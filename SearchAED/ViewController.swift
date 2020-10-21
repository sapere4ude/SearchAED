//
//  ViewController.swift
//  SearchAED
//
//  Created by sapere4ude on 2020/10/07.
//

import UIKit
import NMapsMap

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let location: [String] = ["서울","경기","인천","충청북도","충청남도","전라북도","전라남도","경상북도","경상남도","강원도","제주"]
    
    // XML 파싱할때 사용
    var parser = XMLParser()
    var currentElement:String = ""
    
    // XML 정보 불러오기
    var items = [String : String]()
    var AEDItems =  [[String : String]]()
    var getAED_Result = AED_Result()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        네이버 지도 불러오기
//        let nmapFView = NMFMapView(frame: view.frame)
//        view.addSubview(nmapFView)
        
        // XML Parsing
        let url: String = APIDefine.GET_searchAED_URL_FullData
        let urlToSend: NSURL = NSURL(string: url)!
        parser = XMLParser(contentsOf: urlToSend as URL)!
        parser.delegate = self
        let success: Bool = parser.parse()
        
        if success {
            print("parse success!")
            print(AEDItems)
        }
        else {
            print("parse failure!")
        }
        
        // Cell 연결
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ResultTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultTableViewCell")
        
        // View 색상 조절
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AEDItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell", for: indexPath) as! ResultTableViewCell
//        cell.orgLabel?.text = getAED_Result.org
//        cell.addressLabel?.text = getAED_Result.buildAddress
        
        cell.orgLabel?.text = AEDItems[indexPath.row]["org"]
        cell.orgLabel.adjustsFontSizeToFitWidth = true
        cell.addressLabel?.text = AEDItems[indexPath.row]["buildAddress"]
        cell.addressLabel.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.modalTransitionStyle = .coverVertical
        
        // 정보 넘겨주기
        vc.getAddress = AEDItems[indexPath.row]["buildAddress"]!
        vc.getBuildPlace = AEDItems[indexPath.row]["buildPlace"]!
        vc.getClerkTel = AEDItems[indexPath.row]["clerkTel"]!
        vc.getManager = AEDItems[indexPath.row]["manager"]!
        
        // 지도 관련
        vc.getLon = AEDItems[indexPath.row]["wgs84Lon"]!
        vc.getLat = AEDItems[indexPath.row]["wgs84Lat"]!
        
        print("\(vc.getLon)")
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return location.count
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return location[section]
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        
        return headerView
    }
    
    
}

extension ViewController: XMLParserDelegate {
    // 시작 태그를 만날때
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        currentElement = elementName
        if elementName == "item" {
            items = [String : String]()
            getAED_Result.buildPlace = ""
            getAED_Result.buildAddress = ""
            getAED_Result.clerkTel = ""
            getAED_Result.manager = ""
            getAED_Result.managerTel = ""
            getAED_Result.mfg = ""
            getAED_Result.model = ""
            getAED_Result.org = ""
            getAED_Result.wgs84Lat = ""
            getAED_Result.wgs84Lon = ""
            getAED_Result.zipcode1 = ""
            getAED_Result.zipcode2 = ""
        }
        
    }
    
    // 닫는 태그를 만날때
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "item" {
            items["buildAddress"] = getAED_Result.buildAddress
            items["buildPlace"] = getAED_Result.buildPlace
            items["clerkTel"] = getAED_Result.clerkTel
            items["manager"] = getAED_Result.manager
            items["managerTel"] = getAED_Result.managerTel
            items["mfg"] = getAED_Result.mfg
            items["model"] = getAED_Result.model
            items["org"] = getAED_Result.org
            items["wgs84Lat"] = getAED_Result.wgs84Lat
            items["wgs84Lon"] = getAED_Result.wgs84Lon
            items["zipcode1"] = getAED_Result.zipcode1
            items["zipcode2"] = getAED_Result.zipcode2
            
            
            AEDItems.append(items)
        }
    }
    
    // 현재 태그에 담긴 string 출력
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        switch currentElement {
        case "buildAddress":
            getAED_Result.buildAddress = string
        case "buildPlace":
            getAED_Result.buildPlace = string
        case "clerkTel":
            getAED_Result.clerkTel = string
        case "manager":
            getAED_Result.manager = string
        case "managerTel":
            getAED_Result.managerTel = string
        case "mfg":
            getAED_Result.mfg = string
        case "model":
            getAED_Result.model = string
        case "org":
            getAED_Result.org = string
        case "wgs84Lat":
            getAED_Result.wgs84Lat = string
        case "wgs84Lon":
            getAED_Result.wgs84Lon = string
        case "zipcode1":
            getAED_Result.zipcode1 = string
        case "zipcode2":
            getAED_Result.zipcode2 = string
        default:
            print("error")
        }
    }
    
    private func parser(parser: XMLParser, parseErrorOccurred parseError: NSError) {
        NSLog("failure error: %@", parseError)
    }
}

