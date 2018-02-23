
/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Main view controller for the AR experience.
 */

import UIKit
import SceneKit
import ARKit

class ARSceneViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    // MARK: - IBOutlets
    
    //@IBOutlet weak var sceneView: ARSCNView!
    //@IBOutlet weak var sessionInfoView: UIView!
    //@IBOutlet weak var sessionInfoLabel: UILabel!
    //@IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
   // @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sessionView: UIVisualEffectView!
    
    var currentAngle: Float = 0.0
    var selectedImage: UIImage?
    var planeNode: SCNNode?
    var latestTranslatePos: CGPoint?
    var lastRotation: CGFloat = 0
    // MARK: - View Life Cycle
    
    /// - Tag: StartARSession
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        
        // Start the view's AR session with a configuration that uses the rear camera,
        // device position and orientation tracking, and plane detection.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration)
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self
        sceneView.delegate = self
       // sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ARSceneViewController.panRecognizer(sender:)))
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ARSceneViewController.pinchRecognizer(sender:)))
        let rotateRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(ARSceneViewController.rotateAction(sender:)))
        sceneView.addGestureRecognizer(pinchRecognizer)
        sceneView.addGestureRecognizer(panRecognizer)
        sceneView.addGestureRecognizer(rotateRecognizer)
        //adding a pinch recognizer (This works)
//        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: Selector(("pinchGesture:")))
//        sceneView.addGestureRecognizer(pinchRecognizer)
        // Show debug UI to view performance metrics (e.g. frames per second).
        //sceneView.showsStatistics = true
    }
    
    @objc func rotateAction(sender:UIRotationGestureRecognizer){
        var originalRotation = CGFloat()
        if sender.state == .began{
            sender.rotation = lastRotation
            originalRotation = sender.rotation
        }
        if sender.state == .changed{
            let translation = sender.rotation + originalRotation
            let pan_x = Float(translation)
//            let pan_y = Float(-translation)
//            let anglePan = sqrt(pow(pan_x,2)+pow(pan_y,2))*(Float)(Double.pi)/180.0
//            var rotationVector = SCNVector4()
//
//            rotationVector.x = -pan_y
//            rotationVector.y = 0
//            rotationVector.z = pan_x
//            rotationVector.w = anglePan
            
            //planeNode?.rotation = rotationVector
            //planeNode?.eulerAngles.x = -.pi / 2
            planeNode?.eulerAngles.y = -pan_x
            //planeNode?.eulerAngles.y =
            //planeNode?.rotation = GLKMatrix4MakeZRotation(Float(newRotation))
        }
        if sender.state == .ended{
            lastRotation = sender.rotation
        }
    }
    @objc func pinchRecognizer(sender: UIPinchGestureRecognizer){
        let mult = sender.scale;
        let plane = planeNode?.geometry as! SCNPlane
        if((mult > 1 && plane.width < 1) || (mult < 1 && plane.width > 0.05 )){
            plane.width *= mult;
            plane.height *= mult;
        }
        sender.scale = 1;
    }
    @objc func panRecognizer(sender: UIPanGestureRecognizer) {
        
        let position = sender.location(in: sender.view!)
        let state = sender.state
        
        if (state == .failed || state == .cancelled) {
            return
        }
        
        if (state == .began) {
                latestTranslatePos = position
        } else {
            
            // Translate virtual object
            let deltaX = Float(position.x - latestTranslatePos!.x)/700
            let deltaY = Float(position.y - latestTranslatePos!.y)/700
            
            planeNode!.localTranslate(by: SCNVector3Make(deltaX, -deltaY, 0.0))
            //after rotation coordinate system changes and local transalte doesn't work as predicted
            latestTranslatePos = position
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's AR session.
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    /// - Tag: PlaceARContent
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create a SceneKit plane to visualize the plane anchor using its position and extent.
        //let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        planeNode = SCNNode()
        planeNode?.geometry = SCNPlane(width: 0.1, height: 0.1)
        // planeNode.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.0)
        planeNode?.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        // `SCNPlane` is vertically oriented in its local coordinate space, so
        // rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
        planeNode?.eulerAngles.x = -.pi / 2
        
        // Make the plane visualization semitransparent to clearly show real-world placement.
        //let material = SCNMaterial()
        //material.diffuse.contents = UIImage(named: "brick2.png")
        //material.diffuse.contents = UIColor.white
        // planeNode.opacity = 0.25
        planeNode?.geometry?.firstMaterial?.diffuse.contents = selectedImage
        //planeNode.
        currentAngle = (planeNode?.eulerAngles.z)!
        
        // Add the plane visualization to the ARKit-managed node so that it tracks
        // changes in the plane anchor as plane estimation continues.
        node.addChildNode(planeNode!)
    }
    
    /// - Tag: UpdateARContent
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
//        guard let planeAnchor = anchor as?  ARPlaneAnchor,
//            let planeNode = node.childNodes.first
//            //let plane = planeNode.geometry as? SCNPlane
//            else { return }
//
//        // Plane estimation may shift the center of a plane relative to its anchor's transform.
//        //planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
//
//        // Plane estimation may also extend planes, or remove one plane to merge its extent into another.
////                plane.width = CGFloat(planeAnchor.extent.x)
////                plane.height = CGFloat(planeAnchor.extent.z)
//    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        label.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        label.text = "Session interruption ended"
        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        label.text = "Session failed: \(error.localizedDescription)"
        resetTracking()
    }
    
    // MARK: - Private methods
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal surfaces."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""
            
        }
        
        label.text = message
        sessionView.isHidden = message.isEmpty
        //sessionInfoView.isHidden = message.isEmpty
//        if !message.isEmpty {
//            
//        }
    }
    
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}
