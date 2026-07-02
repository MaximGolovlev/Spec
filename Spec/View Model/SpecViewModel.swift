//
//  SpecViewModel.swift
//  Spec
//
//  Created by Maxim Golovlev on 02.07.2026.
//


import Foundation
import UIKit
import Combine

enum ConversionMode: Int {
    case pxToUnits = 0
    case remToUnits = 1
}

class SpecViewModel: ObservableObject {
    @Published var numericInput: String = "" {
        didSet { calculateValues() }
    }
    
    // Режим конвертации: 0 — из PX, 1 — из REM
    @Published var conversionMode: ConversionMode = .pxToUnits {
        didSet {
            numericInput = "" // Очищаем ввод при смене режима
            calculateValues()
        }
    }
    
    @Published var baseFontSize: Double = 16.0 {
        didSet {
            UserDefaults.standard.set(baseFontSize, forKey: "spec_base_font_size")
            calculateValues()
        }
    }
    
    @Published var swiftUICode: String = ".frame(width: 0)"
    @Published var cssCode: String = "width: 0rem;"
    @Published var androidCode: String = "width = 0.dp"
    
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    var currentInputValue: Double {
        return Double(numericInput) ?? 0.0
    }
    
    init() {
        hapticGenerator.prepare()
        let savedBase = UserDefaults.standard.double(forKey: "spec_base_font_size")
        if savedBase > 0 {
            self.baseFontSize = savedBase
        }
    }
    
    func calculateValues() {
        let value = currentInputValue
        
        switch conversionMode {
        case .pxToUnits:
            // Режим А: Ввод в Пикселях
            let rem = value / baseFontSize
            swiftUICode = String(format: ".frame(width: %.0f)", value)
            cssCode = String(format: "width: %.3frem;", rem)
            androidCode = String(format: "width = %.0f.dp", value)
            
        case .remToUnits:
            // Режим Б: Ввод в REM
            let px = value * baseFontSize
            swiftUICode = String(format: ".frame(width: %.0f)", px)
            cssCode = String(format: "width: %.3frem;", value)
            androidCode = String(format: "width = %.0f.dp", px)
        }
    }
    
    func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
    }
    
    func resetAll() {
        numericInput = ""
        let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
        heavyHaptic.impactOccurred()
    }
}


// Расширение для отслеживания жеста физической тряски iPhone в SwiftUI
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}
