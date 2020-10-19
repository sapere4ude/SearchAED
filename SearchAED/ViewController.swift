//
//  ViewController.swift
//  SearchAED
//
//  Created by sapere4ude on 2020/10/07.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var dddddd: UILabel!
    
    // XML 파싱할때 사용
    var parser = XMLParser()
    var currentElement:String = ""
    
    // XML 정보 불러오기
    var items = [String : String]()
    var AEDItems =  [[String : String]]()
    var getAED_Result = AED_Result()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url: String = APIDefine.GET_searchAED_URL_information
        
        let urlToSend: NSURL = NSURL(string: url)!
        
        // Parse the XML
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            string
        }
    }
    
    private func parser(parser: XMLParser, parseErrorOccurred parseError: NSError) {
        NSLog("failure error: %@", parseError)
    }
}

