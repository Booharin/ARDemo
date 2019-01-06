//
//  ViewController.swift
//  ARDemo
//
//  Created by Booharin on 07/12/2018.
//  Copyright © 2018 Booharin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    var planes = [Plane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        // Show statistics such as fps and timing information
       // sceneView.showsStatistics = true
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
        
        let scene = SCNScene()

        sceneView.scene = scene
        sceneView.scene.physicsWorld.contactDelegate = self
        
        setupGestures()
    }
    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(placeVirtualObject))
        tap.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tap)
        
//        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(placeBox))
//        doubleTap.numberOfTapsRequired = 2
//        sceneView.addGestureRecognizer(doubleTap)
    }
    
    //MARK: - place box
    @objc func placeBox(tapGesture: UITapGestureRecognizer) {
        guard let sceneView = tapGesture.view as? ARSCNView else { return }
        let location = tapGesture.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        guard let hitResult = hitTestResult.first else { return }
        
        createBox(hitResult: hitResult)
    }
    
    private func createBox(hitResult: ARHitTestResult) {
        let position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                  hitResult.worldTransform.columns.3.y + 0.5,
                                  hitResult.worldTransform.columns.3.z)
        
        let box = Box(atPosition: position)
        sceneView.scene.rootNode.addChildNode(box)
    }
    
    //MARK: - place gun
    @objc func placeVirtualObject(tapGesture: UITapGestureRecognizer) {
        self.sceneView.scene.removeAllParticleSystems()
        
        guard let sceneView = tapGesture.view as? ARSCNView else { return }
        let location = tapGesture.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        guard let hitResult = hitTestResult.first else { return }
        
        createVirtualObject(hitResult: hitResult)
    }
    
    private func createVirtualObject(hitResult: ARHitTestResult) {
        let position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                  hitResult.worldTransform.columns.3.y,
                                  hitResult.worldTransform.columns.3.z)
        
        guard let virtualObject = VirtualObject.availableObjects.first else { return }
        virtualObject.position = position
        virtualObject.load()
        
        if let particleSystem = SCNParticleSystem(named: "smoke.scnp", inDirectory: nil),
            let smokeNode = virtualObject.childNode(withName: "SmokeNode", recursively: true) {
            
            smokeNode.addParticleSystem(particleSystem)
        }
        
        sceneView.scene.rootNode.addChildNode(virtualObject)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ARWorldTrackingConfiguration.isSupported {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            sceneView.session.run(configuration)
        } else {
            let configuration = AROrientationTrackingConfiguration()
            sceneView.session.run(configuration)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        let plane = Plane(anchor: anchor)
        self.planes.append(plane)
        node.addChildNode(plane)
        #if DEBUG
        print("Plane detected")
        #endif
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let plane = self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
        }.first
        
        guard plane != nil else { return }
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        plane?.update(anchor: anchor)
    }
}

extension ViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        if nodeB.physicsBody?.contactTestBitMask == BitMaskCategory.box {
            nodeA.geometry?.materials.first?.diffuse.contents = UIColor.red
            return
        }
        nodeB.geometry?.materials.first?.diffuse.contents = UIColor.red
    }
}
