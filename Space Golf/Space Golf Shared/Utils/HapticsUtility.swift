//
//  HapticUtility.swift
//  Space Golf
//
//  Created by Andrew Finke on 4/10/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import CoreGraphics

#if os(macOS)
class HapticsUtility {
    func playCompletedHole() {}
    func playHitPlanet(normalizedImpact: CGFloat) {}
}
#else

import CoreHaptics
import UIKit

class HapticsUtility {
    
    private var supportsHaptics: Bool {
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        return hapticCapability.supportsHaptics
    }
    
    private var engine: CHHapticEngine?
    private var engineActive = false
    private var continuousPlayer: CHHapticAdvancedPatternPlayer!

    init() {
        guard supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        engine?.stoppedHandler = { reason in
            print(reason)
            self.engineActive = false
        }
        engine?.resetHandler = {
            self.startEngine()
        }
        
        startEngine()
    }
    
    private func startEngine() {
        guard !engineActive else { return }
        do {
            try engine?.start()
            self.engineActive = true
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Play -
    
    func playCompletedHole() {
        guard supportsHaptics else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    func playHitPlanet(normalizedImpact: CGFloat) {
        guard supportsHaptics, let engine = engine else { return }
        startEngine()
        
        do {
            let volume = CGFloat(0.1).lerp(value: 1, alpha: normalizedImpact)
            let decay = CGFloat(0).lerp(value: 0.1, alpha: normalizedImpact)
            let audioEvent = CHHapticEvent(eventType: .audioContinuous, parameters: [
                CHHapticEventParameter(parameterID: .audioPitch, value: -0.15),
                CHHapticEventParameter(parameterID: .audioVolume, value: Float(volume)),
                CHHapticEventParameter(parameterID: .decayTime, value: Float(decay)),
                CHHapticEventParameter(parameterID: .sustained, value: 0)
            ], relativeTime: 0)
            
            let sharpness = CGFloat(0.4).lerp(value: 1, alpha: normalizedImpact)
            let intensity = CGFloat(0.4).lerp(value: 1, alpha: normalizedImpact)
            let hapticEvent = CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(sharpness)),
                CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity))
            ], relativeTime: 0)
            
            let pattern = try CHHapticPattern(events: [audioEvent, hapticEvent], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
}
#endif
