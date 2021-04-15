//
//  Utilities.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import QuartzCore

final class Utilities {

    static func applyBorder(on view: UIView, radius: CGFloat = 16) {

        view.layer.borderColor = UIColor(named: "Border")?.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = radius
        view.layer.masksToBounds = true
    }

    static func drawCorner(on view: UIView) {
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
    }

    static func applyDominantSpeakerBorder(on view: UIView) {
        view.layer.borderColor = UIColor.link.cgColor
        view.layer.borderWidth = 6
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
    }

    static func applySpeakingBorder(on view: UIView) {

        view.layer.borderColor = UIColor.link.withAlphaComponent(0.5).cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
    }

    static func getEndpoint(from endpoint: String) -> String {

        let env = getEnv(from: endpoint)

        return "wss://\(env).100ms.live/ws"
    }

    static func getEnv(from endpoint: String) -> String {

        let env: String

        if endpoint.contains("qa") {
            env = "qa-in"
        } else {
            env = "prod-in"
        }

        return env
    }

    static func getAvatarName(from name: String) -> String {
        let words = name.components(separatedBy: " ")

        var avatar = ""

        for (index, word) in words.enumerated() where index < 2 {
            if let character = word.first {
                avatar += "\(character)"
            }
        }

        if avatar.count == 1 {
            let trimmedName = "\(name.dropFirst())"
            if let nextCharacter = trimmedName.first {
                avatar += "\(nextCharacter)"
            }
        }

        return avatar.uppercased()
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
