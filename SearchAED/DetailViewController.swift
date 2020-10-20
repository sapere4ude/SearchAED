//
//  DetailViewController.swift
//  SearchAED
//
//  Created by sapere4ude on 2020/10/19.
//

import UIKit
import NMapsMap

class DetailViewController: UIViewController {
    
    var getAddress: String = ""
    var getClerkTel: String = ""
    var getBuildPlace: String = ""
    var getManager: String = ""
    
    var getLat: String = ""
    var getLon: String = ""
    
    @IBOutlet weak var mapView: NMFMapView!
    @IBOutlet var detailView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var clerkTelLabel: UILabel!
    @IBOutlet weak var buildPlaceLabel: UILabel!
    @IBOutlet weak var managerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()

        // Do any additional setup after loading the view.
    }
    
    func initUI() {
        
        detailView.backgroundColor = .systemBackground
        addressLabel.adjustsFontSizeToFitWidth = true
        addressLabel?.text = getAddress
        clerkTelLabel.adjustsFontSizeToFitWidth = true
        clerkTelLabel?.text = getClerkTel
        buildPlaceLabel.adjustsFontSizeToFitWidth = true
        buildPlaceLabel?.text = getBuildPlace
        managerLabel.adjustsFontSizeToFitWidth = true
        managerLabel?.text = "관리자: " + getManager

        let param = NMFCameraUpdateParams()
        param.scroll(to: NMGLatLng(lat: Double(getLat)!, lng: Double(getLon)!))
        param.zoom(to: 16)
        param.tilt(to: 0)
        param.rotate(to: 90)
        mapView.moveCamera(NMFCameraUpdate(params: param))
        mapView.isIndoorMapEnabled = true
        
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: Double(getLat)!, lng: Double(getLon)!)
        marker.mapView = mapView
        marker.iconImage = NMFOverlayImage(image: (UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withTintColor(.systemRed, renderingMode: .alwaysOriginal))!)
        marker.iconTintColor = .systemPink
        
        
        
    }

}
