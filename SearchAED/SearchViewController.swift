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
    

    // API를 통해 받아온 결과를 저장함
//    var items = [String : String]()
//    var AEDItems =  [[String : String]]()
    
    var AEDItems:[AED_Result] = []
    var queryText: String?  // 받아오는 검색어
    
    
    // XML 파싱할때 사용
    var strXMLData: String? = "" // xml데이터를 저장
    var currentElement:String = ""
    var item: AED_Result? = nil
    
    // 전역변수로 활용
    var qqq: AED_Result? = nil
    var qqqItems:[AED_Result] = []
    
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
    
    
    let indicator = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 20, y: UIScreen.main.bounds.height/2, width: 50, height: 50),
                                            type: .ballBeat,
                                            color: .systemPink,
                                            padding: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
//        searchAED()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }

    
    // 새롭게 추가하고 있는 것 2020.10.22
    func searchAED(search_text: String) {
        
        var items = [String : String]()
        var AEDItems =  [[String : String]]()
        var getAED_Result = AED_Result()
        
        let url: String = APIDefine.GET_searchAED_URL_FullData + "&Q1=" + search_text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print("\(url)")
        let urlToSend: NSURL = NSURL(string: url)!
        
        let request = URLRequest(url: urlToSend as URL)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 에러가 있으면 리턴
            guard error == nil else {
                print(error as Any)
                return
            }
            
            // 데이터가 비었으면 출력 후 리턴
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            // 데이터 초기화
            self.item?.buildAddress = ""
            self.item?.buildAddress = ""
            self.item?.buildPlace = ""
            self.item?.clerkTel = ""
            self.item?.manager = ""
            self.item?.managerTel = ""
            self.item?.mfg = ""
            self.item?.model = ""
            self.item?.org = ""
            self.item?.wgs84Lat = ""
            self.item?.wgs84Lon = ""
            self.item?.zipcode1 = ""
            self.item?.zipcode2 = ""
            
            // Parse the XML
            let parser = XMLParser(data: Data(data))
            parser.delegate = self
            let success:Bool = parser.parse()
            if success {
                print(self.strXMLData as Any)
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
        
        let AEDItem = AEDItems[indexPath.row]
        
        cell.orgLabel?.text = AEDItem.org
        cell.orgLabel.adjustsFontSizeToFitWidth = true
        cell.addressLabel?.text = AEDItem.buildAddress
        cell.addressLabel.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.modalTransitionStyle = .coverVertical
        
        // 정보 넘겨주기
        
        let AEDItem = AEDItems[indexPath.row]
        
        vc.getAddress = AEDItem.buildAddress
        vc.getBuildPlace = AEDItem.buildPlace
        vc.getClerkTel = AEDItem.clerkTel
        vc.getManager = AEDItem.manager
        
        // 지도 관련
        vc.getLon = AEDItem.wgs84Lon
        vc.getLat = AEDItem.wgs84Lat
        
        print("\(vc.getLon)")
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        
        return headerView
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(#function)
        noResultLabel.isHidden = true
        guard let query = searchBar.text, !query.replacingOccurrences(of: "", with: "").isEmpty else {
            noResultLabel.isHidden = false
            return
        }
        
        //searchText = text   // sendRequst 함수에서 만들어진 값을 전역변수로 넘겨주는 역할
        
        searchBar.resignFirstResponder()
        
        //indicator show
        self.indicator.isHidden = true
//        indicator.startAnimating()
        
        self.searchAED(search_text: query)
        
//        DispatchQueue.main.async {
            
            // 여기에 검색 텍스트가 있을 경우 보여주는 것 코드 만들기
            print("query->",query)
            
//            self.searchAED(search_text: query)
            
//                self.tableView.reloadData()
//            }
        
            
//            DispatchQueue.main.async {
//                self.indicator.stopAnimating()
//                self.indicator.isHidden = true
//            }
//            if self.AEDItems.isEmpty {
//                self.tableView.isHidden = true
//                self.noResultLabel.isHidden = false
//            } else {
//                self.tableView.isHidden = false
//            }
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
                item = AED_Result()
            }
        }
        
    }
    
    // 닫는 태그를 만날때
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "buildAddress" {
            item?.buildAddress = currentElement.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        } else if elementName == "buildPlace" {
            item?.buildPlace = currentElement
        } else if elementName == "clerkTel" {
            item?.clerkTel = currentElement
        } else if elementName == "manager" {
            item?.manager = currentElement
        } else if elementName == "managerTel" {
            item?.managerTel = currentElement
        } else if elementName == "mfg" {
            item?.mfg = currentElement
        } else if elementName == "model" {
            item?.model = currentElement
        } else if elementName == "org" {
            item?.org = currentElement
        } else if elementName == "wgs84Lat" {
            item?.wgs84Lat = currentElement
        } else if elementName == "wgs84Lon" {
            item?.wgs84Lon = currentElement
        } else if elementName == "zipcode1" {
            item?.zipcode1 = currentElement
        } else if elementName == "zipcode2" {
            item?.zipcode2 = currentElement
            AEDItems.append(self.item!)
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
        }
    }
    
    // 현재 태그에 담긴 string 출력
    func parser(_ parser: XMLParser, foundCharacters string: String) {
       currentElement += string
       
    }
    
    private func parser(parser: XMLParser, parseErrorOccurred parseError: NSError) {
        NSLog("failure error: %@", parseError)
    }
}
