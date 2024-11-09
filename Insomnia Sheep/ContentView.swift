//
//  ContentView.swift
//  Insomnia Sheep
//
//  Created by Pieter Yoshua Natanael on 20/03/24.
//



import SwiftUI
import AVFoundation

// MARK: - Main Content View
struct ContentView: View {
    // MARK: - State Variables
    @State private var isCounting = false          // Controls counting state
    @State private var sheepCount = 0              // Tracks number of sheep counted
    @State private var timer: Timer?               // Timer for counting sheep
    @State private var showBlackBackground = false // Controls background animation
    @State private var showConfirmationScreen = false
    @State private var isSoundOn = true           // Controls sheep sound
    @State private var isAnimating = false        // Controls gradient animation
    @State private var shouldChangeGradientColor = false // Controls gradient color scheme
    
    // Audio setup
    private let speechSynthesizer = AVSpeechSynthesizer()
    @State private var audioPlayer: AVAudioPlayer?
    
    // MARK: - Computed Properties
    // Dynamic gradient based on user preference
    private var gradient: AngularGradient {
        let colors = shouldChangeGradientColor
            ? [Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)),
               Color(#colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)),
               Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1))]
            : [Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)),
               .black,
               Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1))]
        
        return AngularGradient(
            gradient: Gradient(colors: colors),
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360)
        )
    }
    
    // MARK: - Body View
    var body: some View {
        ZStack {
            // Background Layer
            backgroundLayer
            
            // Content Layer
            VStack {
                // Top Navigation
                navigationBar
                
                Spacer()
                
                // Main Content
                sheepCounterContent
                
                // Control Button
                controlButton
                
                Spacer()
            }
            .sheet(isPresented: $showConfirmationScreen) {
                ConfirmationView(
                    onConfirm: { showConfirmationScreen = false },
                    isSoundOn: $isSoundOn,
                    shouldChangeGradientColor: $shouldChangeGradientColor
                )
            }
        }
        .onAppear(perform: setupAudioPlayer)
    }
    
    // MARK: - View Components
    private var backgroundLayer: some View {
        Group {
            if showBlackBackground {
                blackBackgroundView
            } else {
                animatedGradientView
            }
        }
    }
    
    private var blackBackgroundView: some View {
        Color.black
            .edgesIgnoringSafeArea(.all)
            .transition(.opacity)
            .onTapGesture(perform: handleBackgroundTap)
    }
    
    private var animatedGradientView: some View {
        GeometryReader { geometry in
            Circle()
                .fill(gradient)
                .scaleEffect(2 * sqrt(2))
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 30)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
                .onAppear { isAnimating = true }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .onTapGesture(perform: handleBackgroundTap)
        }
        .ignoresSafeArea()
    }
    
    private var navigationBar: some View {
        HStack {
            Spacer()
            Button(action: { showConfirmationScreen = true }) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .padding(.horizontal)
    }
    
    private var sheepCounterContent: some View {
        VStack {
            Image("sheep")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(width: UIScreen.main.bounds.width,
                       height: UIScreen.main.bounds.height / 2)
                .onTapGesture(perform: handleBackgroundTap)
            
            Text("\(sheepCount)")
                .font(.system(size: 133))
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.white)
                .onTapGesture(perform: handleBackgroundTap)
        }
    }
    
    private var controlButton: some View {
        Group {
            if isCounting {
                Button(action: stopCounting) {
                    Text("Stop")
                        .font(.title)
                        .padding()
                        .foregroundColor(.black)
                        .background(Color.red)
                        .cornerRadius(25.0)
                }
            } else {
                Button(action: startCounting) {
                    Text("Start")
                        .font(.title)
                        .padding()
                        .foregroundColor(.black)
                        .background(Color.white)
                        .cornerRadius(25.0)
                }
            }
        }
    }
    
    // MARK: - Functions
    private func handleBackgroundTap() {
        withAnimation {
            showBlackBackground.toggle()
            if isSoundOn {
                playSheepSound()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showBlackBackground = false
                    isAnimating = false
                }
            }
        }
    }
    
    private func startCounting() {
        isCounting = true
        sheepCount += 1
        speakSheepCount()
        
        // Set up timer for counting every 30 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            if sheepCount < Int.max {
                sheepCount += 1
                speakSheepCount()
            }
        }
    }
    
    private func stopCounting() {
        isCounting = false
        timer?.invalidate()
        sheepCount = 0
    }
    
    private func speakSheepCount() {
        let utterance = AVSpeechUtterance(string: "\(sheepCount) sheep")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }
    
    private func setupAudioPlayer() {
        guard let path = Bundle.main.path(forResource: "sheep", ofType: "mp3") else {
            print("Audio file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
        }
    }
    
    private func playSheepSound() {
        audioPlayer?.play()
    }
}

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


// MARK: - Confirmation View
struct ConfirmationView: View {
    let onConfirm: () -> Void
    @Binding var isSoundOn: Bool
    @Binding var shouldChangeGradientColor: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Features Section
                featureSection
                
                // App Functionality Section
                functionalitySection
                
                // App Cards Section
                appCardsSection
                
                // Footer
                footerSection
                
                // Close Button
                closeButton
            }
            .padding()
            .cornerRadius(15)
            .padding()
        }
    }
    
    // MARK: - View Components
    private var featureSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Feature")
                .font(.largeTitle.bold())
            
            Toggle(isOn: $isSoundOn) {
                Text("Sheep Sound \(isSoundOn ? "On" : "Off")")
            }
            
            Toggle(isOn: $shouldChangeGradientColor) {
                Text("Background Color\(shouldChangeGradientColor ? " Blue" : " Black")")
            }
        }
    }
    
    private var functionalitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("App Functionality")
                .font(.title.bold())
            
            Text("""
            •Press start to initiate sheep counting every 30 seconds.
            •Listen for the sheep counting sound at 30-second intervals.
            •Tap on the sheep when you hear the sound to confirm wakefulness.
            •Repeat the process until you're ready to stop.
            """)
            .font(.title3)
            .multilineTextAlignment(.leading)
            .padding()
        }
    }
    
    private var appCardsSection: some View {
        VStack(spacing: 15) {
            // Example app cards - add more as needed
            AppCardView(
                imageName: "iprogram",
                appName: "iProgramMe",
                appDescription: "Custom affirmations, schedule notifications, stay inspired daily.",
                appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935"
            )
            Divider().background(Color.gray)
            
            AppCardView(
                imageName: "takemedication",
                appName: "Take Medication",
                appDescription: "Just press any of the 24 buttons, each representing an hour of the day, and you'll get timely reminders to take your medication.",
                appURL: "https://apps.apple.com/id/app/take-medication/id6736924598"
            )
            Divider().background(Color.gray)
            
            AppCardView(
                imageName: "timetell",
                appName: "TimeTell",
                appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch.",
                appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030"
            )
            // Add more AppCardView components as needed
        }
    }
    
    private var footerSection: some View {
        Text("Insomnia Sheep is developed by Three Dollar.")
            .font(.title3.bold())
    }
    
    private var closeButton: some View {
        Button("Close") {
            onConfirm()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .font(.title3.bold())
        .cornerRadius(10)
        .padding()
        .shadow(color: Color.white.opacity(0.12), radius: 3, x: 3, y: 3)
    }
}

// MARK: - App Card View
struct AppCardView: View {
    let imageName: String
    let appName: String
    let appDescription: String
    let appURL: String
    
    var body: some View {
        HStack {
            // App Icon
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(7)
            
            // App Details
            VStack(alignment: .leading) {
                Text(appName)
                    .font(.title3)
                Text(appDescription)
                    .font(.caption)
            }
            
            Spacer()
            
            // Try Button
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Try")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

/*
 
 //bagus hanya mau dirapihkan dan dikasih comment
import SwiftUI
import AVFoundation

struct ContentView: View {
    
    @State private var isCounting: Bool = false
    @State private var sheepCount: Int = 0
    @State private var timer: Timer?
    @State private var showBlackBackground: Bool = false
    @State private var showConfirmationScreen: Bool = false
    @State private var showAd: Bool = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isSoundOn: Bool = true
    @State private var isAnimating = false
    @State private var shouldRestartAnimation = false
    @State private var shouldChangeGradientColor: Bool = false // New @State property

    
 
    // Rotating gradients
    var gradient: AngularGradient {
        if shouldChangeGradientColor {
            return AngularGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)),Color(#colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)), Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1))]),
                center: .center,
                startAngle: .degrees(0),
                endAngle: .degrees(360)
            )
        } else {
            return AngularGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)), .black, Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1))]),
                center: .center,
                startAngle: .degrees(0),
                endAngle: .degrees(360)
            )
        }
    }
    
    let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        ZStack {
            // Background
            if showBlackBackground {
                Color.black.edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            showBlackBackground.toggle()
                            if isSoundOn {
                                playSheepSound()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showBlackBackground = false
                                    shouldRestartAnimation.toggle() // Restart the animation
                                }
                            }
                        }
                    }
            } else {
                // With rotation
                GeometryReader { geometry in
                    ZStack {
                        Circle()
                            .fill(gradient)
                            .scaleEffect(2 * sqrt(2))
                            .rotationEffect(.degrees(isAnimating ? 360 : 0)) // Removed shouldRestartAnimation here
                            .animation(Animation.linear(duration: 30).repeatForever(autoreverses: false), value: isAnimating)
                            .onAppear {
                                self.isAnimating = true
                            }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showBlackBackground.toggle()
                        if isSoundOn {
                            playSheepSound()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showBlackBackground = false
                                isAnimating = false // Stop the animation when black background is hidden
                            }
                        }
                    }
                }
            }

            // Content
            VStack {
                HStack {
                    Button(action: {
                        
                    }) {
                        Image(systemName: "")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                    Button(action: {
                        showConfirmationScreen = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack {
                    Image("sheep")
                        //.renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2) // Adjust the height as needed
                        .onTapGesture {
                            withAnimation {
                                showBlackBackground.toggle()
                                if isSoundOn {
                                    playSheepSound()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation {
                                        showBlackBackground = false
                                    }
                                }
                            }}
                    
                    Text("\(sheepCount) ")
                        .font(.system(size: 133))
                        .multilineTextAlignment(.center)
                        .padding()
                        .foregroundColor(.white)
                        .onTapGesture {
                            withAnimation {
                                showBlackBackground.toggle()
                                if isSoundOn {
                                    playSheepSound()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation {
                                        showBlackBackground = false
                                    }
                                }
                            }
                    }
                   
                }

                if isCounting {
                    Button(action: stopCounting) {
                        Text("Stop")
                            .font(.title)
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.red)
                            .cornerRadius(25.0)
                    }
                } else {
                    Button(action: startCounting) {
                        Text("Start")
                            .font(.title)
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .cornerRadius(25.0)
                    }
                }
                
                Spacer()
            }
            .sheet(isPresented: $showAd) {
                AdView(onConfirm: {
                    showAd = false
                }, isSoundOn: $isSoundOn,
                       shouldChangeGradientColor: $shouldChangeGradientColor
                )
            }
            .sheet(isPresented: $showConfirmationScreen) {
                ConfirmationView(onConfirm: {
                    showConfirmationScreen = false
                }, isSoundOn: $isSoundOn,
                                 shouldChangeGradientColor: $shouldChangeGradientColor
                )
            }
        }
        .onAppear {
            setupAudioPlayer()
        }
    }

    func startCounting() {
        isCounting = true
        sheepCount += 1 // Immediately count 1 sheep
        speakSheepCount()
        
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
            if sheepCount < Int.max {
                sheepCount += 1
                speakSheepCount()
            }
        }
    }

    func stopCounting() {
        isCounting = false
        timer?.invalidate()
        sheepCount = 0
    }

    func speakSheepCount() {
        let utterance = AVSpeechUtterance(string: "\(sheepCount) sheep")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }

    func setupAudioPlayer() {
        if let path = Bundle.main.path(forResource: "sheep", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        } else {
            print("Audio file not found")
        }
    }

    func playSheepSound() {
        audioPlayer?.play()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AdView: View {
    var onConfirm: () -> Void
    @Binding var isSoundOn: Bool // Changed to @Binding
    @Binding var shouldChangeGradientColor: Bool // New binding for changing gradient colors


    var body: some View {
        ScrollView {
            VStack {
                Toggle(isOn: $isSoundOn, label: {
                    Text("Sheep Sound \(isSoundOn ? "On" : "Off")")
                        .foregroundColor(.white)
                })
                Toggle(isOn: $shouldChangeGradientColor, label: {
                    Text("Background Color\(shouldChangeGradientColor ? " Blue" : " Black")")
                                  .foregroundColor(.white)
                          })
                // Other content...
                Text("Ads to Support Us!")
                                    .font(.title)
                                    .padding()
                                    .foregroundColor(.white)

                                // Your ad content here...

                                Text("Buying our apps with a one-time fee helps us keep making helpful apps.")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                           
                
                Text("TimeTell.")
                    .font(.title)
    //                           .monospaced()
                    .padding()
                    .foregroundColor(.white)
                    .onTapGesture {
                        if let url = URL(string: "https://apps.apple.com/app/time-tell/id6479016269") {
                            UIApplication.shared.open(url)
                        }
                    }
    Text("Time Announcement.") // Add your 30 character description here
                      .font(.subheadline)
                      .padding(.horizontal)
                      .foregroundColor(.white)
                
                   
                   Text("Angry Kid.")
                       .font(.title)
        //                           .monospaced()
                       .padding()
                       .foregroundColor(.white)
                       .onTapGesture {
                           if let url = URL(string: "https://apps.apple.com/id/app/angry-kid/id6499461061") {
                               UIApplication.shared.open(url)
                           }
                       }
                Text("Guide for parents.") // Add your 30 character description here
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                    .foregroundColor(.white)
                              
                              Text("Dry Eye Read.")
                                  .font(.title)
        //                           .monospaced()
                                  .padding()
                                  .foregroundColor(.white)
                                  .onTapGesture {
                                      if let url = URL(string: "https://apps.apple.com/id/app/dry-eye-read/id6474282023") {
                                          UIApplication.shared.open(url)
                                      }
                                  }
                Text("Read With Ease.") // Add your 30 character description here
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                    .foregroundColor(.white)
                              
                              Text("iProgramMe.")
                                  .font(.title)
        //                           .monospaced()
                                  .padding()
                                  .foregroundColor(.white)
                                  .onTapGesture {
                                      if let url = URL(string: "https://apps.apple.com/id/app/iprogramme/id6470770935") {
                                          UIApplication.shared.open(url)
                                      }
                                  }
                Text("Code Your Best Self.") // Add your 30 character description here
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                    .foregroundColor(.white)
                              
                              Text("LoopSpeak.")
                                  .font(.title)
        //                           .monospaced()
                                  .padding()
                                  .foregroundColor(.white)
                                  .onTapGesture {
                                      if let url = URL(string: "https://apps.apple.com/id/app/loopspeak/id6473384030") {
                                          UIApplication.shared.open(url)
                                      }
                                  }
                Text("Looping Reading Companion.") // Add your 30 character description here
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                    .foregroundColor(.white)
                              
                         
                              Text("TemptationTrack.")
                                  .font(.title)
        //                           .monospaced()
                                  .padding()
                                  .foregroundColor(.white)
                                  .onTapGesture {
                                      if let url = URL(string: "https://apps.apple.com/id/app/temptationtrack/id6471236988") {
                                          UIApplication.shared.open(url)
                                      }
                                  }
                Text("Empowering Progress.") // Add your 30 character description here
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                    .foregroundColor(.white)

                           Spacer()

                           Button("Close") {
                               // Perform confirmation action
                               onConfirm()
                           }
                           .font(.title)
                           .padding()
                           .foregroundColor(.black)
                           .background(Color.white)
                           .cornerRadius(25.0)
                           .padding()
                       
            }
            .padding()
            .background(Color.black)
            .cornerRadius(15.0)
        .padding()
        }
    }
}

struct ConfirmationView: View {
   var onConfirm: () -> Void
    @Binding var isSoundOn: Bool // Changed to @Binding
    @Binding var shouldChangeGradientColor: Bool // New binding for changing gradient colors


    var body: some View {
        ScrollView {
            VStack {
//               HStack{
//                   Text("Feature, Ads & App Functionality")
//                       .font(.title3.bold())
//                   Spacer()
//               }
                Divider().background(Color.gray)
              
                //ads
                VStack {
                    HStack {
                        Text("Feature")
                            .font(.largeTitle.bold())
                        Spacer()
                    }
                    Toggle(isOn: $isSoundOn, label: {
                        Text("Sheep Sound \(isSoundOn ? "On" : "Off")")
                            
                    })
                    Toggle(isOn: $shouldChangeGradientColor, label: {
                        Text("Background Color\(shouldChangeGradientColor ? " Blue" : " Black")")
                                    
                              })
                    
                    HStack {
                        Text("Ads")
                            .font(.largeTitle.bold())
                        Spacer()
                    }
//                    ZStack {
//                        Image("threedollar")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .cornerRadius(25)
//                            .clipped()
//                            .onTapGesture {
//                                if let url = URL(string: "https://b33.biz/three-dollar/") {
//                                    UIApplication.shared.open(url)
//                                }
//                            }
//                    }
                    // App Cards
                    VStack {
                        
                        AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                        Divider().background(Color.gray)
                        
                        Divider().background(Color.gray)
                        AppCardView(imageName: "takemedication", appName: "Take Medication", appDescription: "Just press any of the 24 buttons, each representing an hour of the day, and you'll get timely reminders to take your medication. It's easy, quick, and ensures you never miss a dose!", appURL: "https://apps.apple.com/id/app/take-medication/id6736924598")
                        Divider().background(Color.gray)
                        // Add more AppCardViews here if needed
                        // App Data
                     
                        
                        AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch, for time-sensitive tasks.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "wb", appName: "Worry Bin", appDescription: "Worry Bin empowers you to take control of your mental well-being.", appURL: "https://apps.apple.com/id/app/worry-bin/id6498626727")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "BEC2", appName: "Blink Screen Time", appDescription: "Using screens can reduce your blink rate to just 6 blinks per minute, leading to dry eyes and eye strain. Our app helps you maintain a healthy blink rate to prevent these issues and keep your eyes comfortable.", appURL: "https://apps.apple.com/id/app/blink-screen-time/id6587551095")
                        Divider().background(Color.gray)
                        
                    
                        
                      
                    
                    }
                    Spacer()

                   
                   
                }
//                .padding()
//                .cornerRadius(15.0)
//                .padding()
                
                //ads end
                
                
                HStack{
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }
               
               Text("""
               •Press start to initiate sheep counting every 30 seconds.
               •Listen for the sheep counting sound at 30-second intervals.
               •Tap on the sheep when you hear the sound to confirm wakefulness.
               •Repeat the process until you're ready to stop.
               """)
               .font(.title3)
               .multilineTextAlignment(.leading)
               .padding()
               
               Spacer()
                
                HStack {
                    Text("Insomnia Sheep is developed by Three Dollar.")
                        .font(.title3.bold())
                    Spacer()
                }

               Button("Close") {
                   // Perform confirmation action
                   onConfirm()
               }
               .frame(maxWidth: .infinity)
               .padding()
               .background(Color.blue)
               .foregroundColor(.white)
               .font(.title3.bold())
               .cornerRadius(10)
               .padding()
               .shadow(color: Color.white.opacity(12), radius: 3, x: 3, y: 3)
           }
           .padding()
           .cornerRadius(15.0)
           .padding()
        }

   }
}

// MARK: - App Card View
struct AppCardView: View {
    var imageName: String
    var appName: String
    var appDescription: String
    var appURL: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(7)
            
            VStack(alignment: .leading) {
                Text(appName)
                    .font(.title3)
                Text(appDescription)
                    .font(.caption)
            }
            .frame(alignment: .leading)
            
            Spacer()
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Try")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}


*/

/*
//working great, combine showad and showconfirmation
import SwiftUI
import AVFoundation

struct ContentView: View {
    
    @State private var isCounting: Bool = false
    @State private var sheepCount: Int = 0
    @State private var timer: Timer?
    @State private var showBlackBackground: Bool = false
    @State private var showConfirmationScreen: Bool = false
    @State private var showAd: Bool = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isSoundOn: Bool = true
    @State private var isAnimating = false
    @State private var shouldRestartAnimation = false
    @State private var shouldChangeGradientColor: Bool = false // New @State property

    
 
    // Rotating gradients
    var gradient: AngularGradient {
        if shouldChangeGradientColor {
            return AngularGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)),Color(#colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)), Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1))]),
                center: .center,
                startAngle: .degrees(0),
                endAngle: .degrees(360)
            )
        } else {
            return AngularGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)), .black, Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1))]),
                center: .center,
                startAngle: .degrees(0),
                endAngle: .degrees(360)
            )
        }
    }
    
    let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        ZStack {
            // Background
            if showBlackBackground {
                Color.black.edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            showBlackBackground.toggle()
                            if isSoundOn {
                                playSheepSound()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showBlackBackground = false
                                    shouldRestartAnimation.toggle() // Restart the animation
                                }
                            }
                        }
                    }
            } else {
                // With rotation
                GeometryReader { geometry in
                    ZStack {
                        Circle()
                            .fill(gradient)
                            .scaleEffect(2 * sqrt(2))
                            .rotationEffect(.degrees(isAnimating ? 360 : 0)) // Removed shouldRestartAnimation here
                            .animation(Animation.linear(duration: 30).repeatForever(autoreverses: false), value: isAnimating)
                            .onAppear {
                                self.isAnimating = true
                            }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showBlackBackground.toggle()
                        if isSoundOn {
                            playSheepSound()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showBlackBackground = false
                                isAnimating = false // Stop the animation when black background is hidden
                            }
                        }
                    }
                }
            }

            // Content
            VStack {
                HStack {
                    Button(action: {
                        showAd = true
                    }) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                    Button(action: {
                        showConfirmationScreen = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack {
                    Image("sheep")
                        //.renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2) // Adjust the height as needed
                        .onTapGesture {
                            withAnimation {
                                showBlackBackground.toggle()
                                if isSoundOn {
                                    playSheepSound()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation {
                                        showBlackBackground = false
                                    }
                                }
                            }}
                    
                    Text("\(sheepCount) ")
                        .font(.system(size: 133))
                        .multilineTextAlignment(.center)
                        .padding()
                        .foregroundColor(.white)
                        .onTapGesture {
                            withAnimation {
                                showBlackBackground.toggle()
                                if isSoundOn {
                                    playSheepSound()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation {
                                        showBlackBackground = false
                                    }
                                }
                            }
                    }
                   
                }

                if isCounting {
                    Button(action: stopCounting) {
                        Text("Stop")
                            .font(.title)
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .cornerRadius(25.0)
                    }
                } else {
                    Button(action: startCounting) {
                        Text("Start")
                            .font(.title)
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .cornerRadius(25.0)
                    }
                }
                
                Spacer()
            }
            .sheet(isPresented: $showAd) {
                AdView(onConfirm: {
                    showAd = false
                }, isSoundOn: $isSoundOn,
                       shouldChangeGradientColor: $shouldChangeGradientColor
                )
            }
            .sheet(isPresented: $showConfirmationScreen) {
                ConfirmationView(onConfirm: {
                    showConfirmationScreen = false
                })
            }
        }
        .onAppear {
            setupAudioPlayer()
        }
    }

    func startCounting() {
        isCounting = true
        sheepCount += 1 // Immediately count 1 sheep
        speakSheepCount()
        
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
            if sheepCount < Int.max {
                sheepCount += 1
                speakSheepCount()
            }
        }
    }

    func stopCounting() {
        isCounting = false
        timer?.invalidate()
        sheepCount = 0
    }

    func speakSheepCount() {
        let utterance = AVSpeechUtterance(string: "\(sheepCount) sheep")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }

    func setupAudioPlayer() {
        if let path = Bundle.main.path(forResource: "sheep", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        } else {
            print("Audio file not found")
        }
    }

    func playSheepSound() {
        audioPlayer?.play()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AdView: View {
    var onConfirm: () -> Void
    @Binding var isSoundOn: Bool // Changed to @Binding
    @Binding var shouldChangeGradientColor: Bool // New binding for changing gradient colors


    var body: some View {
        ScrollView {
            VStack {
                Toggle(isOn: $isSoundOn, label: {
                    Text("Sheep Sound \(isSoundOn ? "On" : "Off")")
                        .foregroundColor(.white)
                })
                Toggle(isOn: $shouldChangeGradientColor, label: {
                    Text("Background Color\(shouldChangeGradientColor ? " Blue" : " Black")")
                                  .foregroundColor(.white)
                          })
                // Other content...
                Text("Ads to Support Us!")
                                    .font(.title)
                                    .padding()
                                    .foregroundColor(.white)

                                // Your ad content here...

                                Text("Buying our apps with a one-time fee helps us keep making helpful apps.")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                           
                
                Text("TimeTell.")
                    .font(.title)
    //                           .monospaced()
                    .padding()
                    .foregroundColor(.white)
                    .onTapGesture {
                        if let url = URL(string: "https://apps.apple.com/app/time-tell/id6479016269") {
                            UIApplication.shared.open(url)
                        }
                    }
    Text("Time Announcement.") // Add your 30 character description here
                      .font(.subheadline)
                      .padding(.horizontal)
                      .foregroundColor(.white)
                
                   
                   Text("Insomnia Sheep.")
                       .font(.title)
        //                           .monospaced()
                       .padding()
                       .foregroundColor(.white)
                       .onTapGesture {
                           if let url = URL(string: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431") {
                               UIApplication.shared.open(url)
                           }
                       }
                Text("Design to Count Sheep.") // Add your 30 character description here
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                    .foregroundColor(.white)
                              
                              Text("Dry Eye Read.")
                                  .font(.title)
        //                           .monospaced()
                                  .padding()
                                  .foregroundColor(.white)
                                  .onTapGesture {
                                      if let url = URL(string: "https://apps.apple.com/id/app/dry-eye-read/id6474282023") {
                                          UIApplication.shared.open(url)
                                      }
                                  }
                Text("Read With Ease.") // Add your 30 character description here
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                    .foregroundColor(.white)
                              
                              Text("iProgramMe.")
                                  .font(.title)
        //                           .monospaced()
                                  .padding()
                                  .foregroundColor(.white)
                                  .onTapGesture {
                                      if let url = URL(string: "https://apps.apple.com/id/app/iprogramme/id6470770935") {
                                          UIApplication.shared.open(url)
                                      }
                                  }
                Text("Code Your Best Self.") // Add your 30 character description here
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                    .foregroundColor(.white)
                              
                              Text("LoopSpeak.")
                                  .font(.title)
        //                           .monospaced()
                                  .padding()
                                  .foregroundColor(.white)
                                  .onTapGesture {
                                      if let url = URL(string: "https://apps.apple.com/id/app/loopspeak/id6473384030") {
                                          UIApplication.shared.open(url)
                                      }
                                  }
                Text("Looping Reading Companion.") // Add your 30 character description here
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                    .foregroundColor(.white)
                              
                         
                              Text("TemptationTrack.")
                                  .font(.title)
        //                           .monospaced()
                                  .padding()
                                  .foregroundColor(.white)
                                  .onTapGesture {
                                      if let url = URL(string: "https://apps.apple.com/id/app/temptationtrack/id6471236988") {
                                          UIApplication.shared.open(url)
                                      }
                                  }
                Text("Empowering Progress.") // Add your 30 character description here
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                    .foregroundColor(.white)

                           Spacer()

                           Button("Close") {
                               // Perform confirmation action
                               onConfirm()
                           }
                           .font(.title)
                           .padding()
                           .foregroundColor(.black)
                           .background(Color.white)
                           .cornerRadius(25.0)
                           .padding()
                       
            }
            .padding()
            .background(Color.black)
            .cornerRadius(15.0)
        .padding()
        }
    }
}

struct ConfirmationView: View {
   var onConfirm: () -> Void

    var body: some View {
       VStack {
           Text("Press start to begin counting sheep every 30 seconds. Tap on the sheep when you hear the sheep counting every 30 seconds to confirm that you are awake.")
               .font(.title)
               .multilineTextAlignment(.center)
//                       .monospaced()
               .padding()
               .foregroundColor(.white)

           Spacer()

           Button("Close") {
               // Perform confirmation action
               onConfirm()
           }
           .font(.title)
           .padding()
           .foregroundColor(.black)
           .background(Color.white)
           .cornerRadius(25.0)
           .padding()
       }
       .padding()
       .background(Color.black)
       .cornerRadius(15.0)
       .padding()
   }
}

*/

//ini bagus namun mau ada penambahan fitur rubah gradients color
/*
import SwiftUI
import AVFoundation

struct ContentView: View {
    
    @State private var isCounting: Bool = false
    @State private var sheepCount: Int = 0
    @State private var timer: Timer?
    @State private var showBlackBackground: Bool = false
    @State private var showConfirmationScreen: Bool = false
    @State private var showAd: Bool = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isSoundOn: Bool = true
    @State private var isAnimating = false
    @State private var shouldRestartAnimation = false
    
    // Rotating gradients
    let gradient = AngularGradient(
        gradient: Gradient(colors: [Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)), .black, Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1))]),
        center: .center,
        startAngle: .degrees(0),
        endAngle: .degrees(360)
    )
    
    let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        ZStack {
            // Background
            if showBlackBackground {
                Color.black.edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            showBlackBackground.toggle()
                            if isSoundOn {
                                playSheepSound()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showBlackBackground = false
                                    shouldRestartAnimation.toggle() // Restart the animation
                                }
                            }
                        }
                    }
            } else {
                // With rotation
                GeometryReader { geometry in
                    ZStack {
                        Circle()
                            .fill(gradient)
                            .scaleEffect(2 * sqrt(2))
                            .rotationEffect(.degrees(isAnimating ? 360 : 0)) // Removed shouldRestartAnimation here
                            .animation(Animation.linear(duration: 30).repeatForever(autoreverses: false), value: isAnimating)
                            .onAppear {
                                self.isAnimating = true
                            }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showBlackBackground.toggle()
                        if isSoundOn {
                            playSheepSound()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showBlackBackground = false
                                isAnimating = false // Stop the animation when black background is hidden
                            }
                        }
                    }
                }
            }

            // Content
            VStack {
                HStack {
                    Button(action: {
                        showAd = true
                    }) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                    Button(action: {
                        showConfirmationScreen = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.horizontal)
                
                Spacer()
              
                Text("\(sheepCount) 🐑")
                    .font(.system(size: 133))
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.white)
                    .onTapGesture {
                        withAnimation {
                            showBlackBackground.toggle()
                            if isSoundOn {
                                playSheepSound()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showBlackBackground = false
                                }
                            }
                        }
                    }

                if isCounting {
                    Button(action: stopCounting) {
                        Text("Stop")
                            .font(.title)
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .cornerRadius(25.0)
                    }
                } else {
                    Button(action: startCounting) {
                        Text("Start")
                            .font(.title)
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .cornerRadius(25.0)
                    }
                }
               
                Spacer()
            }
            .sheet(isPresented: $showAd) {
                AdView(onConfirm: {
                    showAd = false
                }, isSoundOn: $isSoundOn)
            }
            .sheet(isPresented: $showConfirmationScreen) {
                ConfirmationView(onConfirm: {
                    showConfirmationScreen = false
                })
            }
        }
        .onAppear {
            setupAudioPlayer()
        }
    }

    func startCounting() {
        isCounting = true
        sheepCount += 1 // Immediately count 1 sheep
        speakSheepCount()
        
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
            if sheepCount < Int.max {
                sheepCount += 1
                speakSheepCount()
            }
        }
    }

    func stopCounting() {
        isCounting = false
        timer?.invalidate()
        sheepCount = 0
    }

    func speakSheepCount() {
        let utterance = AVSpeechUtterance(string: "\(sheepCount) sheep")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }

    func setupAudioPlayer() {
        if let path = Bundle.main.path(forResource: "sheep", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        } else {
            print("Audio file not found")
        }
    }

    func playSheepSound() {
        audioPlayer?.play()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AdView: View {
    var onConfirm: () -> Void
    @Binding var isSoundOn: Bool // Changed to @Binding

    var body: some View {
        VStack {
            Toggle(isOn: $isSoundOn, label: {
                Text("Sheep Sound \(isSoundOn ? "On" : "Off")")
                    .foregroundColor(.white)
            })
            // Other content...
            Text("Ad.")
                           .font(.title)
//                           .bold()
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                       
                       Text("Dry Eye Read.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/id/app/dry-eye-read/id6474282023") {
                                   UIApplication.shared.open(url)
                               }
                           }
                       
                       Text("iProgramMe.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/id/app/iprogramme/id6470770935") {
                                   UIApplication.shared.open(url)
                               }
                           }
                       
                       Text("LoopSpeak.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/id/app/loopspeak/id6473384030") {
                                   UIApplication.shared.open(url)
                               }
                           }
                       
                       Text("TimeTell.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/app/time-tell/id6479016269") {
                                   UIApplication.shared.open(url)
                               }
                           }
                       
                       Text("TemptationTrack.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/id/app/temptationtrack/id6471236988") {
                                   UIApplication.shared.open(url)
                               }
                           }

                       Spacer()

                       Button("Close") {
                           // Perform confirmation action
                           onConfirm()
                       }
                       .font(.title)
                       .padding()
                       .foregroundColor(.black)
                       .background(Color.white)
                       .cornerRadius(25.0)
                       .padding()
                   
        }
        .padding()
        .background(Color.black)
        .cornerRadius(15.0)
        .padding()
    }
}

struct ConfirmationView: View {
   var onConfirm: () -> Void

    var body: some View {
       VStack {
           Text("Tap the screen when you hear sheep counting every 30 seconds to confirm your wakefulness. Otherwise, we'll switch to a rest mode to help you relax peacefully.")
               .font(.title)
               .multilineTextAlignment(.center)
//                       .monospaced()
               .padding()
               .foregroundColor(.white)

           Spacer()

           Button("Close") {
               // Perform confirmation action
               onConfirm()
           }
           .font(.title)
           .padding()
           .foregroundColor(.black)
           .background(Color.white)
           .cornerRadius(25.0)
           .padding()
       }
       .padding()
       .background(Color.black)
       .cornerRadius(15.0)
       .padding()
   }
}

*/


/*

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    @State private var isCounting: Bool = false
    @State private var sheepCount: Int = 0
    @State private var timer: Timer?
    @State private var showBlackBackground: Bool = false
    @State private var showConfirmationScreen: Bool = false
    @State private var showAd: Bool = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isSoundOn: Bool = true
    @State private var isAnimating = false
    @State private var shouldRestartAnimation = false

    
    //rotating gradients
    let gradient = AngularGradient(
        gradient: Gradient(colors: [Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)), .black, Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1))]),
        center: .center,
        startAngle: .degrees(0),
        endAngle: .degrees(360)
    )
    
//    @State private var SheepAnimate = false
    let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        ZStack {
            // Background
            if showBlackBackground {
                Color.black.edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            showBlackBackground.toggle()
                            if isSoundOn {
                                playSheepSound()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showBlackBackground = false
                                    
                          
                                           shouldRestartAnimation.toggle()
                                    
                                }
                        
                            }
//                            SheepAnimate.toggle()
                           
                        }
                       
                    }
            
//            Text("🐑")
//                 .font(.system(size: 100)) // Set the font size
//                 // Position the view off-screen to the right initially, and move it to the center when `animate` is true
//                 .offset(x: SheepAnimate ? 0 : UIScreen.main.bounds.width, y: 0)
//                 .animation(.easeInOut(duration: 1), value: SheepAnimate) // Animate the movement
         }
            else {
                //with rotation
                GeometryReader { geometry in
                    // Create a ZStack to layer views
                    ZStack {
                        // Circle with a diameter equal to the diagonal of the screen
                        Circle()
                            .fill(gradient)
                            .scaleEffect(2 * sqrt(2)) // Scale factor to cover the diagonal
                            .rotationEffect(.degrees(isAnimating || shouldRestartAnimation ? 360 : 0))
                            .animation(Animation.linear(duration: 30).repeatForever(autoreverses: false), value: isAnimating || shouldRestartAnimation)

                            .onAppear {
                                self.isAnimating = true
                            }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height) // Match frame to screen size
                }
                .ignoresSafeArea() // Ignore safe area to cover the entire screen/background.
                //ori without rotation
//                LinearGradient(colors: [Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)), .white], startPoint: .top, endPoint: .bottom)
//                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showBlackBackground.toggle()
                            if isSoundOn {
                                playSheepSound()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showBlackBackground = false
                                }
                            }
                        }
                    }
            }

            // Content
            VStack {
                HStack {
                    Button(action: {
                        showAd = true
                    }) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                   
                    Button(action: {
                        showConfirmationScreen = true
                    }) {
                        
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.horizontal)
                
                Spacer()
              
                Text("\(sheepCount) 🐑")
                    .font(.system(size: 133))
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.white)
                    .onTapGesture {
                        withAnimation {
                            showBlackBackground.toggle()
                            if isSoundOn {
                                playSheepSound()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showBlackBackground = false
                                }
                            }
                        }
                    }

                if isCounting {
                    Button(action: stopCounting) {
                        Text("Stop")
                            .font(.title)
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .cornerRadius(25.0)
                    }
                } else {
                    Button(action: startCounting)
                    {
                        Text("Start")
                            .font(.title)
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .cornerRadius(25.0)
                    }
                }
               
                Spacer()
                //sheep appear
//                Text("🐑")
//                    .font(.system(size: 100)) // Set the font size
//                    // Position the view off-screen to the right initially, and move it to the center when `animate` is true
//                    .offset(x: SheepAnimate ? 0 : UIScreen.main.bounds.width, y: 0)
//                    .animation(.easeInOut(duration: 1), value: SheepAnimate) // Animate the movement
                
            }
            .sheet(isPresented: $showAd) {
                AdView(onConfirm: {
                    // Handle confirmation action here
                    showAd = false
                }, isSoundOn: $isSoundOn)
            }
            .sheet(isPresented: $showConfirmationScreen) {
                ConfirmationView(onConfirm: {
                    // Handle confirmation action here
                    showConfirmationScreen = false
                })
            }
        }
        .onAppear {
            setupAudioPlayer()
        }
    }

    func startCounting() {
        isCounting = true
        sheepCount += 1 // Immediately count 1 sheep
           speakSheepCount()
        
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
            if sheepCount < Int.max {
                sheepCount += 1
                speakSheepCount()
            }
        }
    }

    func stopCounting() {
        isCounting = false
        timer?.invalidate()
        sheepCount = 0
    }

    func speakSheepCount() {
        let utterance = AVSpeechUtterance(string: "\(sheepCount) sheep")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }

    func setupAudioPlayer() {
        if let path = Bundle.main.path(forResource: "sheep", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        } else {
            print("Audio file not found")
        }
    }

    func playSheepSound() {
        audioPlayer?.play()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AdView: View {
    var onConfirm: () -> Void
    @Binding var isSoundOn: Bool // Changed to @Binding

   
    var body: some View {
        VStack {
            Toggle(isOn: $isSoundOn, label: {
                Text("Sheep Sound \(isSoundOn ? "On" : "Off")")
                    .foregroundColor(.white)
            })
            // Other content...
            Text("Ad.")
                           .font(.title)
//                           .bold()
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                       
                       Text("Dry Eye Read.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/id/app/dry-eye-read/id6474282023") {
                                   UIApplication.shared.open(url)
                               }
                           }
                       
                       Text("iProgramMe.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/id/app/iprogramme/id6470770935") {
                                   UIApplication.shared.open(url)
                               }
                           }
                       
                       Text("LoopSpeak.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/id/app/loopspeak/id6473384030") {
                                   UIApplication.shared.open(url)
                               }
                           }
                       
                       Text("TimeTell.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/app/time-tell/id6479016269") {
                                   UIApplication.shared.open(url)
                               }
                           }
                       
                       Text("TemptationTrack.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/id/app/temptationtrack/id6471236988") {
                                   UIApplication.shared.open(url)
                               }
                           }

                       Spacer()

                       Button("Close") {
                           // Perform confirmation action
                           onConfirm()
                       }
                       .font(.title)
                       .padding()
                       .foregroundColor(.black)
                       .background(Color.white)
                       .cornerRadius(25.0)
                       .padding()
                   
        }
        .padding()
        .background(Color.black)
        .cornerRadius(15.0)
        .padding()
    }
}
struct ConfirmationView: View {
   var onConfirm: () -> Void

   
    var body: some View {
       VStack {
           Text("If you hear the sheep counting, give us a tap on the screen to confirm you're not counting them in your sleep. If you don't tap, well, we'll assume you've drifted off into a fluffy dreamland and activate our snooze mode.")
               .font(.title)
//                       .monospaced()
               .padding()
               .foregroundColor(.white)

          
           Spacer()

           Button("Close") {
               // Perform confirmation action
               onConfirm()
           }
           .font(.title)
           .padding()
           .foregroundColor(.black)
           .background(Color.white)
           .cornerRadius(25.0)
           .padding()
       }
       .padding()
       .background(Color.black)
       .cornerRadius(15.0)
       .padding()
   }
}

*/
/*
import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var isCounting: Bool = false
    @State private var sheepCount: Int = 0
    @State private var timer: Timer?
    @State private var showBlackBackground: Bool = false
    @State private var showConfirmationScreen: Bool = false
    @State private var showAd: Bool = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isSoundOn: Bool = true
    //    @State private var SheepAnimate = false
    let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        ZStack {
            // Background
            RotatingGradientsBG() // Use RotatingGradientsBG for the rotating gradient background
            
            // Content
            VStack {
                HStack {
                    Button(action: {
                        showAd = true
                    }) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                    
                    Button(action: {
                        showConfirmationScreen = true
                    }) {
                        
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Text("\(sheepCount) 🐑")
                    .font(.system(size: 133))
                    .padding()
                    .foregroundColor(.white)
                    .onTapGesture {
                        withAnimation {
                            showBlackBackground.toggle()
                            if isSoundOn {
                                playSheepSound()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showBlackBackground = false
                                }
                            }
                        }
                    }

                if isCounting {
                    Button(action: stopCounting) {
                        Text("Stop")
                            .font(.title)
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .cornerRadius(25.0)
                    }
                } else {
                    Button(action: startCounting)
                    {
                        Text("Start")
                            .font(.title)
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .cornerRadius(25.0)
                    }
                }
                
                Spacer()
            }
            .sheet(isPresented: $showAd) {
                AdView(onConfirm: {
                    // Handle confirmation action here
                    showAd = false
                }, isSoundOn: $isSoundOn)
            }
            .sheet(isPresented: $showConfirmationScreen) {
                ConfirmationView(onConfirm: {
                    // Handle confirmation action here
                    showConfirmationScreen = false
                })
            }
        }
        .onAppear {
            setupAudioPlayer()
        }
    }

    func startCounting() {
        isCounting = true
        sheepCount += 1 // Immediately count 1 sheep
        speakSheepCount()
        
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
            if sheepCount < Int.max {
                sheepCount += 1
                speakSheepCount()
            }
        }
    }

    func stopCounting() {
        isCounting = false
        timer?.invalidate()
        sheepCount = 0
    }

    func speakSheepCount() {
        let utterance = AVSpeechUtterance(string: "\(sheepCount) sheep")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }

    func setupAudioPlayer() {
        if let path = Bundle.main.path(forResource: "sheep", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        } else {
            print("Audio file not found")
        }
    }

    func playSheepSound() {
        audioPlayer?.play()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AdView: View {
    var onConfirm: () -> Void
    @Binding var isSoundOn: Bool // Changed to @Binding

    var body: some View {
        VStack {
            Toggle(isOn: $isSoundOn, label: {
                Text("Sheep Sound \(isSoundOn ? "On" : "Off")")
                    .foregroundColor(.white)
            })
            // Other content...
        }
        .padding()
        .background(Color.black)
        .cornerRadius(15.0)
        .padding()
    }
}

struct ConfirmationView: View {
    var onConfirm: () -> Void

    var body: some View {
        VStack {
            Text("If you hear the sheep counting, give us a tap on the screen to confirm you're not counting them in your sleep. If you don't tap, well, we'll assume you've drifted off into a fluffy dreamland and activate our snooze mode.")
                .font(.title)
                .padding()
                .foregroundColor(.white)

            Spacer()

            Button("Close") {
                // Perform confirmation action
                onConfirm()
            }
            .font(.title)
            .padding()
            .foregroundColor(.black)
            .background(Color.white)
            .cornerRadius(25.0)
            .padding()
        }
        .padding()
        .background(Color.black)
        .cornerRadius(15.0)
        .padding()
    }
}


//struct rotating BG


struct RotatingGradientsBG: View {
    @State private var rotationAngle: Double = 0

    var body: some View {
        let gradient = AngularGradient(
            gradient: Gradient(colors: [.white, .blue, .white]),
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360)
        )

        return Circle()
            .fill(gradient)
            .rotationEffect(.degrees(rotationAngle))
            .animation(Animation.linear(duration: 10).repeatForever(autoreverses: false))
            .onAppear {
                self.rotationAngle = 360
            }
            .edgesIgnoringSafeArea(.all)
    }
}




*/


/*

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var isCounting: Bool = false
    @State private var sheepCount: Int = 0
    @State private var timer: Timer?
    @State private var showBlackBackground: Bool = false
    @State private var showConfirmationScreen: Bool = false
    @State private var showAd: Bool = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isSoundOn: Bool = true
//    @State private var SheepAnimate = false
    let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        ZStack {
            // Background
            if showBlackBackground {
                Color.black.edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            showBlackBackground.toggle()
                            if isSoundOn {
                                playSheepSound()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showBlackBackground = false
                                }
                        
                            }
//                            SheepAnimate.toggle()
                           
                        }
                       
                    }
            
//            Text("🐑")
//                 .font(.system(size: 100)) // Set the font size
//                 // Position the view off-screen to the right initially, and move it to the center when `animate` is true
//                 .offset(x: SheepAnimate ? 0 : UIScreen.main.bounds.width, y: 0)
//                 .animation(.easeInOut(duration: 1), value: SheepAnimate) // Animate the movement
         }
            else {
                LinearGradient(colors: [Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)), .white], startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showBlackBackground.toggle()
                            if isSoundOn {
                                playSheepSound()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showBlackBackground = false
                                }
                            }
                        }
                    }
            }

            // Content
            VStack {
                HStack {
                    Button(action: {
                        showAd = true
                    }) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                   
                    Button(action: {
                        showConfirmationScreen = true
                    }) {
                        
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.horizontal)
                
                Spacer()
              
                Text("\(sheepCount) 🐑")
                    .font(.system(size: 133))
                    .padding()
                    .foregroundColor(.white)
                    .onTapGesture {
                        withAnimation {
                            showBlackBackground.toggle()
                            if isSoundOn {
                                playSheepSound()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showBlackBackground = false
                                }
                            }
                        }
                    }

                if isCounting {
                    Button(action: stopCounting) {
                        Text("Stop")
                            .font(.title)
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .cornerRadius(25.0)
                    }
                } else {
                    Button(action: startCounting)
                    {
                        Text("Start")
                            .font(.title)
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .cornerRadius(25.0)
                    }
                }
               
                Spacer()
                //sheep appear
//                Text("🐑")
//                    .font(.system(size: 100)) // Set the font size
//                    // Position the view off-screen to the right initially, and move it to the center when `animate` is true
//                    .offset(x: SheepAnimate ? 0 : UIScreen.main.bounds.width, y: 0)
//                    .animation(.easeInOut(duration: 1), value: SheepAnimate) // Animate the movement
                
            }
            .sheet(isPresented: $showAd) {
                AdView(onConfirm: {
                    // Handle confirmation action here
                    showAd = false
                }, isSoundOn: $isSoundOn)
            }
            .sheet(isPresented: $showConfirmationScreen) {
                ConfirmationView(onConfirm: {
                    // Handle confirmation action here
                    showConfirmationScreen = false
                })
            }
        }
        .onAppear {
            setupAudioPlayer()
        }
    }

    func startCounting() {
        isCounting = true
        sheepCount += 1 // Immediately count 1 sheep
           speakSheepCount()
        
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
            if sheepCount < Int.max {
                sheepCount += 1
                speakSheepCount()
            }
        }
    }

    func stopCounting() {
        isCounting = false
        timer?.invalidate()
        sheepCount = 0
    }

    func speakSheepCount() {
        let utterance = AVSpeechUtterance(string: "\(sheepCount) sheep")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }

    func setupAudioPlayer() {
        if let path = Bundle.main.path(forResource: "sheep", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        } else {
            print("Audio file not found")
        }
    }

    func playSheepSound() {
        audioPlayer?.play()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AdView: View {
    var onConfirm: () -> Void
    @Binding var isSoundOn: Bool // Changed to @Binding

   
    var body: some View {
        VStack {
            Toggle(isOn: $isSoundOn, label: {
                Text("Sheep Sound \(isSoundOn ? "On" : "Off")")
                    .foregroundColor(.white)
            })
            // Other content...
            Text("Ad.")
                           .font(.title)
//                           .bold()
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                       
                       Text("Dry Eye Read.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/id/app/dry-eye-read/id6474282023") {
                                   UIApplication.shared.open(url)
                               }
                           }
                       
                       Text("iProgramMe.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/id/app/iprogramme/id6470770935") {
                                   UIApplication.shared.open(url)
                               }
                           }
                       
                       Text("LoopSpeak.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/id/app/loopspeak/id6473384030") {
                                   UIApplication.shared.open(url)
                               }
                           }
                       
                       Text("TimeTell.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/app/time-tell/id6479016269") {
                                   UIApplication.shared.open(url)
                               }
                           }
                       
                       Text("TemptationTrack.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/id/app/temptationtrack/id6471236988") {
                                   UIApplication.shared.open(url)
                               }
                           }

                       Spacer()

                       Button("Close") {
                           // Perform confirmation action
                           onConfirm()
                       }
                       .font(.title)
                       .padding()
                       .foregroundColor(.black)
                       .background(Color.white)
                       .cornerRadius(25.0)
                       .padding()
                   
        }
        .padding()
        .background(Color.black)
        .cornerRadius(15.0)
        .padding()
    }
}
struct ConfirmationView: View {
   var onConfirm: () -> Void

   
    var body: some View {
       VStack {
           Text("If you hear the sheep counting, give us a tap on the screen to confirm you're not counting them in your sleep. If you don't tap, well, we'll assume you've drifted off into a fluffy dreamland and activate our snooze mode.")
               .font(.title)
//                       .monospaced()
               .padding()
               .foregroundColor(.white)

          
           Spacer()

           Button("Close") {
               // Perform confirmation action
               onConfirm()
           }
           .font(.title)
           .padding()
           .foregroundColor(.black)
           .background(Color.white)
           .cornerRadius(25.0)
           .padding()
       }
       .padding()
       .background(Color.black)
       .cornerRadius(15.0)
       .padding()
   }
}

*/


/*
import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var isCounting: Bool = false
    @State private var sheepCount: Int = 0
    @State private var timer: Timer?
    @State private var showBlackBackground: Bool = false
    @State private var showConfirmationScreen: Bool = false
    @State private var showAd: Bool = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isSoundOn: Bool = true
//    @State private var SheepAnimate = false
    let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        ZStack {
            // Background
            if showBlackBackground {
                Color.black.edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            showBlackBackground.toggle()
                            if isSoundOn {
                                playSheepSound()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showBlackBackground = false
                                }
                        
                            }
//                            SheepAnimate.toggle()
                           
                        }
                       
                    }
            
//            Text("🐑")
//                 .font(.system(size: 100)) // Set the font size
//                 // Position the view off-screen to the right initially, and move it to the center when `animate` is true
//                 .offset(x: SheepAnimate ? 0 : UIScreen.main.bounds.width, y: 0)
//                 .animation(.easeInOut(duration: 1), value: SheepAnimate) // Animate the movement
         }
            else {
                LinearGradient(colors: [Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)), .white], startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showBlackBackground.toggle()
                            if isSoundOn {
                                playSheepSound()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showBlackBackground = false
                                }
                            }
                        }
                    }
            }

            // Content
            VStack {
                HStack {
                    Button(action: {
                        showAd = true
                    }) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                   
                    Button(action: {
                        showConfirmationScreen = true
                    }) {
                        
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.horizontal)
                
                Spacer()
              
                Text("\(sheepCount) 🐑")
                    .font(.system(size: 133))
                    .padding()
                    .foregroundColor(.white)
                    .onTapGesture {
                        withAnimation {
                            showBlackBackground.toggle()
                            if isSoundOn {
                                playSheepSound()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showBlackBackground = false
                                }
                            }
                        }
                    }

                if isCounting {
                    Button(action: stopCounting) {
                        Text("Stop")
                            .font(.title)
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .cornerRadius(25.0)
                    }
                } else {
                    Button(action: startCounting)
                    {
                        Text("Start")
                            .font(.title)
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .cornerRadius(25.0)
                    }
                }
               
                Spacer()
                //sheep appear
//                Text("🐑")
//                    .font(.system(size: 100)) // Set the font size
//                    // Position the view off-screen to the right initially, and move it to the center when `animate` is true
//                    .offset(x: SheepAnimate ? 0 : UIScreen.main.bounds.width, y: 0)
//                    .animation(.easeInOut(duration: 1), value: SheepAnimate) // Animate the movement
                
            }
            .sheet(isPresented: $showAd) {
                AdView(onConfirm: {
                    // Handle confirmation action here
                    showAd = false
                }, isSoundOn: $isSoundOn)
            }
            .sheet(isPresented: $showConfirmationScreen) {
                ConfirmationView(onConfirm: {
                    // Handle confirmation action here
                    showConfirmationScreen = false
                })
            }
        }
        .onAppear {
            setupAudioPlayer()
        }
    }

    func startCounting() {
        isCounting = true
        sheepCount += 1 // Immediately count 1 sheep
           speakSheepCount()
        
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
            if sheepCount < Int.max {
                sheepCount += 1
                speakSheepCount()
            }
        }
    }

    func stopCounting() {
        isCounting = false
        timer?.invalidate()
        sheepCount = 0
    }

    func speakSheepCount() {
        let utterance = AVSpeechUtterance(string: "\(sheepCount) sheep")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }

    func setupAudioPlayer() {
        if let path = Bundle.main.path(forResource: "sheep", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        } else {
            print("Audio file not found")
        }
    }

    func playSheepSound() {
        audioPlayer?.play()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AdView: View {
    var onConfirm: () -> Void
    @Binding var isSoundOn: Bool // Changed to @Binding

   
    var body: some View {
        VStack {
            Toggle(isOn: $isSoundOn, label: {
                Text("Sheep Sound \(isSoundOn ? "On" : "Off")")
                    .foregroundColor(.white)
            })
            // Other content...
            Text("Ad.")
                           .font(.title)
//                           .bold()
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                       
                       Text("Dry Eye Read.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/id/app/dry-eye-read/id6474282023") {
                                   UIApplication.shared.open(url)
                               }
                           }
                       
                       Text("iProgramMe.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/id/app/iprogramme/id6470770935") {
                                   UIApplication.shared.open(url)
                               }
                           }
                       
                       Text("LoopSpeak.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/id/app/loopspeak/id6473384030") {
                                   UIApplication.shared.open(url)
                               }
                           }
                       
                       Text("TimeTell.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/app/time-tell/id6479016269") {
                                   UIApplication.shared.open(url)
                               }
                           }
                       
                       Text("TemptationTrack.")
                           .font(.title)
//                           .monospaced()
                           .padding()
                           .foregroundColor(.white)
                           .onTapGesture {
                               if let url = URL(string: "https://apps.apple.com/id/app/temptationtrack/id6471236988") {
                                   UIApplication.shared.open(url)
                               }
                           }

                       Spacer()

                       Button("Close") {
                           // Perform confirmation action
                           onConfirm()
                       }
                       .font(.title)
                       .padding()
                       .foregroundColor(.black)
                       .background(Color.white)
                       .cornerRadius(25.0)
                       .padding()
                   
        }
        .padding()
        .background(Color.black)
        .cornerRadius(15.0)
        .padding()
    }
}
struct ConfirmationView: View {
   var onConfirm: () -> Void

   
    var body: some View {
       VStack {
           Text("If you hear the sheep counting, give us a tap on the screen to confirm you're not counting them in your sleep. If you don't tap, well, we'll assume you've drifted off into a fluffy dreamland and activate our snooze mode.")
               .font(.title)
//                       .monospaced()
               .padding()
               .foregroundColor(.white)

          
           Spacer()

           Button("Close") {
               // Perform confirmation action
               onConfirm()
           }
           .font(.title)
           .padding()
           .foregroundColor(.black)
           .background(Color.white)
           .cornerRadius(25.0)
           .padding()
       }
       .padding()
       .background(Color.black)
       .cornerRadius(15.0)
       .padding()
   }
}
*/
