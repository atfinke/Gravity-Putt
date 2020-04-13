//
//  SaveUtility.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 4/8/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Foundation

struct SaveUtility {

    // MARK: - Properties -

    static private let sceneURL: URL = {
        #if os(macOS)
        let dir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Gravity Golf")
        try? FileManager.default
            .createDirectory(at: dir,
                             withIntermediateDirectories: true,
                             attributes: nil)
        #else
        let dir = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
        #endif
        let url = dir.appendingPathComponent("scene_data")
        print("Using data @ \(url)")
        return url
    }()

    static private let saveQueue = DispatchQueue(label: "com.andrewfinke.save", qos: .utility)

    // MARK: - Helpers -

    static func loadScene() -> GameScene {
        guard Debugging.isLoadingOn else {
            return GameScene()
        }
        do {
            #if os(tvOS)
            let data = UserDefaults.standard.data(forKey: "data") ?? Data()
            #else
            let data = try Data(contentsOf: SaveUtility.sceneURL)
            #endif
            let scene = try JSONDecoder().decode(GameScene.self, from: data)
            return scene
        } catch {
            return GameScene()
        }
    }

    static func save(scene: GameScene) {
        SaveUtility.saveQueue.async {
            do {
                let data = try JSONEncoder().encode(scene)
                #if os(tvOS)
                UserDefaults.standard.set(data, forKey: "data")
                #else
                try data.write(to: SaveUtility.sceneURL)
                #endif
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

}
