//
//  HMSPeer+.swift
//  HMSKitExample
//
//  Created by Yogesh Singh on 08/04/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation
import HMSKit

extension HMSPeer {
    var isPinned: Bool {
        get {
            return self.isPinned
        }
        set {
            self.isPinned = newValue
        }
    }
}
