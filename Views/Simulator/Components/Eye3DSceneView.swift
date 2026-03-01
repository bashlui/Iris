//
//  Eye3DSceneView.swift
//  Iris
//
//  Created by toño on 11/02/26.
//
//  SceneKit 3D eye model showing ray convergence for each condition.
//

import SwiftUI
import SceneKit

struct Eye3DSceneView: UIViewRepresentable {
    let selectedCondition: EyeCondition
    let eyeLength: Float
    let isCorrected: Bool
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = createScene()
        sceneView.backgroundColor = .clear
        sceneView.antialiasingMode = .multisampling4X
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = false
        return sceneView
    }
    
    func updateUIView(_ sceneView: SCNView, context: Context) {
        guard let scene = sceneView.scene else { return }
        
        // Update light rays based on condition
        updateLightRays(in: scene)
        
        // Update lens visibility
        updateLens(in: scene)
    }
    
    // MARK: - Scene Creation
    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        
        // Add ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 300
        ambientLight.light?.color = UIColor.white
        scene.rootNode.addChildNode(ambientLight)
        
        // Add directional light
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.intensity = 800
        directionalLight.light?.color = UIColor.white
        directionalLight.position = SCNVector3(5, 5, 5)
        directionalLight.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(directionalLight)
        
        // Create eye model
        let eyeNode = createEyeNode()
        eyeNode.name = "eye"
        scene.rootNode.addChildNode(eyeNode)
        
        // Create light rays
        let raysNode = createLightRaysNode()
        raysNode.name = "rays"
        scene.rootNode.addChildNode(raysNode)
        
        // Create correction lens (initially hidden)
        let lensNode = createLensNode()
        lensNode.name = "lens"
        lensNode.isHidden = true
        scene.rootNode.addChildNode(lensNode)
        
        // Create retina indicator
        let retinaNode = createRetinaNode()
        retinaNode.name = "retina"
        scene.rootNode.addChildNode(retinaNode)
        
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 45
        cameraNode.position = SCNVector3(0, 0, 8)
        cameraNode.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(cameraNode)
        
        return scene
    }
    
    // MARK: - Node Creation
    
    private func createEyeNode() -> SCNNode {
        let parentNode = SCNNode()
        
        // Main eyeball (outer shell - sclera)
        let eyeballGeometry = SCNSphere(radius: 1.2)
        let eyeballMaterial = SCNMaterial()
        eyeballMaterial.diffuse.contents = UIColor(red: 0.95, green: 0.92, blue: 0.9, alpha: 0.3)
        eyeballMaterial.transparency = 0.6
        eyeballMaterial.isDoubleSided = true
        eyeballGeometry.materials = [eyeballMaterial]
        
        let eyeballNode = SCNNode(geometry: eyeballGeometry)
        parentNode.addChildNode(eyeballNode)
        
        // Cornea (front bulge)
        let corneaGeometry = SCNSphere(radius: 0.5)
        let corneaMaterial = SCNMaterial()
        corneaMaterial.diffuse.contents = UIColor(red: 0.7, green: 0.85, blue: 0.95, alpha: 0.4)
        corneaMaterial.transparency = 0.5
        corneaMaterial.specular.contents = UIColor.white
        corneaMaterial.shininess = 1.0
        corneaGeometry.materials = [corneaMaterial]
        
        let corneaNode = SCNNode(geometry: corneaGeometry)
        corneaNode.position = SCNVector3(-1.0, 0, 0)
        parentNode.addChildNode(corneaNode)
        
        // Pupil
        let pupilGeometry = SCNCylinder(radius: 0.2, height: 0.05)
        let pupilMaterial = SCNMaterial()
        pupilMaterial.diffuse.contents = UIColor.black
        pupilGeometry.materials = [pupilMaterial]
        
        let pupilNode = SCNNode(geometry: pupilGeometry)
        pupilNode.position = SCNVector3(-1.35, 0, 0)
        pupilNode.eulerAngles = SCNVector3(0, 0, Float.pi / 2)
        parentNode.addChildNode(pupilNode)
        
        // Iris
        let irisGeometry = SCNTorus(ringRadius: 0.3, pipeRadius: 0.08)
        let irisMaterial = SCNMaterial()
        irisMaterial.diffuse.contents = UIColor(red: 0.3, green: 0.5, blue: 0.7, alpha: 1.0)
        irisMaterial.emission.contents = UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 0.3)
        irisGeometry.materials = [irisMaterial]
        
        let irisNode = SCNNode(geometry: irisGeometry)
        irisNode.position = SCNVector3(-1.3, 0, 0)
        irisNode.eulerAngles = SCNVector3(0, 0, Float.pi / 2)
        parentNode.addChildNode(irisNode)
        
        // Lens (inside eye)
        let lensGeometry = SCNSphere(radius: 0.35)
        lensGeometry.segmentCount = 24
        let lensMaterial = SCNMaterial()
        lensMaterial.diffuse.contents = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 0.2)
        lensMaterial.transparency = 0.7
        lensGeometry.materials = [lensMaterial]
        
        let internalLensNode = SCNNode(geometry: lensGeometry)
        internalLensNode.position = SCNVector3(-0.6, 0, 0)
        internalLensNode.scale = SCNVector3(1.0, 0.6, 0.6)
        parentNode.addChildNode(internalLensNode)
        
        return parentNode
    }
    
    private func createLightRaysNode() -> SCNNode {
        let parentNode = SCNNode()
        
        let rayPositions: [Float] = [-0.4, 0.0, 0.4]
        
        for (index, yPos) in rayPositions.enumerated() {
            // Incoming ray (from left to lens)
            let incomingRay = createRaySegment(length: 2.5)
            incomingRay.name = "incomingRay_\(index)"
            incomingRay.position = SCNVector3(-4.0, yPos, 0)
            incomingRay.eulerAngles = SCNVector3(0, 0, Float.pi / 2)
            parentNode.addChildNode(incomingRay)
            
            // Refracted ray (from lens to focal point)
            let refractedRay = createRaySegment(length: 2.0)
            refractedRay.name = "refractedRay_\(index)"
            refractedRay.position = SCNVector3(-1.5, yPos, 0)
            parentNode.addChildNode(refractedRay)
        }
        
        // Focal point indicator
        let focalGeometry = SCNSphere(radius: 0.1)
        let focalMaterial = SCNMaterial()
        focalMaterial.diffuse.contents = UIColor.yellow
        focalMaterial.emission.contents = UIColor.yellow
        focalMaterial.emission.intensity = 1.0
        focalGeometry.materials = [focalMaterial]
        
        let focalNode = SCNNode(geometry: focalGeometry)
        focalNode.name = "focalPoint"
        focalNode.position = SCNVector3(0.8, 0, 0)
        parentNode.addChildNode(focalNode)
        
        return parentNode
    }
    
    private func createRaySegment(length: Float) -> SCNNode {
        let rayGeometry = SCNCylinder(radius: 0.03, height: CGFloat(length))
        let rayMaterial = SCNMaterial()
        
        // Neon yellow glow
        rayMaterial.diffuse.contents = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        rayMaterial.emission.contents = UIColor(red: 1.0, green: 0.95, blue: 0.3, alpha: 1.0)
        rayMaterial.emission.intensity = 0.8
        rayGeometry.materials = [rayMaterial]
        
        return SCNNode(geometry: rayGeometry)
    }
    
    private func createLensNode() -> SCNNode {
        let parentNode = SCNNode()
        
        // Correction lens (glasses lens)
        let lensGeometry = SCNCylinder(radius: 0.8, height: 0.08)
        let lensMaterial = SCNMaterial()
        lensMaterial.diffuse.contents = UIColor(red: 0.6, green: 0.7, blue: 1.0, alpha: 0.3)
        lensMaterial.transparency = 0.6
        lensMaterial.specular.contents = UIColor.white
        lensMaterial.shininess = 0.8
        lensGeometry.materials = [lensMaterial]
        
        let lensNode = SCNNode(geometry: lensGeometry)
        lensNode.position = SCNVector3(-2.5, 0, 0)
        lensNode.eulerAngles = SCNVector3(0, 0, Float.pi / 2)
        parentNode.addChildNode(lensNode)
        
        // Lens frame
        let frameGeometry = SCNTorus(ringRadius: 0.85, pipeRadius: 0.05)
        let frameMaterial = SCNMaterial()
        frameMaterial.diffuse.contents = UIColor(red: 0.4, green: 0.3, blue: 0.6, alpha: 1.0)
        frameMaterial.metalness.contents = 0.8
        frameGeometry.materials = [frameMaterial]
        
        let frameNode = SCNNode(geometry: frameGeometry)
        frameNode.position = SCNVector3(-2.5, 0, 0)
        frameNode.eulerAngles = SCNVector3(0, 0, Float.pi / 2)
        parentNode.addChildNode(frameNode)
        
        return parentNode
    }
    
    private func createRetinaNode() -> SCNNode {
        // Retina indicator at the back of the eye
        let retinaGeometry = SCNCylinder(radius: 0.6, height: 0.05)
        let retinaMaterial = SCNMaterial()
        retinaMaterial.diffuse.contents = UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 0.8)
        retinaMaterial.emission.contents = UIColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 0.3)
        retinaGeometry.materials = [retinaMaterial]
        
        let retinaNode = SCNNode(geometry: retinaGeometry)
        retinaNode.position = SCNVector3(1.0, 0, 0)
        retinaNode.eulerAngles = SCNVector3(0, 0, Float.pi / 2)
        
        return retinaNode
    }
    
    // MARK: - Update Methods
    
    private func updateLightRays(in scene: SCNScene) {
        guard let raysNode = scene.rootNode.childNode(withName: "rays", recursively: false) else { return }
        
        let rayPositions: [Float] = [-0.4, 0.0, 0.4]
        
        // Calculate focal point based on condition
        var focalX: Float = 1.0 // Default: at retina (normal)
        
        switch selectedCondition {
        case .normal:
            focalX = isCorrected ? 1.0 : 1.0
        case .myopia:
            focalX = isCorrected ? 1.0 : (0.2 - eyeLength * 0.8) // In front of retina
        case .hyperopia:
            focalX = isCorrected ? 1.0 : (1.0 + eyeLength * 0.8) // Behind retina
        case .astigmatism:
            focalX = isCorrected ? 1.0 : 0.8
        }
        
        // Update focal point position
        if let focalNode = raysNode.childNode(withName: "focalPoint", recursively: false) {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.3
            focalNode.position = SCNVector3(focalX, 0, 0)
            
            // Change color based on whether focus is correct
            if let geometry = focalNode.geometry as? SCNSphere,
               let material = geometry.materials.first {
                if abs(focalX - 1.0) < 0.1 {
                    material.diffuse.contents = UIColor.green
                    material.emission.contents = UIColor.green
                } else {
                    material.diffuse.contents = UIColor.red
                    material.emission.contents = UIColor.red
                }
            }
            SCNTransaction.commit()
        }
        
        // Update refracted rays to point to focal point
        for (index, yPos) in rayPositions.enumerated() {
            if let refractedRay = raysNode.childNode(withName: "refractedRay_\(index)", recursively: false) {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.3
                
                // Calculate angle to focal point
                let startX: Float = -1.5
                let startY: Float = yPos
                let deltaX = focalX - startX
                let deltaY: Float = 0 - startY
                let angle = atan2(deltaY, deltaX)
                let length = sqrt(deltaX * deltaX + deltaY * deltaY)
                
                // Update ray
                if let cylinder = refractedRay.geometry as? SCNCylinder {
                    cylinder.height = CGFloat(length)
                }
                
                refractedRay.position = SCNVector3(startX + deltaX/2, startY + deltaY/2, 0)
                refractedRay.eulerAngles = SCNVector3(0, 0, angle + Float.pi/2)
                
                // Astigmatism: scatter the rays slightly
                if selectedCondition == .astigmatism && !isCorrected {
                    let scatter = Float(index - 1) * 0.15 * eyeLength
                    refractedRay.position.z = scatter
                }
                
                SCNTransaction.commit()
            }
        }
    }
    
    private func updateLens(in scene: SCNScene) {
        guard let lensNode = scene.rootNode.childNode(withName: "lens", recursively: false) else { return }
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        
        lensNode.isHidden = !isCorrected || selectedCondition == .normal
        
        // Animate lens appearance
        if isCorrected && selectedCondition != .normal {
            lensNode.scale = SCNVector3(1, 1, 1)
            lensNode.opacity = 1.0
        } else {
            lensNode.scale = SCNVector3(0.5, 0.5, 0.5)
            lensNode.opacity = 0.0
        }
        
        SCNTransaction.commit()
    }
}

// MARK: - Preview

#Preview {
    Eye3DSceneView(
        selectedCondition: .myopia,
        eyeLength: 0.7,
        isCorrected: false
    )
    .background(Color.black)
}
