//
//  FirebaseInteractor.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 04/03/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation
import Firebase

final class FirebaseInteractor {

    @discardableResult init() {
        FirebaseApp.configure()
    }
}