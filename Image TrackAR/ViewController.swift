//
//  ViewController.swift
//  Image TrackAR
//
//  Created by yuma@duck on 22/9/18.
//  Copyright © 2018 yuma@duck. All rights reserved.
//

// Hello! Before you try out the app, please check the AR Resources in "assets.xcassets". Thanks!

import UIKit
import SceneKit
import ARKit
import AVFoundation
import SpriteKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        guard let arImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        configuration.trackingImages = arImages
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARImageAnchor else { return }
        
        // Container
        guard let container = sceneView.scene.rootNode.childNode(withName: "container", recursively: false) else { return }
        container.removeFromParentNode()
        node.addChildNode(container)
        container.isHidden = false
        
        // Video
        let videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4")!
        let videoPlayer = AVPlayer(url: videoURL)
        
        //audio test
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        //end audio test
        let videoScene = SKScene(size: CGSize(width: 720.0, height: 1080.0))
        
        let videoNode = SKVideoNode(avPlayer: videoPlayer)
        videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
        videoNode.size = videoScene.size
        videoNode.yScale = -1
        videoNode.play()
        
        videoScene.addChild(videoNode)
        
        guard let video = container.childNode(withName: "video", recursively: true) else { return }
        video.geometry?.firstMaterial?.diffuse.contents = videoScene
        
        // Animations
        guard let videoContainer = container.childNode(withName: "videoContainer", recursively: false) else { return }
        //loop
        videoPlayer.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ViewController.playerItemDidReachEnd),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: videoPlayer.currentItem)
        
        videoContainer.runAction(SCNAction.sequence([SCNAction.wait(duration: 1.0), SCNAction.scale(to: 1.0, duration: 0.5)]))

    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
