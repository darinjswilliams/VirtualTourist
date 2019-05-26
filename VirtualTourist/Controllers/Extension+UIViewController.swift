//
//  Extension+UIViewController.swift
//  VirtualTourist
//
//  Created by Darin Williams on 5/19/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
        
        func showFailure(message: String) {
            let alertVC = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alertVC, animated: true)
        }
    
}
