//
//  CameraController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 29/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import AVFoundation


public protocol ICameraController {
    func didFinishWith(image: UIImage)
}



public class CameraController: UIViewController {
    
    public var captureSession: AVCaptureSession?
    public var photoOutput: AVCapturePhotoOutput?
    public var previewLayer: AVCaptureVideoPreviewLayer?
    public var imageData: UIImage?
    @IBOutlet weak var tempImage: UIImageView!
    @IBOutlet weak var verifyFace: UIImageView!
    @IBOutlet weak var verifyKTP: UIImageView!
    
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var stackButton: UIStackView!
    @IBOutlet weak var retake: UIButton!
    @IBOutlet weak var done: UIButton!
    
    public var delegate: ICameraController?
    var type: VerifikasiStep = VerifikasiStep.default
    
    private lazy var alert: UIAlertController = {
        let alert = UIAlertController()
        alert.title = nil
        alert.message = "Mohon tunggu sebentar..."
        return alert
    }()
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tempImage.isHidden = true
        stackButton.isHidden = true
        
        switch type {
        case .selfKtp:
            verifyFace.isHidden = false
            verifyKTP.isHidden = false
        default:
            verifyFace.isHidden = true
            verifyKTP.isHidden = true
        }
        
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeCamera()
        cancelButton.addTarget(self, action: #selector(handleDismiss(sender:)), for: .touchUpInside)
        captureButton.addTarget(self, action: #selector(handleTakePhoto(sender:)), for: .touchUpInside)
        retake.addTarget(self, action: #selector(handleRetake(sender:)), for: .touchUpInside)
        done.addTarget(self, action: #selector(handleDone(sender:)), for: .touchUpInside)
    }
    
    @objc private func handleDismiss(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleRetake(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleDone(sender: UIButton) {
        dismiss(animated: true) {
            if let data = self.imageData {
                self.delegate?.didFinishWith(image: data)
            }
        }
    }
    
    private func initializeCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)
            captureSession?.addInput(input)
            photoOutput = AVCapturePhotoOutput()
            if (captureSession?.canAddOutput(photoOutput!) != nil) {captureSession?.addOutput(photoOutput!)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
                previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                cameraView.layer.addSublayer(previewLayer!)
                captureSession?.startRunning()
            }
        } catch {
            print("Error: \(error)")
        }
        previewLayer?.frame = view.bounds
    }
    
    @objc private func handleTakePhoto(sender: UIButton) {
        
        self.photoOutput?.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating()
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {

    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if error == nil {
            alert.dismiss(animated: true, completion: nil)
        }
        // Make sure we get some photo sample buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
                print("Error capturing photo: \(String(describing: error))")
                return
        }
        // Convert photo same buffer to a jpeg image data by using // AVCapturePhotoOutput
        guard let imageData =
            AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
                return
        }
        
        let dataProvider = CGDataProvider(data: imageData as CFData)
        
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.absoluteColorimetric)
        
        
        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImage.Orientation.right)
        self.imageData = image
        self.tempImage.image = image
        self.tempImage.isHidden = false
        self.stackButton.isHidden = false
    }
}