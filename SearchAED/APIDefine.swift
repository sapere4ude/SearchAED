//
//  APIDefine.swift
//  SearchAED
//
//  Created by sapere4ude on 2020/10/07.
//

import Foundation
import Alamofire
import SwiftyXMLParser



class APIDefine: NSObject {
    
    static let searchAED_URL_information = "http://apis.data.go.kr/B552657/AEDInfoInqireService/getEgytAedManageInfoInqire?" // 관리정보 조회
    
    static let searchAED_URL_Location = "http://apis.data.go.kr/B552657/AEDInfoInqireService/getAedLcinfoInqire" // 위치정보 조회
    
    static let searchAED_URL_FullData = "http://apis.data.go.kr/B552657/AEDInfoInqireService/getAedFullDown" // 모든 데이터 가져오기
    
    // 인증받은 key값
    static let KEY: String = "iUxao104ymKQUz5r%2FtNLfMYhq70wJrTQeK8qN3JpJ22J%2Fi0QLW80iuVsJbtMOcdbspIiv%2FeFic1cE7Xrpx%2F%2Fwg%3D%3D"
    
    
    // postman
//    http://apis.data.go.kr/B552657/AEDInfoInqireService/getEgytAedManageInfoInqire?Servicekey=iUxao104ymKQUz5r%2FtNLfMYhq70wJrTQeK8qN3JpJ22J%2Fi0QLW80iuVsJbtMOcdbspIiv%2FeFic1cE7Xrpx%2F%2Fwg%3D%3D&pageNo=2&numOfRows=100
    
    static let GET_searchAED_URL_information = searchAED_URL_information + "Servicekey=" + KEY + "&pageNo=2" + "&numOfRows=100"
    
    static func getSearchInformation() -> String {
        var apiAddr: String = ""
        apiAddr = GET_searchAED_URL_information
        return apiAddr
    }
}
