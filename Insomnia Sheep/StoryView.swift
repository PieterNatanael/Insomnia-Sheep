//
//  StoryView.swift
//  Insomnia Sheep
//
//  Created by Pieter Yoshua Natanael on 09/12/24.
//


import SwiftUI
import AVFoundation

struct StoryView: View {
    @State private var textToRead = ""
    @State private var isReading = false
    @State private var timer: Timer?
    @State private var showAd: Bool = false
    @State private var showExplain: Bool = false
    @State private var playbackRate: Float = 0.3
    @FocusState private var isTextEditorFocused: Bool
    
    
    let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack {
            //AdView button
            HStack{
             
                
                Button(action: {
                                    }) {
                    Image(systemName: "")
                        .font(.system(size: 30))
//                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                    Button(action: {
                        showExplain = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(#colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)))
//                            .foregroundColor(.white)
                            .padding()
                    }
                }
            }

            
            Text("Bedtime Story")
                .font(.largeTitle.bold())
                .padding()

            TextEditor(text: $textToRead)
                .padding()
                .focused($isTextEditorFocused)
            
            HStack {
                Button(action: {
                    if isReading {
                        stopLoop()
                    } else {
                        startLoop()
                    }
                    isReading.toggle()
                }) {
                    Text(isReading ? "Stop" : "Start")
                        .bold()
                        .frame(maxWidth: .infinity)
                    
                        .padding()
                        .foregroundColor(.white)
                        .background(isReading ? Color.green : Color(#colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)))
                        .cornerRadius(10)
                }
                
                Button(action: {
                                  // Paste functionality
                                  textToRead = UIPasteboard.general.string ?? ""
                              }) {
                                  Image(systemName: "doc.on.clipboard.fill")
                                      .font(.system(size: 30))
                                      .foregroundColor(Color(#colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)))
                                      .padding()
                              }
                
                Button(action: {
                    textToRead = ""
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(Color(#colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)))
                }
                         
                              Spacer()
            }
            
            HStack {
                Text("Speed")
                Slider(value: $playbackRate, in: 0.05...0.6, step: 0.05) {
                    Text("Playback Speed")
                }
                .accentColor(Color(#colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)))
                .padding()
                Text(String(format: "%.2fx", playbackRate))
            }
            .padding()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isTextEditorFocused = false
                }
            }
        }
        .onTapGesture {
            // Dismiss keyboard when tapping outside text editor
            isTextEditorFocused = false
        }
        //ViewAd and other button
        .sheet(isPresented: $showAd) {
            ShowAdView(onConfirm: {
                showAd = false
            })
        }
        
        .sheet(isPresented: $showExplain) {
            ShowExplainView(onConfirm: {
                showExplain = false
            })
        }
        .padding()
    }

    func speak(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.rate = playbackRate
        speechSynthesizer.speak(speechUtterance)
    }
    

    func startLoop() {
        // Use a while loop to continuously speak until stopped
        DispatchQueue.global(qos: .background).async {
            while self.isReading {
                self.speak(text: self.textToRead)
                
                // Wait until speech is finished before next iteration
                while self.speechSynthesizer.isSpeaking && self.isReading {
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }
        }
    }

    func stopLoop() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    
}



struct ShowAdView: View {
   var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                Text("Behind the Scenes.")
                                    .font(.title)
                                    .padding()
                                    .foregroundColor(.white)

                                // Your ad content here...

                                Text("Thank you for buying our app with a one-time fee, it helps us keep up the good work. Explore these helpful apps as well. ")
                    .font(.title3)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                
                
                
             
           

               Spacer()

               Button("Close") {
                   // Perform confirmation action
                   onConfirm()
               }
               .font(.title)
               .padding()
               .foregroundColor(Color(#colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)))
               .background(Color.white)
               .cornerRadius(25.0)
               .padding()
           }
           .padding()
           .background(Color(#colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)))
           .cornerRadius(15.0)
       .padding()
        }
   }
}



// MARK: - Explain View
struct ShowExplainView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
               HStack{
                   Text("Ads & App Functionality")
                       .font(.title3.bold())
                   Spacer()
               }
                Divider().background(Color.gray)
              
                //ads
                VStack {
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
                        
                        Divider().background(Color.gray)
                        AppCardView(imageName: "bst", appName: "Blink Screen Time", appDescription: "Using screens can reduce your blink rate to just 6 blinks per minute, leading to dry eyes and eye strain. Our app helps you maintain a healthy blink rate to prevent these issues and keep your eyes comfortable.", appURL: "https://apps.apple.com/id/app/blink-screen-time/id6587551095")
                        
                        
                       
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
               •Type or paste your story text
               •Press the start button to initiate the BedTime story loop
               •Press stop to stop the BedTime story loop
               •Use the slider to adjust reading speed.
               •We do not collect data
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
               .font(.title)
               .frame(maxWidth: .infinity)
               .padding()
               .background(Color(#colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)))
               .foregroundColor(.white)
               .cornerRadius(10)
               .padding(.vertical, 10)
           }
           .padding()
           .cornerRadius(15.0)
           .padding()
        }
    }
}


struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView()
    }
}


/*
// ada kendala 500 words okay, tapi 3000 words jadi error dan restart sendiri, jadi mau di update kode nya

import SwiftUI
import AVFoundation

struct StoryView: View {
    @State private var textToRead = ""
    @State private var isReading = false
    @State private var timer: Timer?
    @State private var showAd: Bool = false
    @State private var showExplain: Bool = false
    @State private var playbackRate: Float = 0.3
    @FocusState private var isTextEditorFocused: Bool
    
    
    let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack {
            //AdView button
            HStack{
             
                
                Button(action: {
                                    }) {
                    Image(systemName: "")
                        .font(.system(size: 30))
//                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                    Button(action: {
                        showExplain = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color.red)
//                            .foregroundColor(.white)
                            .padding()
                    }
                }
            }

            
            Text("Bedtime Story")
                .font(.largeTitle.bold())
                .padding()

            TextEditor(text: $textToRead)
                .padding()
                .focused($isTextEditorFocused)
            
            HStack {
                Button(action: {
                    if isReading {
                        stopLoop()
                    } else {
                        startLoop()
                    }
                    isReading.toggle()
                }) {
                    Text(isReading ? "Stop" : "Start")
                        .bold()
                        .frame(maxWidth: .infinity)
                    
                        .padding()
                        .foregroundColor(.white)
                        .background(isReading ? Color.green : Color.red)
                        .cornerRadius(10)
                }
                
                Button(action: {
                                  // Paste functionality
                                  textToRead = UIPasteboard.general.string ?? ""
                              }) {
                                  Image(systemName: "doc.on.clipboard.fill")
                                      .font(.system(size: 30))
                                      .foregroundColor(Color.red)
                                      .padding()
                              }
                
                Button(action: {
                    textToRead = ""
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                         
                              Spacer()
            }
            
            HStack {
                Text("Speed")
                Slider(value: $playbackRate, in: 0.05...0.6, step: 0.05) {
                    Text("Playback Speed")
                }
                .accentColor(.red)
                .padding()
                Text(String(format: "%.2fx", playbackRate))
            }
            .padding()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isTextEditorFocused = false
                }
            }
        }
        .onTapGesture {
            // Dismiss keyboard when tapping outside text editor
            isTextEditorFocused = false
        }
        //ViewAd and other button
        .sheet(isPresented: $showAd) {
            ShowAdView(onConfirm: {
                showAd = false
            })
        }
        
        .sheet(isPresented: $showExplain) {
            ShowExplainView(onConfirm: {
                showExplain = false
            })
        }
        .padding()
    }

    func speak(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.rate = playbackRate
        speechSynthesizer.speak(speechUtterance)
    }
    

    func startLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.speak(text: self.textToRead) // Explicitly use self here
        }
    }

    func stopLoop() {
        timer?.invalidate()
        timer = nil
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
}



struct ShowAdView: View {
   var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                Text("Behind the Scenes.")
                                    .font(.title)
                                    .padding()
                                    .foregroundColor(.white)

                                // Your ad content here...

                                Text("Thank you for buying our app with a one-time fee, it helps us keep up the good work. Explore these helpful apps as well. ")
                    .font(.title3)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                
                
                
             
           

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
           .background(Color(#colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)))
           .cornerRadius(15.0)
       .padding()
        }
   }
}



// MARK: - Explain View
struct ShowExplainView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
               HStack{
                   Text("Ads & App Functionality")
                       .font(.title3.bold())
                   Spacer()
               }
                Divider().background(Color.gray)
              
                //ads
                VStack {
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
                        
                        Divider().background(Color.gray)
                        AppCardView(imageName: "bst", appName: "Blink Screen Time", appDescription: "Using screens can reduce your blink rate to just 6 blinks per minute, leading to dry eyes and eye strain. Our app helps you maintain a healthy blink rate to prevent these issues and keep your eyes comfortable.", appURL: "https://apps.apple.com/id/app/blink-screen-time/id6587551095")
                        
                        
                       
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
               •Type or paste your story text
               •Press the start button to initiate the BedTime story loop
               •Press stop to stop the BedTime story loop
               •Use the slider to adjust reading speed.
               •We do not collect data
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
               .font(.title)
               .frame(maxWidth: .infinity)
               .padding()
               .background(Color.blue)
               .foregroundColor(.white)
               .cornerRadius(10)
               .padding(.vertical, 10)
           }
           .padding()
           .cornerRadius(15.0)
           .padding()
        }
    }
}


struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView()
    }
}
*/
