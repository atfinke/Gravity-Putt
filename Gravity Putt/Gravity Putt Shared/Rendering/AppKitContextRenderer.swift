//
//  AppKitContextRenderer.swift
//  Gravity Putt
//
//  Created by Andrew Finke on 4/4/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

#if os(macOS)
import AppKit

class AppKitContextRenderer {
    let size: CGSize

    init(size: CGSize) {
        self.size = size
    }

    func image(actions: (NSGraphicsContext) -> Void) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocusFlipped(true)

        guard let ctx = NSGraphicsContext.current else {
            fatalError()
        }

        actions(ctx)
        image.unlockFocus()
        return image
    }
}
#endif
