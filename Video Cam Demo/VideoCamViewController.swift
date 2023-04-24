//
//  VideoCamViewController.swift
//  Video Cam Demo
//
//  Created by Sorfian on 01/04/23.
//

import UIKit
import AVFoundation
import AVKit

class VideoCamViewController: UIViewController {

    @IBOutlet weak var cameraButton: UIButton!
    
    let captureSession = AVCaptureSession()
    var currentDevice: AVCaptureDevice!
    var videoFileOutput: AVCaptureMovieFileOutput!
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    @IBAction func capture(sender: AnyObject) {
        if !isRecording {
            isRecording = true
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: { () -> Void in
            self.cameraButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5) }, completion: nil)
            let outputPath = NSTemporaryDirectory() + "output.mov"
            let outputFileURL = URL(fileURLWithPath: outputPath)
            videoFileOutput?.startRecording(to: outputFileURL, recordingDelegate: self)
        } else {
            isRecording = false
            UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: { ( ) -> Void in
            self.cameraButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0) }, completion: nil)
            cameraButton.layer.removeAllAnimations()
            videoFileOutput?.stopRecording()
        }
    }
    
    private func configure(){
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
        
        currentDevice = device
        
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice) else {
            return
        }
        videoFileOutput = AVCaptureMovieFileOutput()
        
        captureSession.addInput(captureDeviceInput)
        captureSession.addOutput(videoFileOutput)
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
    
        view.bringSubviewToFront(cameraButton)
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playVideo" {
            let videoPlayerViewController = segue.destination as! AVPlayerViewController
            let videoURL = sender as! URL
            videoPlayerViewController.player = AVPlayer(url: videoURL)
        }
    }
}

extension VideoCamViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else {
            print(error ?? "")
            return
        }
        
        performSegue(withIdentifier: "playVideo", sender: outputFileURL)
    }
}
