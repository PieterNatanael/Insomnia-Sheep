//
//  ContentView.swift
//  Insomnia Sheep
//
//  Created by Pieter Yoshua Natanael on 20/03/24.
//


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
