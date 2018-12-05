//
//  LocationManagerController.swift
//  GTCatalog
//
//  Created by liuxc on 2018/12/3.
//

import UIKit
import GTToolKit

class LocationManagerController: UIViewController {

    var locationRequestID: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "定位管理类"

        GTLocationManager.sharedInstance().setShowsBackgroundLocationIndicator(true)
        GTLocationManager.sharedInstance().setPausesLocationUpdatesAutomatically(false)


        locationRequestID = GTLocationManager.sharedInstance().requestLocation(withDesiredAccuracy: .block, timeout: 0, delayUntilAuthorized: true) { (location, accuary, locationStatus) in
            if locationStatus == .success {
                GTLocationManager.sharedInstance().requestGeocoder(with: location!, block: { (address, status) in
                    if (status == .success) {
                        print(status)
                    }
                });
            }
        }


    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //取消定位请求
        GTLocationManager.sharedInstance().cancelLocationRequest(locationRequestID);
    }




    @objc class func catalogMetadata() -> NSDictionary {
        return [
            "breadcrumbs": ["LocationManager"],
            "primaryDemo": true,
            "presentable": true
        ]
    }
}
