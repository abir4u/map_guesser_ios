//
//  UIApplication+Extension.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import UIKit

extension UIApplication {
    var rootViewController: UIViewController? {
        return self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
