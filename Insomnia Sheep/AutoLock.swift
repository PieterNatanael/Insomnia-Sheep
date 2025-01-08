//
//  AutoLock.swift
//  Insomnia Sheep
//
//  Created by Pieter Yoshua Natanael on 19/12/24.
//


import SwiftUI

struct AutoLockView: View {
    @AppStorage("records") private var recordsData: Data = Data()
    @State private var records: [String] = []
    @State private var timer: Timer?
    @State private var lastInteractionTime: Date = Date()
    @State private var lastRecordedTime: Date? = nil
    @State private var appStartTime: Date? = nil  // Track when the app started
    
    // MARK: - Configurable Durations
    private let minimumActiveDuration: TimeInterval = 3 * 60  // 3 minutes - adjust to 15 minutes as needed
    private let autoLockCheckInterval: TimeInterval = 1 * 60  // 5 minutes between checks
    
    var body: some View {
        NavigationView {
            VStack {
                List(records, id: \.self) { record in
                    Text(record)
                }
                .navigationTitle("Sleep Detection")
            
                Button("Clear data") {
                    // Perform confirmation action
                    records.removeAll()
                }
                .font(.title)
                .frame(maxWidth: .infinity)
                .padding()
                .background((Color(#colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1))))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.vertical, 10)
            }
            .onAppear {
                appStartTime = Date()  // Set the start time when app appears
                loadRecords()
                setupNotifications()
                resetTimer()
            }
            .onDisappear {
                removeNotifications()
                stopTimer()
            }
            .onTapGesture {
                resetInteraction()
            }
        }
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            checkAndRecordEvent()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            resetInteraction()
        }
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func resetInteraction() {
        lastInteractionTime = Date()
        resetTimer()
    }
    
    func resetTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: autoLockCheckInterval, repeats: true) { _ in
            if Date().timeIntervalSince(lastInteractionTime) >= autoLockCheckInterval {
                checkAndRecordEvent()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // New function to check minimum duration before recording
    func checkAndRecordEvent() {
        guard let startTime = appStartTime else { return }
        
        let now = Date()
        let activeTime = now.timeIntervalSince(startTime)
        
        // Only record if the app has been active for the minimum duration
        if activeTime >= minimumActiveDuration {
            recordAutolockEvent()
        }
    }
    
    func recordAutolockEvent() {
        let now = Date()
        // Prevent duplicate records within a short time frame
        if let lastTime = lastRecordedTime, now.timeIntervalSince(lastTime) < 1 {
            return
        }
        
        lastRecordedTime = now
        let timestamp = DateFormatter.localizedString(from: now, dateStyle: .short, timeStyle: .medium)
        records.append("Sleep detected at \(timestamp)")
        saveRecords()
    }
    
    func saveRecords() {
        if let encodedData = try? JSONEncoder().encode(records) {
            recordsData = encodedData
        }
    }
    
    func loadRecords() {
        if let decodedData = try? JSONDecoder().decode([String].self, from: recordsData) {
            records = decodedData
        }
    }
}

struct AutoLockView_Previews: PreviewProvider {
    static var previews: some View {
        AutoLockView()
    }
}

/*
//works but data missing after restart
import SwiftUI

struct AutoLockView: View {
    @State private var records: [String] = []
    @State private var timer: Timer?
    @State private var lastInteractionTime: Date = Date()
    @State private var lastRecordedTime: Date? = nil // Prevent duplicate entries

    var body: some View {
        NavigationView {
            VStack {
                List(records, id: \.self) { record in
                    Text(record)
                }
                .navigationTitle("Sleep Record")
                .toolbar {
                    Button("Clear") {
                        records.removeAll()
                    }
                }
                Button("Clear data") {
                    // Perform confirmation action
                    records.removeAll()
                }
                .font(.title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.vertical, 10)
            }
            .onAppear {
                setupNotifications()
                resetTimer()
            }
            .onDisappear {
                removeNotifications()
                stopTimer()
            }
            .onTapGesture {
                resetInteraction()
            }
        }
    }

    func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            recordAutolockEvent()
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            resetInteraction()
        }
    }

    func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    func resetInteraction() {
        lastInteractionTime = Date()
        resetTimer()
    }

    func resetTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 5 * 60, repeats: true) { _ in
            if Date().timeIntervalSince(lastInteractionTime) >= 5 * 60 {
                recordAutolockEvent()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func recordAutolockEvent() {
        let now = Date()

        // Prevent duplicate records within a short time frame
        if let lastTime = lastRecordedTime, now.timeIntervalSince(lastTime) < 1 {
            return
        }

        lastRecordedTime = now
        let timestamp = DateFormatter.localizedString(from: now, dateStyle: .short, timeStyle: .medium)
        records.append("Sleep detected at \(timestamp)")
    }
}

struct AutoLockView_Previews: PreviewProvider {
    static var previews: some View {
        AutoLockView()
    }
}

*/




/*
//work but firing 2 time
import SwiftUI

struct AutoRecordApp: App {
    var body: some Scene {
        WindowGroup {
            AutoLockView()
        }
    }
}

struct AutoLockView: View {
    @State private var records: [String] = []
    @State private var timer: Timer?
    @State private var lastInteractionTime: Date = Date()

    var body: some View {
        NavigationView {
            VStack {
                List(records, id: \.self) { record in
                    Text(record)
                }
                .navigationTitle("Sleep Time")
                .toolbar {
                    Button("Clear Data") {
                        records.removeAll()
                    }
                }
                
            }
            .onAppear {
                setupNotifications()
                resetTimer()
            }
            .onDisappear {
                removeNotifications()
                stopTimer()
            }
            .onTapGesture {
                resetInteraction()
            }
        }.navigationViewStyle(StackNavigationViewStyle())

    }

    func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            recordAutolockEvent()
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            resetInteraction()
        }
    }

    func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    func resetInteraction() {
        lastInteractionTime = Date()
        resetTimer()
    }

    func resetTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 5 * 60, repeats: true) { _ in
            if Date().timeIntervalSince(lastInteractionTime) >= 5 * 60 {
                recordAutolockEvent()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func recordAutolockEvent() {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
        records.append("Sleep detected at \(timestamp)")
    }
}
struct AutoLockView_Previews: PreviewProvider {
    static var previews: some View {
        AutoLockView()
    }
}

*/
