//
//  MainAppView.swift
//  Time Tell
//
//  Created by Pieter Yoshua Natanael on 04/12/24.
//


import SwiftUI
import CoreLocation

struct MainAppView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Image(systemName: "atom")
                    Text("The Sheep")
                }
                .tag(0)
            
           StoryView()
                .tabItem {
                    Image(systemName: "repeat")
                    Text("BedTime Story")
                }
                .tag(1)
            
            ListView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Story Library")
                }
                .tag(2)
            
            AutoLockView()
                .tabItem {
                    Image(systemName: "eye.fill")
                    Text("Sleep Detection")
                }
                .tag(3)
            
            
        }
        .accentColor(Color(#colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)))
    }
}
