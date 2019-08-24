//
//  ViewController.swift
//  SafetyOnSite
//
//  Created by M'haimdat omar on 17-08-2019.
//  Copyright © 2019 M'haimdat omar. All rights reserved.
//

import UIKit
import Vision
import AVKit

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let identifierLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont(name: "Avenir", size: 22)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCamera()
        setupLabel()
    }
    
    fileprivate func setupCamera() {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .hd1920x1080
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    fileprivate func setupLabel() {
        view.addSubview(identifierLabel)
        identifierLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        identifierLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        identifierLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        identifierLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model = try? VNCoreMLModel(for: SafetyOnSite_turicreate_1().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            guard let results = finishedReq.results else { return }
            DispatchQueue.main.async(execute: {
                // perform all the UI updates on the main queue
                for case let foundObject as VNRecognizedObjectObservation in results {
                    let bestLabel = foundObject.labels.first!
                    let objectBounds = foundObject.boundingBox
                    print(bestLabel)
                    print(objectBounds)
                    DispatchQueue.main.async {
                        if bestLabel.identifier == "no_helmet_no_jacket" || bestLabel.identifier == "helmet_no_jacket" || bestLabel.identifier == "no_helmet_jacket" {
                            self.identifierLabel.text = "\(bestLabel.identifier) \(bestLabel.confidence * 100)"
                            self.identifierLabel.backgroundColor = .red
                        } else if bestLabel.identifier == "helmet_jacket" {
                            self.identifierLabel.text = "\(bestLabel.identifier) \(bestLabel.confidence * 100)"
                            self.identifierLabel.backgroundColor = .green
                        } else {
                            self.identifierLabel.text = ""
                            self.identifierLabel.backgroundColor = .white
                        }

                    }

                    print(bestLabel.identifier, bestLabel.confidence, objectBounds)
                }
            })
        }
        request.imageCropAndScaleOption = .scaleFill
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
}
