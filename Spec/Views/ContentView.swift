//
//  ContentView.swift
//  Spec
//
//  Created by Maxim Golovlev on 02.07.2026.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SpecViewModel()
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.blueprintDarkBg.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // DESCRIPTION: Описание в шапке
                        Text("Convert layout units into production-ready code tokens. Switch modes to calculate backwards. Shake your iPhone to clear.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 8)
                            .padding(.top, 8)
                        
                        // СЕЛЕКТОР НАПРАВЛЕНИЯ: Переключатель режимов
                        Picker("Mode", selection: $viewModel.conversionMode) {
                            Text("PX → REM / PT").tag(ConversionMode.pxToUnits)
                            Text("REM → PX / PT").tag(ConversionMode.remToUnits)
                        }
                        .pickerStyle(.segmented)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(8)
                        
                        // ВВОД: Поле для ввода числа (PX или REM)
                        VStack(spacing: 8) {
                            Text(viewModel.conversionMode == .pxToUnits ? "ENTER PIXELS (PX)" : "ENTER VALUE (REM)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.electricCyan)
                                .tracking(1)
                            
                            HStack {
                                // .decimalPad позволяет вводить точку для REM-значений (например 1.5)
                                TextField(viewModel.conversionMode == .pxToUnits ? "0" : "0.00", text: $viewModel.numericInput)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .focused($isInputFocused)
                            }
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                        
                        // НАСТРОЙКА: Слайдер базового шрифта
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Web Base Font Size")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(Int(viewModel.baseFontSize)) PX")
                                    .font(.system(.body, design: .monospaced))
                                    .fontWeight(.bold)
                                    .foregroundColor(.electricCyan)
                            }
                            
                            Slider(value: $viewModel.baseFontSize, in: 10...24, step: 1)
                                .tint(.electricCyan)
                        }
                        .padding(18)
                        .background(Color.blueprintCard)
                        .cornerRadius(20)
                        
                        // РЕЗУЛЬТАТЫ: Интерактивные плашки кода
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Generated Code Tokens:")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white.opacity(0.4))
                                .textCase(.uppercase)
                                .padding(.horizontal, 4)
                            
                            CodeCard(title: "SWIFTUI (iOS)", code: viewModel.swiftUICode) {
                                viewModel.copyToClipboard(text: viewModel.swiftUICode)
                            }
                            
                            CodeCard(title: "CSS REM (WEB)", code: viewModel.cssCode) {
                                viewModel.copyToClipboard(text: viewModel.cssCode)
                            }
                            
                            CodeCard(title: "JETPACK COMPOSE (ANDROID)", code: viewModel.androidCode) {
                                viewModel.copyToClipboard(text: viewModel.androidCode)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Spec Converter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") { isInputFocused = false }
                            .fontWeight(.bold)
                            .foregroundColor(.electricCyan)
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                withAnimation {
                    viewModel.resetAll()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}


// Вспомогательный переиспользуемый компонент карточки кода
struct CodeCard: View {
    let title: String
    let code: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.electricCyan.opacity(0.7))
                    
                    Text(code)
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "doc.on.doc.fill")
                    .font(.footnote)
                    .foregroundColor(.electricCyan)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(Color.blueprintCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.03), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

import SwiftUI

extension Color {
    static let blueprintDarkBg = Color(red: 0.04, green: 0.07, blue: 0.16) // #0A1128
    static let blueprintCard = Color(red: 0.06, green: 0.12, blue: 0.26)   // #101F42
    static let electricCyan = Color(red: 0.00, green: 0.90, blue: 1.00)    // #00E5FF
}
