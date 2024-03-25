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
