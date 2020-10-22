//
//  SearchViewController.swift
//  SearchAED
//
//  Created by sapere4ude on 2020/10/20.
//

import UIKit
import NVActivityIndicatorView

class SearchViewController: UIViewController {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    var queryText: String?  // 받아오는 검색어

    // API를 통해 받아온 결과를 저장함
    var items = [String : String]()
    var AEDItems =  [[String : String]]()
    
    
    // XML 파싱할때 사용
    var strXMLData: String? = "" // xml데이터를 저장
    var currentElement:String = ""
    
    private let noResultLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "검색 결과가 없습니다!"
        label.sizeToFit()
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    //MARK:paging
    let queryOnceCnt:Int = 10
    var currentPage:Int = 0
    let callNextPageBeforeOffset:CGFloat = 150
    var isQuery:Bool = false
    var reachEnd:Bool = false
    
    var searchText:String = ""
    
    // XML 정보 불러오기
//    var items = [String : String]()
//    var AEDItems =  [[String : String]]()
//    var getAED_Result = AED_Result()
    
    
    let indicator = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 20, y: UIScreen.main.bounds.height/2, width: 50, height: 50),
                                            type: .ballBeat,
                                            color: .systemPink,
                                            padding: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        
        // XML Parsing
//        let url: String = APIDefine.GET_searchAED_URL_FullData
//        let urlToSend: NSURL = NSURL(string: url)!
//        parser = XMLParser(contentsOf: urlToSend as URL)!
//        parser.delegate = self
//        let success: Bool = parser.parse()
//
//        if success {
//            print("parse success!")
//            print(AEDItems)
//        }
//        else {
//            print("parse failure!")
//        }
        
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    
    
    // 새롭게 추가하고 있는 것 2020.10.22
    func searchAED() {
        var items = [String : String]()
        var AEDItems =  [[String : String]]()
        var getAED_Result = AED_Result()
        
        let url: String = APIDefine.GET_searchAED_URL_FullData
        let urlToSend: NSURL = NSURL(string: url)!
        
        var request = URLRequest(url: urlToSend as URL)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 에러가 있으면 리턴
            guard error == nil else {
                print(error)
                return
            }
            
            // 데이터가 비었으면 출력 후 리턴
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            // 데이터 초기화
            getAED_Result.buildAddress = ""
            getAED_Result.buildPlace = ""
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
            
            // Parse the XML
            let parser = XMLParser(data: Data(data))
            parser.delegate = self
            let success:Bool = parser.parse()
            if success {
                print(self.strXMLData)
            } else {
                print("parse failure!")
            }
        }
        task.resume()
    }
    
    
    func initUI() {
        searchBar.placeholder = "지역을 입력하세요"
        tableView.isHidden = true
        self.view.addSubview(indicator)
        self.view.addSubview(noResultLabel)
        
        tableView.register(UINib(nibName: "ResultTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultTableViewCell")
    }
    
    override func viewDidLayoutSubviews() {

        noResultLabel.frame = CGRect(x: 120,
                                     y: 450,
                                     width: 150,
                                     height: 50)
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
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

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(#function)
        noResultLabel.isHidden = true
        guard let text = searchBar.text, !text.replacingOccurrences(of: "", with: "").isEmpty else {
            noResultLabel.isHidden = true
            return
        }
        
        searchText = text   // sendRequst 함수에서 만들어진 값을 전역변수로 넘겨주는 역할
        
        searchBar.resignFirstResponder()
        
        //indicator show
        self.indicator.isHidden = true
        indicator.startAnimating()
        DispatchQueue.main.async {
            
            // 여기에 검색 텍스트가 있을 경우 보여주는 것 코드 만들기
            
//            if self.AEDItems.contains(["buildAddress":self.searchText]) {
//                switch self.searchText {
//                case "":
//                    //AEDItems.append()
//                default:
//
//                }
//            }
            
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
            }
            if self.AEDItems.isEmpty {
                self.tableView.isHidden = true
                self.noResultLabel.isHidden = false
            } else {
                self.tableView.isHidden = false
            }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == nil {
            noResultLabel.isHidden = true
        }
    }
    
    // 스크롤했을때 새로운 페이지 보여주는 방법
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollView:\(scrollView.contentOffset.y)")
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        let y = offset.y + bounds.size.height - inset.bottom
        let h = size.height
        
        if y + self.callNextPageBeforeOffset >= h {
            if !self.isQuery && !self.reachEnd {
            }
        }
    }
}

extension SearchViewController: XMLParserDelegate {
    // 시작 태그를 만날때
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        currentElement = elementName
        if elementName == "buildAddress" || elementName == "buildPlace" || elementName == "clerkTel" || elementName == "manager" || elementName == "managerTel" || elementName == "mfg" || elementName == "model" || elementName == "org" || elementName == "wgs84Lat" || elementName == "wgs84Lon" || elementName == "zipcode1" || elementName == "zipcode2" {
            currentElement = ""
            if elementName == "buildAddress" {
                items = AED_Result()
            }
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
