// MARK: - StoryView.swift
// This file contains the StoryView for the Insomnia Sheep app, which allows users to read and listen to bedtime stories.
// It features text-to-speech functionality and ad display options.

import SwiftUI
import AVFoundation

// MARK: - StoryView
/// The main view for the Insomnia Sheep app, responsible for displaying the bedtime story and managing text-to-speech functionality.
struct StoryView: View {
    @State private var textToRead = "" // Text to be read aloud
    @State private var isReading = false // Indicates if the story is currently being read
    @State private var timer: Timer? // Timer for managing playback
    @State private var showAd: Bool = false // Indicates if the ad view should be shown
    @State private var showExplain: Bool = false // Indicates if the explanation view should be shown
    @State private var playbackRate: Float = 0.3 // Playback rate for text-to-speech
    @FocusState private var isTextEditorFocused: Bool // Focus state for text editor

    let speechSynthesizer = AVSpeechSynthesizer() // Speech synthesizer instance

    var body: some View {
        VStack {
            // AdView button
            HStack {
                Button(action: {
                    // Action for ad button (currently empty)
                }) {
                    Image(systemName: "") // Placeholder for ad button image
                        .font(.system(size: 30))
                        .padding()
                }
                Spacer()
                Button(action: {
                    showExplain = true // Show explanation view
                }) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color(#colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)))
                        .padding()
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
        // ViewAd and other button
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

    // MARK: - Text-to-Speech Functionality
    /// Speaks the given text using the speech synthesizer.
    func speak(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.rate = playbackRate
        speechSynthesizer.speak(speechUtterance)
    }

    // MARK: - Start Loop Function
    /// Starts the text-to-speech loop.
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

    // MARK: - Stop Loop Function
    /// Stops the text-to-speech loop.
    func stopLoop() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
}

// MARK: - ShowAdView
/// A view for displaying ads.
struct ShowAdView: View {
    var onConfirm: () -> Void // Callback for confirming ad view

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

// MARK: - ShowExplainView
/// A view for displaying explanations.
struct ShowExplainView: View {
    var onConfirm: () -> Void // Callback for confirming explanation view

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Ads & App Functionality")
                        .font(.title3.bold())
                    Spacer()
                }
                Divider().background(Color.gray)

                // ads
                VStack {
                    HStack {
                        Text("Ads")
                            .font(.largeTitle.bold())
                        Spacer()
                    }
                    // App Cards
                    VStack {

                        Divider().background(Color.gray)
                        AppCardView(imageName: "bst", appName: "Blink Screen Time", appDescription: "Using screens can reduce your blink rate to just 6 blinks per minute, leading to dry eyes and eye strain. Our app helps you maintain a healthy blink rate to prevent these issues and keep your eyes comfortable.", appURL: "https://apps.apple.com/id/app/blink-screen-time/id6587551095")

                        Spacer()

                    }
                    // .padding()
                    // .cornerRadius(15.0)
                    // .padding()
                }
                // ads end

                HStack {
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }

                Text("""
               • Type or paste your story text
               • Press the start button to initiate the BedTime story loop
               • Press stop to stop the BedTime story loop
               • Use the slider to adjust reading speed.
               • We do not collect data
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

// MARK: - Preview for SwiftUI
struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView() // Preview of StoryView
    }
}
