//
//  ImmersiveView.swift
//  DiceGame
//
//  Created by Pranav Gangurde on 5/30/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

//content view is the grey screen
//immersive view is the dice screen


let diceMap = [
    [1,6],
    [4,3],
    [2,5],
]


struct ImmersiveView: View {
    
    @State var droppedDice = false
    @State var dropShark = false
    @State private var sharkEntity: Entity?
    var diceData: DiceData
    @State private var style: ImmersionStyle = .full

    var body: some View {
        
        
        RealityView { content in
            
            let floor = ModelEntity(mesh: .generatePlane(width: 50, depth: 50), materials: [OcclusionMaterial()])
            floor.generateCollisionShapes(recursive: false)
            floor.components.set(GroundingShadowComponent(castsShadow: false, receivesShadow: true))
            floor.components[PhysicsBodyComponent.self] = .init(
                massProperties: .default,
                mode: .static
            )
            content.add(floor)
            
            
            
            if let diceModel = try? await Entity(named: "dice"),
            let dice = diceModel.children.first?.children.first,
            let env = try? await EnvironmentResource(named: "studio"){
                dice.scale = [0.1,0.1,0.1]
                dice.position.y = 0.5
                dice.position.z = -1
                
                
                
                dice.generateCollisionShapes(recursive: false)
                dice.components.set(InputTargetComponent())
                dice.components.set(GroundingShadowComponent(castsShadow: true))
                
                
                
//                dice.components.set(ImageBasedLightComponent(source: .single(env)))
                dice.components.set(ImageBasedLightComponent(source: .single(env)))
                dice.components.set(ImageBasedLightReceiverComponent(imageBasedLight: dice))
                
                
                
                
                dice.components[PhysicsBodyComponent.self] = .init(
                    massProperties: .default,
                    material: .generate(staticFriction: 0.8, dynamicFriction: 0.5, restitution: 0.1),
                    mode: .dynamic
                )
                
                dice.components[PhysicsMotionComponent.self] = .init()
                
                
                
                content.add(dice)
//                content.add(shark)
                
                
                let _ = content.subscribe(to: SceneEvents.Update.self){event in
                    guard droppedDice else{return}
                    guard let diceMotion = dice.components[PhysicsMotionComponent.self] else { return }
                    
                    
                    if simd_length(diceMotion.linearVelocity) < 0.1 && simd_length(diceMotion.angularVelocity) < 0.1{
                        let xDirection = dice.convert(direction: SIMD3(x:1, y:0, z:0), to: nil)
                        let yDirection = dice.convert(direction: SIMD3(x:0, y:1, z:0), to: nil)
                        let zDirection = dice.convert(direction: SIMD3(x:0, y:0, z:1), to: nil)
                        
                        let greatestDirection = [
                            0: xDirection.y,
                            1: yDirection.y,
                            2: zDirection.y,
                        ]
                            .sorted(by: {abs($0.1) > abs($1.1)})[0]
                        
                        
                        let rolledValue = diceMap[greatestDirection.key][greatestDirection.value > 0 ? 0 : 1]
                        diceData.rolledNumber = rolledValue
                        
//                        Task {
//                            await jumpShark(times: rolledValue)
//                        }
//                        
                        
                    
                    }
                    
                }
                
            }
            
            
            
            
        }
        .gesture(newGesture)
    }
    
    
    var newGesture: some Gesture{
        DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
                value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic
                print(value.entity.name)
                
            }
            .onEnded { value in
                value.entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
                
                if !droppedDice {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                        droppedDice = true
                    }
                }
                
                if !dropShark {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                        dropShark = true
                    }
                }
            }
    }
    
    var dragGesture : some Gesture{
        DragGesture()
            .targetedToAnyEntity()
            .onChanged(){value in
                value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
                value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic
            }
            .onEnded(){value in
                value.entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
                
                if !droppedDice{
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false){_ in
                        droppedDice = true
                    }
                }
                
                if !dropShark{
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false){_ in
                        dropShark = true
                    }
                }
                
                
            }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView(diceData: DiceData())
        .environment(AppModel())
}
