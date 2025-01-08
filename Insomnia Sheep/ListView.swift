//
//  ListView.swift
//  LoopSpeak
//
//  Created by Pieter Yoshua Natanael on 09/12/24.
//

import SwiftUI

struct TextEntry: Identifiable, Codable {
    let id: UUID
    var text: String
    var previewText: String
    var dateCreated: Date
    
    init(text: String) {
        self.id = UUID()
        self.text = text
        // Create preview text (first 3 lines or first 100 characters)
        let lines = text.components(separatedBy: .newlines)
        self.previewText = lines.prefix(3).joined(separator: "\n")
        self.dateCreated = Date()
    }
}

struct ListView: View {
    @State private var savedTexts: [TextEntry] = []
    @State private var newText: String = ""
    @State private var showCopyConfirmation: Bool = false
    @FocusState private var isTextEditorFocused: Bool
    @State private var showAdsAndAppFunctionality = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    showAdsAndAppFunctionality = true
                }) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color(#colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)))
                        .padding()
                     
                }
            }
            NavigationView {
                VStack {
                    
                    // Text Input Section
                    VStack {
                        TextEditor(text: $newText)
                            .frame(height: 150)
                            .border(Color.gray.opacity(0.3), width: 1)
                            .padding()
                            .focused($isTextEditorFocused)
                        
                        HStack {
                            
                            
                            Button(action: saveText) {
                                Text("Save Story")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(#colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(newText.isEmpty)
                            
                            // Paste Button
                            Button(action: {
                                newText = UIPasteboard.general.string ?? ""
                            }) {
                                Image(systemName: "doc.on.clipboard.fill")
                                    .foregroundColor(Color(#colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)))
                            }
                            .padding(.horizontal)
                            
                            Button(action: {
                                newText = ""
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(Color(#colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)))
                            }
                            
                        }
                    }
                    
                    // Saved Texts List
                    List {
                        ForEach(savedTexts) { entry in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(entry.previewText)
                                        .font(.caption)
                                        .lineLimit(3)
                                    
                                    Text(entry.dateCreated, style: .date)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    // Copy text to clipboard
                                    UIPasteboard.general.string = entry.text
                                    showCopyConfirmation = true
                                }) {
                                    Image(systemName: "doc.on.clipboard")
                                        .foregroundColor(Color(#colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)))
                                }
                            }
                        }
                        .onDelete(perform: deleteEntries)
                    }
                }
                .navigationTitle("Story Library")
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isTextEditorFocused = false
                        }
                    }
                }
                .sheet(isPresented: $showAdsAndAppFunctionality) {
                    ShowAdsAndAppFunctionalityView(onConfirm: {
                        showAdsAndAppFunctionality = false
                    })
                }
                
                .alert(isPresented: $showCopyConfirmation) {
                    Alert(
                        title: Text("Text Copied"),
                        message: Text("The text has been copied to clipboard."),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .onTapGesture {
                    // Dismiss keyboard when tapping outside text editor
                    isTextEditorFocused = false
                }
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    // Save text to the list
    func saveText() {
        guard !newText.isEmpty else { return }
        
        let newEntry = TextEntry(text: newText)
        savedTexts.append(newEntry)
        
        // Clear text after saving
        newText = ""
        
        // Dismiss keyboard
        isTextEditorFocused = false
        
        // Save to UserDefaults
        saveToUserDefaults()
    }
    
    // Delete entries by IndexSet (used by .onDelete)
    func deleteEntries(at offsets: IndexSet) {
        savedTexts.remove(atOffsets: offsets)
        saveToUserDefaults()
    }
    
    // Save texts to UserDefaults for persistence
    func saveToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(savedTexts) {
            UserDefaults.standard.set(encoded, forKey: "savedTexts")
        }
    }
    
    // Load texts from UserDefaults on view initialization
    init() {
        if let savedTextsData = UserDefaults.standard.object(forKey: "savedTexts") as? Data {
            let decoder = JSONDecoder()
            if let loadedTexts = try? decoder.decode([TextEntry].self, from: savedTextsData) {
                _savedTexts = State(initialValue: loadedTexts)
            }
        }
    }
}


struct ShowAdsAndAppFunctionalityView: View {
    var onConfirm: () -> Void
    
    struct Story: Identifiable {
        let id = UUID()
        let title: String
        let description: String
    }
    
    // Sample stories
    let stories: [Story] = [
        Story(title: "A Smooth Journey to Mars",
              description: """
              
              Liam sat at the helm of the Celestial Voyager, staring blankly at the control panel in front of him. The soft hum of the spacecraft’s systems filled the air. It was the beginning of what would be a six-month journey to Mars, but Liam’s mind wandered. Everything was as it should be—perfectly routine.

              The launch had been flawless. The countdown, the thrust of the engines, the gradual escape from Earth's gravity—it was all so predictable, so calm. No malfunctions, no surprises. Everything had been checked and double-checked by the team. Even the weather on Earth was clear. "Just another day in the life of an astronaut," Liam thought, absently glancing at the Earth fading into the distance.

              His crewmates, all equally calm and collected, sat in their designated sections of the ship, quietly performing their tasks. Dr. Mia Patel, the mission’s chief scientist, reviewed data on the mission’s research protocols. Lt. James O’Connor, the flight engineer, was running diagnostics on the spacecraft’s propulsion system, making sure the engines were running as smoothly as they had during the test flights. Captain Ava Mitchell sat at the front, her eyes on the controls, but her mind seemed far away, lost in thoughts about the months ahead.

              Liam pulled up the mission log on his screen and added an entry: “Launch successful. All systems operational. No issues.” He hit save and leaned back in his chair, watching the stars streak past as the ship accelerated into deep space. There was nothing to do now except wait.

              Days turned into weeks. The routine of life aboard Celestial Voyager quickly settled in. Each day felt exactly the same as the one before it. Liam woke up at 6:00 AM, stretched, and began his morning routine: breakfast, a quick workout in the small gym, a check of his personal gear, and then a review of the ship’s systems. There were always reports to file, data to record, but nothing had changed. Every system was running perfectly, without a hitch.

              Dr. Patel would occasionally ask Liam to double-check some of the scientific equipment, but most of the time, she was absorbed in her own research. Lt. O’Connor, who had a habit of humming while working, was constantly running diagnostics on the spacecraft's various systems, making sure everything was functioning as expected.

              The meals were bland, pre-packaged, and tasteless. At first, Liam had tried to find joy in the food, imagining that the freeze-dried lasagna would taste like home. But after the first few days, it became clear that it was nothing more than sustenance. "At least it’s not completely inedible," he thought, chewing a bite of scrambled eggs that tasted more like cardboard than food.

              The crew would gather for lunch in the mess hall, but the conversations were always the same. They talked about Earth, about their families, about what they’d do once they returned. They all knew the rules of space travel: no complaints, no negativity. You don’t complain about the food, the long hours, the isolation. It was part of the job. So, they talked about trivial things, passing the time until the next task.

              “How’s the weather back home?” Dr. Patel asked one day, looking up from her tablet.

              “Clear skies,” Lt. O’Connor replied, a slight smile tugging at his lips. “Same as usual.”

              “Nice,” Liam muttered, nodding. “I think I’ll take a walk in the park when I get back.”

              That was about as exciting as it got.

              Weeks turned into months, and the Earth was now a distant memory. The vast emptiness of space stretched on, a constant reminder of how far away they were from home. Liam occasionally glanced out the window, watching the stars glimmer in the blackness. There was something soothing about it, but also incredibly lonely. Nothing to see but a sea of stars.

              The crew had settled into a rhythm. Every day felt like the one before it, each hour stretching into the next. The most exciting part of the day was the daily maintenance check. The engines were still running smoothly. The air filtration system was still working. The spacecraft still floated through space without a hitch.

              Liam kept busy with his own tasks. He ran diagnostics on the navigation system, made sure all the equipment was calibrated, and ensured that the communications systems were functioning. It was a lot of work, but it was also incredibly repetitive. The only variation was the occasional communication with mission control back on Earth, but even that had become a routine. The operators would give the crew updates on the progress of the mission, but there was nothing groundbreaking to report. “All systems are operational. No issues. Keep up the good work,” they would say.

              One day, Captain Mitchell called a meeting. “We’re approaching the halfway point,” she said, her voice as steady as ever. “No major issues so far. We’re ahead of schedule. Everyone is doing a great job.”

              Liam didn’t respond. There was nothing to say. The mission had been perfect—perhaps too perfect. There were no complications, no challenges to overcome. Everything was just… fine. And that was fine, but it left a lingering sense of emptiness. What were they really accomplishing? It was hard to shake the feeling that the mission was merely a technical exercise, devoid of the excitement that so many people had expected when they signed up for the Mars mission.

              The crew nodded in agreement, and the meeting quickly concluded. There was nothing more to discuss. The ship continued its journey, slicing through the black void.

              The days continued, and the monotony became more pronounced. Time felt like it was both crawling and flying by. Liam couldn’t remember the last time he’d felt truly excited about something. It wasn’t that he was unhappy, per se. Everything was fine. Everything was perfect. But there was no thrill, no sense of wonder. He wondered if this was how astronauts in the past had felt—lost in space with nothing to do but maintain their ship and wait for their destination.

              And then, one day, it happened.

              They were passing through an area of space where the stars appeared to flicker, almost as if they were blinking in and out of existence. It was subtle, almost imperceptible, but it caught Liam’s attention. He sat up straighter in his chair and stared at the star field. It wasn’t a glitch in the ship’s system. It was real. Something was… strange.

              Liam didn’t know how long he stared, but after a few minutes, he realized that nothing was going to happen. The stars kept blinking, just like they had before. No sudden flashes of light, no cosmic events. Just… stars. After all this time, the momentary oddity was nothing but a brief distraction.

              As the days passed, the crew finally began to feel the effects of their prolonged isolation. Conversations in the mess hall started to take on a slightly more desperate tone, but the small talk never stopped. They continued to talk about what they’d do when they returned, imagining vacations to places they’d never visited. They discussed the books they would read, the music they would listen to, the food they would eat. But even these discussions were becoming repetitive. They were all stuck in a loop, locked in an endless cycle of perfection and predictability.

              When they finally reached Mars, it felt almost anticlimactic. The planet loomed on the horizon, its red surface slowly coming into view. “Mars,” Liam muttered to himself. But it wasn’t the exciting, adventurous place he had imagined. It was just another planet. Another rock floating in space, waiting to be explored. The landing was smooth, as expected. They deployed the rover, collected some samples, and planted the flag. The mission had been flawless.

              There was no grand celebration. No fanfare. Just the hum of the ship’s engines as they prepared for the journey back.

              Liam sighed and turned to Captain Mitchell. “Well, we did it,” he said.

              “Yeah,” she replied, her voice flat. “We did.”

              And so, the crew of the Celestial Voyager returned to Earth, just as they had left. No drama, no excitement—just a perfectly executed mission, with no real highs or lows.

              Liam stepped off the spacecraft, back on solid ground. But even as his feet touched the Earth again, he felt the same emptiness. Everything had gone according to plan, but it felt… incomplete. After months of nothing but perfection, he couldn’t help but wonder: was this all there was?


              """),
        
        Story(title: "First Day at the Office",
              description: """
                Emma walked into the office building precisely at 8:00 AM, just as instructed. She was greeted by Linda, the HR manager, who smiled politely and handed her a packet of onboarding materials. “Read these, sign here, and I’ll show you to your desk,” Linda said in a tone that was neither warm nor cold—just professional.

                After signing the forms and watching a mandatory orientation video, Emma was led to her cubicle. It was gray, clean, and unremarkable. On the desk was a computer, a stapler, and a welcome card signed by her new team. “We’re glad to have you,” it read. Emma smiled faintly and set it aside.

                Her manager, Mr. Johnson, stopped by to briefly introduce himself. “Welcome aboard,” he said, shaking her hand with just the right amount of firmness. “Take the day to get settled and go through the training modules. If you have questions, my door is open.”

                Emma spent the rest of the morning clicking through online training modules about company policies, safety procedures, and communication protocols. Each module ended with a short quiz, which she passed easily.

                At lunch, she ate a sandwich alone in the break room. A few coworkers walked in, nodded politely, and sat at another table, chatting quietly among themselves. Emma scrolled through her phone, feeling neither excited nor disappointed.

                The afternoon was much the same. She completed a few tasks assigned in her onboarding packet and sent a couple of emails to confirm her login credentials. At 5:00 PM sharp, she logged off her computer, packed up her things, and left the office.

                “How was your first day?” her roommate asked when she got home.
                “It was fine,” Emma replied.


"""),
        
        Story(title: "Stuck in the Hole",
              description: """
                Jake was walking through the woods when he accidentally stepped on a loose patch of earth, causing the ground beneath him to give way. He fell straight down into a small hole, about five feet deep.

                At first, Jake tried to climb out, using the sides of the hole for leverage, but the earth was too soft and crumbled beneath his hands. He stopped trying after a few attempts and simply sat down, staring at the sky through the small opening above him.

                The hole was silent. There was nothing to do but wait. Jake pulled out his phone to check the time: 12:15 PM. He didn’t have much signal, so he couldn’t call for help. “I guess I’ll just wait,” he muttered to himself.

                For the next hour, he did exactly that—waited. He could hear the occasional rustle of leaves and distant birds, but otherwise, there was no noise. He considered yelling for help but decided against it. “No one’s out here,” he thought. “I’ll be fine.”

                The minutes dragged on. He checked his phone again: 1:20 PM. He took a deep breath, trying to think of something to do. Nothing came to mind. He adjusted his position, trying to make himself more comfortable on the dirt floor.

                Around 3:00 PM, Jake finally heard footsteps. Someone had wandered nearby and heard him calling. They lowered a rope, and Jake was pulled out of the hole.

                “Thanks,” Jake said flatly as he stood up, brushing himself off.
                """)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Section header
                HStack {
                    Text("Ads & App Functionality")
                        .font(.title3.bold())
                    Spacer()
                }
                Divider().background(Color.gray)
                
                // Story section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Story For You")
                            .font(.largeTitle.bold())
                        Spacer()
                    }
                    Divider().background(Color.gray)
                    
                    ForEach(stories) { story in
                        VStack(alignment: .leading) {
                            Text(story.title)
                                .font(.title2.bold())
                                .padding(.bottom, 5)
                            Text(story.description)
                                .lineLimit(3) // Show only the first 3 rows
                                .font(.body)
                                .foregroundColor(.gray)
                                .padding(.bottom, 5)
                            Button(action: {
                                UIPasteboard.general.string = story.description
                            }) {
                                Text("Copy Full Story")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .underline()
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 1)
                    }
                }
                .padding()
                
                HStack {
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }
                Text("""
                • Save your favorite bedtime story here
                • Choose from 3 stories available
                • Copy and paste the story
                • Go to the Bedtime Story page to have it read for you
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
                
                // Close button
                Button("Close") {
                    onConfirm()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(#colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)))
                .foregroundColor(.white)
                .font(.title3.bold())
                .cornerRadius(10)
                .padding()
                .shadow(color: Color.white.opacity(0.12), radius: 3, x: 3, y: 3)
            }
            .padding()
            .cornerRadius(15.0)
        }
    }
}


// Preview for SwiftUI
struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
