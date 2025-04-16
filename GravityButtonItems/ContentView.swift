//
//  ContentView.swift
//  GravityButtonItems
//
//  Created by Killua Zoldyck on 4/16/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        ZStack {
            GravityBoxView()
                .ignoresSafeArea()
        }
    }
}
#Preview {
    ContentView()
}
