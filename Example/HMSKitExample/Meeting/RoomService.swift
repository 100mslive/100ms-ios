//
//  RoomService.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 05/03/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation

struct RoomService {

    static func setup(for flow: MeetingFlow,
                      _ user: String,
                      _ room: String,
                      completion: @escaping (String?, String?) -> Void) {

        switch flow {
        case .join:
            getToken(for: user, room) { (token, roomID) in
                completion(token, roomID)
            }

        case .start:

            createRoom(user, room) { (roomID, error) in

                guard error == nil, let roomID = roomID
                else {
                    let error = error ?? CustomError(title: "Create Room Error")
                    print(#function, "Error: ", error.localizedDescription)
                    NotificationCenter.default.post(name: Constants.hmsError,
                                                    object: nil,
                                                    userInfo: ["Error": error])
                    completion(nil, nil)
                    return
                }

                getToken(for: user, roomID) { (token, roomID) in
                    completion(token, roomID)
                }
            }
        }
    }

    // MARK: - Room Token

    private static func getToken(for user: String, _ room: String, completion: @escaping (String?, String?) -> Void) {

        requestToken(for: user, room) { token, error in

            guard error == nil, let token = token
            else {
                let error = error ?? CustomError(title: "Fetch Token Error")
                print(#function, "Error: ", error.localizedDescription)
                NotificationCenter.default.post(name: Constants.hmsError,
                                                object: nil,
                                                userInfo: ["Error": error])
                completion(nil, nil)
                return
            }
            completion(token, room)
        }
    }

    private static func requestToken(for user: String,
                                     _ roomID: String,
                                     completion: @escaping (String?, Error?) -> Void) {

        /*
        if let request = createRequest(for: Constants.getTokenURL, user, roomID) {

            URLSession.shared.dataTask(with: request) { data, response, error in

                guard error == nil, response != nil, let data = data else {
                    print(#function, error?.localizedDescription ?? "Unexpected Error")
                    completion(nil, error ?? CustomError(title: "No response"))
                    return
                }

                let (parsedData, error) = parseResponse(data, for: Constants.tokenKey)

                DispatchQueue.main.async {
                    completion(parsedData, error)
                }
            }.resume()
        }
         */

        completion(Token.getWith(roomID), nil)
    }

    // MARK: - Create Room

    private static func createRoom(_ user: String,
                                   _ roomName: String,
                                   completion: @escaping (String?, Error?) -> Void) {

        let cleanedRoomName = roomName.replacingOccurrences(of: " ", with: "")

        if let request = createRequest(for: Constants.createRoomURL, user, cleanedRoomName) {
            URLSession.shared.dataTask(with: request) { data, response, error in

                guard error == nil, response != nil, let data = data else {
                    print(#function, error?.localizedDescription ?? "Unexpected Error")
                    completion(nil, error ?? CustomError(title: "No response"))
                    return
                }

                let (parsedData, error) = parseResponse(data, for: Constants.idKey)
                completion(parsedData, error)
            }.resume()
        }
    }

    // MARK: - Service Helpers

    private static func createRequest(for url: String, _ user: String, _ room: String) -> URLRequest? {

        guard let url = URL(string: url)
        else {
            print("Error: ", #function, "Get Token & Socket Endpoint URLs are incorrect")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let env = Utilities.getEnv(from: Constants.endpoint)

        let body = [  "room_id": room,
                      "user_name": user,
                      "role": "guest",
                      "env": env  ]

        print(#function, "URL: ", url, "\nBody: ", body)

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch {
            print("Error: ", #function, "Incorrect body parameters provided")
            print(error.localizedDescription)
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        return request
    }

    private static func parseResponse(_ data: Data, for key: String) -> (String?, Error?) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data,
                                                           options: .mutableContainers) as? [String: Any] {

                print(#function, "JSON: ", json)

                if let value = json[key] as? String {
                    return (value, nil)
                } else {
                    return(nil, CustomError(title: "Unexpectedly found nil for key: \(key)"))
                }
            }
        } catch {
            print(#function, error.localizedDescription)
            return(nil, CustomError(title: error.localizedDescription))
        }

        return (nil, CustomError(title: "Unexpected Data Format"))
    }
}
