//
//  DiceGameApp.swift
//  DiceGame
//
//  Created by Pranav Gangurde on 5/30/25.
//

import SwiftUI

@Observable
class DiceData{
    var rolledNumber = 0
}


@main
struct DiceGameApp: App {

    @State private var appModel = AppModel()
    @State private var diceData = DiceData()
    @State private var style: ImmersionStyle = .mixed

    var body: some Scene {
        WindowGroup {
            ContentView(diceData: diceData)
                .environment(appModel)
        }
        .defaultSize(width: 100, height: 100)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView(diceData: diceData)
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: $style, in: .mixed)
     }
}
