//
//  ContentView.swift
//  DiceGame
//
//  Created by Pranav Gangurde on 5/30/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    var diceData : DiceData

    var body: some View {
        VStack {
//            Model3D(named: "Scene", bundle: realityKitContentBundle)
//                .padding(.bottom, 50)

            Text(diceData.rolledNumber == 0 ? "🎲" : "\(diceData.rolledNumber)")
                .foregroundStyle(.yellow)
                .font(.custom("Menlo", size: 100))
                .bold()

            ToggleImmersiveSpaceButton()
        }
        .padding()
        .task {
            
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(diceData: DiceData())
        .environment(AppModel())
}
