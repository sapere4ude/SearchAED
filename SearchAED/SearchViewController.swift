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
    var items = [String : String]()
    var AEDItems =  [[String : String]]()
    
    lazy var result_AEDItems = [[String : String]]()
    
    var getAED_Result = AED_Result()
    
    var queryText: String?  // 받아오는 검색어
    
    
    // XML 파싱할때 사용
    var parser = XMLParser()
    var strXMLData: String? = "" // xml데이터를 저장
    var currentElement:String = ""
    var item: AED_Result? = nil
    
    
    // 넘겨줄때
    var getSearchText: String = ""
    
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
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
    }
    
    func searchAED(search_text: String, completionHandler:@escaping (String) -> (), failureHandler:@escaping (String) ->() ) {
        
        let url: String = APIDefine.GET_searchAED_URL_information + "&Q1=" + search_text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        //getSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        //print("\(url)")
        
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
                
                //print("search에서 확인",self.strXMLData as Any)
                //print(self.AEDItems)
                //print("총 개수:",self.AEDItems.count)
                self.result_AEDItems += self.AEDItems
                //print("검색결과->", self.result_AEDItems)
                completionHandler("성공")
                
                if self.AEDItems.count == 0 {
                    self.tableView.isHidden = true
                    self.noResultLabel.isHidden = false
                }
                
                self.AEDItems.removeAll()
                
            } else {
                print("parse failure!")
                failureHandler("실패")
            }
        }
        task.resume()
    }
    
    
    func initUI() {
        searchBar.placeholder = "시·군·구 중 하나를 입력하세요"
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
        //print(#function)
        return result_AEDItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print(#function)
        let cell: ResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell", for: indexPath) as! ResultTableViewCell
        
        cell.orgLabel?.text = self.result_AEDItems[indexPath.row]["org"]
        cell.orgLabel.adjustsFontSizeToFitWidth = true
        
        cell.addressLabel?.text = self.result_AEDItems[indexPath.row]["buildAddress"]
        cell.addressLabel.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(#function)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.modalTransitionStyle = .coverVertical
        
        // 정보 넘겨주기
        vc.getAddress = self.result_AEDItems[indexPath.row]["buildAddress"]!
        vc.getBuildPlace = self.result_AEDItems[indexPath.row]["buildPlace"]!
        vc.getClerkTel = self.result_AEDItems[indexPath.row]["clerkTel"]!
        
        
        guard let number = URL(string: "tel://" + vc.getClerkTel) else { return }
        UIApplication.shared.open(number)
        
        vc.getManager = self.result_AEDItems[indexPath.row]["manager"]!
        
        // 지도 관련
        vc.getLon = self.result_AEDItems[indexPath.row]["wgs84Lon"]!
        vc.getLat = self.result_AEDItems[indexPath.row]["wgs84Lat"]!
        
        
        //print("\(vc.getLon)")
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 10))
        
        return headerView
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //print(#function)
        
        self.result_AEDItems.removeAll() // result_AEDItems에는 기존의 값이 있기때문에 전부 초기화 시켜주는 작업을 먼저 진행한다!
        
        noResultLabel.isHidden = true
        
        guard let query = searchBar.text, !query.replacingOccurrences(of: "", with: "").isEmpty else {
            noResultLabel.isHidden = true
            tableView.isHidden = true // check
            return
        }
        
        getSearchText = String(searchBar.text!)
        
        searchBar.resignFirstResponder()
        
        // indicator show
        self.indicator.isHidden = true
        indicator.startAnimating()
                        
            //print("검색데이터->",query)
            
            self.searchAED(search_text: query,completionHandler: { success in
              print("success : \(success)")
                
                DispatchQueue.main.async {  // 비동기 -> 비동기 안에 indicator를 멈춰줘야함
                    self.indicator.stopAnimating()
                    self.indicator.isHidden = true
                }
                if self.result_AEDItems.isEmpty {
                    self.tableView.isHidden = true
                    self.noResultLabel.isHidden = false
                } else {
                    self.tableView.isHidden = false
                }
                
            },failureHandler: { error in
                self.indicator.isHidden = true
                print("error: \(error)")
            })
        }
    
    // 갑자기 안돌아가는 것
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
                self.searchAED(search_text: getSearchText, completionHandler: { success in
                  print("success : \(success)")
                    
                },failureHandler: { error in
                    print("error: \(error)")
                })
            }
        }
    }
}

extension SearchViewController: XMLParserDelegate {
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
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.contentOffset = .zero
            }
        }
        
    }
    
    // 현재 태그에 담긴 string 출력
    func parser(_ parser: XMLParser, foundCharacters string: String) {
//       currentElement += string
        
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
            break
        }
    }
    
    private func parser(parser: XMLParser, parseErrorOccurred parseError: NSError) {
        NSLog("failure error: %@", parseError)
    }
}

