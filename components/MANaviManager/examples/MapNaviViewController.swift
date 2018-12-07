//
//  MapNaviViewController.swift
//  GTCatalog
//
//  Created by liuxc on 2018/12/6.
//

import UIKit
import GTToolKit

class MapNaviViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "定位管理类"

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            let start = AMapNaviPoint()
            start.latitude = 30.2750500000
            start.longitude = 119.9903000000

            let end = AMapNaviPoint()
            end.latitude = 30.2864900000
            end.longitude = 120.0053900000

            ThirdPartyNaviManager.shared().createOptionMenuStartLocation(start, endLocation: end, stationName: "哈哈")
        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc class func catalogMetadata() -> NSDictionary {
        return [
            "breadcrumbs": ["MANaviManager"],
            "primaryDemo": true,
            "presentable": true
        ]
    }

}
