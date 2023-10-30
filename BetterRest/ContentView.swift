//
//  ContentView.swift
//  BetterRest
//
//  Created by Maks Winters on 26.10.2023.
//

import SwiftUI
import CoreML

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeUp
    @State private var sleepAmount = 8.0
    @State private var cupsOfCoffee = 1
    
    @State private var hourTime = "00"
    @State private var minuteTime = "00"
    @State private var alertIsShown = false
    
    @Environment (\.colorScheme) var colorScheme
    
    static var defaultWakeUp: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
// Background
                CustomColor.backgroundColor
                    .ignoresSafeArea()
// Ideal time screen
                VStack {
                    Spacer()
                    Text("Your ideal bedtime is:")
                        .bold()
                    VStack(spacing: -20) {
                        Text(hourTime)
                        Text(minuteTime)
                    }
                    .font(.system(size: 80))
// Wake up and coffee amount selection
                    HStack {
                        VStack(spacing: 5) {
                            Text("Wake up:")
                                .bold()
                            DatePicker("Choose your wake up time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .onChange(of: wakeUp) {
                                    calculateBedTime()
                                }
                        }
                        VStack(spacing: 5) {
                            Text("Coffee:")
                                .bold()
                            Picker("Coffee amount", selection: $cupsOfCoffee) {
                                ForEach(4..<13) {
                                    Text("\($0)")
                                }
                            }
                            .onChange(of: cupsOfCoffee) {
                                calculateBedTime()
                            }
                        }
                    }
// Desired amount of sleep stepper
                    VStack(spacing: 5) {
                        Text("Desired sleep amount:")
                            .bold()
                        Text("\(sleepAmount.formatted()) hours")
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12)
                            .labelsHidden()
                            .onChange(of: sleepAmount) {
                                calculateBedTime()
                            }
                    }
                    Spacer()
                }
                VStack {
// Sun/moon icon
                    HStack {
                        Image(systemName: 
                        mainIcon())
                            .foregroundStyle(.white)
                            .font(.system(size: 300))
                            .shadow(color: CustomColor.iconShadow, radius: 6, x: 5, y: 5)
                            .offset(CGSize(width: -140.0, height: -180.0))
                        Spacer()
                        }
                    Spacer()
                    HStack {
                        Spacer()
// Cup and steam on top
                        ZStack {
// Cup
                            Image(systemName: "cup.and.saucer.fill")
                                .foregroundStyle(CustomColor.coffeeColor)
                                .font(.system(size: 140))
                                .scaleEffect(x: -1, y: 1)
// Steam
                            Image(systemName: "water.waves")
                                .foregroundStyle(CustomColor.steamColor)
                                .rotationEffect(Angle(degrees: 90))
                                .offset(y: -60)
                                .font(.system(size: 50))
                        }
                    }
                    .offset(x: 70, y: 50)
                }
            }
        }
    } 
    
    func mainIcon() -> String{
        if colorScheme == .dark {
            return "moon.fill"
        } else {
            return "sun.max.fill"
        }
    }
    
    func calculateBedTime() {
        
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minutes = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(hour + minutes), estimatedSleep: sleepAmount, coffee: Int64(cupsOfCoffee))
            let sleepTime = wakeUp - prediction.actualSleep
            
            let hourDateFormatter = DateFormatter()
            hourDateFormatter.dateFormat = "HH"
            hourTime = hourDateFormatter.string(from: sleepTime)
            
            let minuteDateFormatter = DateFormatter()
            minuteDateFormatter.dateFormat = "MM"
            minuteTime = minuteDateFormatter.string(from: sleepTime)
        } catch {
            hourTime = "ER"
            minuteTime = "ER"
        }
        alertIsShown = true
        
    }
    
}

struct CustomColor {
    static let backgroundColor = Color("Background")
    static let iconShadow = Color("IconShadow")
    static let coffeeColor = Color("Color")
    static let steamColor = Color("SteamColor")
    // Add more here...
}

#Preview {
    ContentView()
}
