//
//  ViewController.swift
//  AR_Dice
//
//  Created by Elina Mansurova on 2021-01-11.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: sceneView)
        //convert touch location into 3D location inside the scene
        let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if let hitResult = results.first {
            let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
            guard let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) else { return }
            diceNode.position = SCNVector3(
                x: hitResult.worldTransform.columns.3.x,
                y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                z: hitResult.worldTransform.columns.3.z)
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            //set a random numbers for rotation of the dice
            let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
            let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
            //run it as animation
            diceNode.runAction(SCNAction.rotateBy(
                                x: CGFloat(randomX * 5),
                                y: 0,
                                z: CGFloat(randomZ * 5),
                                duration: 0.5))
        }
    }
        //set a horizontal plane
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        let planeAnchor = anchor as! ARPlaneAnchor
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode()
        
        //to set to the created horizontal plane
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        
        //rotating by 90 degrees clock-wise
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        
        node.addChildNode(planeNode)
    }

}
