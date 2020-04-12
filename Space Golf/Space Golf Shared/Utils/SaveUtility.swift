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
        let doc = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        #else
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        #endif
        let url = doc.appendingPathComponent("scene_data")
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
            let data = try Data(contentsOf: SaveUtility.sceneURL)
            let scene = try JSONDecoder().decode(GameScene.self, from: data)
            return scene
        } catch {
            let scene = GameScene()
            return scene
        }
    }

    static func save(scene: GameScene) {
        SaveUtility.saveQueue.async {
            do {
                let data = try JSONEncoder().encode(scene)
                try data.write(to: SaveUtility.sceneURL)
            } catch {
//                fatalError(error.localizedDescription)
            }
        }
    }

}
