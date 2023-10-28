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
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var alertIsShown = false
    
    static var defaultWakeUp: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                VStack {
                    Text("When do you want to wake up?")
                        .bold()
                    HStack {
                        Spacer()
                        DatePicker("Choose your wake up time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
                VStack {
                    Text("Desired amount of sleep")
                        .bold()
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12)
                }
                VStack {
                    Text("Daily coffee intake")
                        .bold()
                    Stepper("^[\(cupsOfCoffee) cup](inflect: true)", value: $cupsOfCoffee)
                }
                HStack(alignment: .center) {
                    Spacer()
                    Button("Calculate", action: calculateBedTime)
                    Spacer()
                }
            
            }
            .navigationTitle("BetterRest")
            .alert(alertTitle, isPresented: $alertIsShown) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
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
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was an error during calculation"
        }
        alertIsShown = true
        
    }
    
}

#Preview {
    ContentView()
}
