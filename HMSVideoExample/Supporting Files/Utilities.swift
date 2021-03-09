//
//  Utilities.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import QuartzCore

class Utilities {

    static func applyBorder(on view: UIView, radius: CGFloat = 16) {
        if #available(iOS 11.0, *) {
            view.layer.borderColor = UIColor(named: "Border")?.cgColor
        } else {
            view.layer.borderColor = UIColor.black.cgColor
        }

        view.layer.borderWidth = 1
        view.layer.cornerRadius = radius
        view.layer.masksToBounds = true
    }

    static func drawCorner(on view: UIView) {
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
    }

    static func applySpeakerBorder(on view: UIView) {

        if #available(iOS 13.0, *) {
            view.layer.borderColor = UIColor.link.cgColor
        } else {
            view.layer.borderColor = UIColor.blue.cgColor
        }
        view.layer.borderWidth = 4
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
    }
}

protocol ErrorProtocol: LocalizedError {
    var title: String { get }
    var code: Int? { get }
    var localizedDescription: String { get }

}

struct CustomError: ErrorProtocol {
    var title: String = "Error"
    var code: Int?
    var localizedDescription: String {
        title
    }
}

enum MeetingFlow {
    case join, start
}

enum Layout {
    case grid, portrait
}

enum VideoCellState {
    case insert(index: Int)
    case delete(index: Int)
    case refresh(indexes: (Int, Int))
}
