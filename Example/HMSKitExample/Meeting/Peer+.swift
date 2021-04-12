//
//  Peer.swift
//  HMSKitExample
//
//  Created by Yogesh Singh on 11/04/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSKit

extension HMSPeer {
    var isPinned: Bool {
        get {
            if let isPinned = customerDescription?["isPinned"] as? Bool {
                return isPinned
            }
            return false
        }
        set {
            if customerDescription == nil {
                customerDescription = [AnyHashable: Any]()
            }
            customerDescription?["isPinned"] = newValue
        }
    }
}
