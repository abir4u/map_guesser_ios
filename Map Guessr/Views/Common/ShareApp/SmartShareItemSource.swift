//
//  SmartShareItemSource.swift
//  Map Guessr
//
//  Created by Abir Pal on 02/06/2026.
//

import UIKit
import LinkPresentation

class SmartShareItemSource: NSObject, UIActivityItemSource {
    private let appUrl = URL(string: "https://apps.apple.com/nz/app/map-guessr-challenge/id6764329692")!
    private let appName = "Map Guessr Challenge"
    private let shareMessage = "Try this awesome geography game!"
    private let previewImageName = "map_guessr_image"
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return appUrl
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController) -> Any? {
        return appUrl
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        guard let activityType = activityType else { return appUrl }
        
        let metaApps = [
            UIActivity.ActivityType("com.facebook.Messenger.ShareExtension"),
            UIActivity.ActivityType("com.burbn.instagram.shareextension"),
            UIActivity.ActivityType.postToFacebook
        ]
        
        if metaApps.contains(activityType) {
            return appUrl
        }
        
        return "\(shareMessage)\n\(appUrl.absoluteString)"
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.originalURL = appUrl
        metadata.url = appUrl
        metadata.title = appName
        if let image = UIImage(named: previewImageName) {
            metadata.iconProvider = NSItemProvider(object: image)
        }
        return metadata
    }
}
