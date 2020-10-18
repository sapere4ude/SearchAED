//
//  ViewController.swift
//  SearchAED
//
//  Created by sapere4ude on 2020/10/07.
//

import UIKit
import Alamofire
import SwiftyXMLParser
import SwiftyJSON

class ViewController: UIViewController {
    @IBOutlet weak var dddddd: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(APIDefine.getSearchInformation())
        
        let xml = try! XML.parse(APIDefine.GET_searchAED_URL_information)
        let qqq = xml["item"]
        print(qqq)
    }
    
    func sendRequest(page:Int,completeHandler:@escaping (XML) -> (),failureHandler:@escaping (String) -> ()) {

        // endIndex 숫자 변경하기
        let url = APIDefine.getSearchInformation()
        
        // 정보를 불러오기만 하는 것이므로 get 방식 사용
        let alamo = AF.request(url, method: .get).validate(statusCode: 200..<300)
        //결과값으로 문자열을 받을 때 사용
        alamo.responseString() { response in
            switch response.result
            {
                
            // 통신 성공
            case .success(let value):   // 주의할 점 : String 타입으로 들어오는걸 Data 타입으로 바꿔줘야한다.
//                let json = JSON.init(value.data(using: .utf8) as Any)
                let xml = try! XML.parse(url)
                completeHandler(xml)

            
            // 통신 실패
            case .failure(let error):
                
                failureHandler(error.localizedDescription)
                print(error)
            }
        }
    }
    
}

