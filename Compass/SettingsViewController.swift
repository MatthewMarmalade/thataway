//
//  SettingsViewController.swift
//  Compass
//
//  Created by Matthew Marsland on 9/4/19.
//  Copyright © 2019 Tectane. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    let defaults:UserDefaults = UserDefaults.standard
    @IBOutlet weak var distanceUnit     : UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distanceUnit.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Charter", size: 12.0)!], for: .normal)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let km = defaults.bool(forKey: "km")
        if km {
            distanceUnit.selectedSegmentIndex = 0
        } else {
            distanceUnit.selectedSegmentIndex = 1
        }
    }

    @IBAction func distanceUnitChanged(_ sender: UISegmentedControl) {
        let km = sender.selectedSegmentIndex == 0
        defaults.set(km, forKey: "km")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
