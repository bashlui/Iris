//
//  CameraManager.swift
//  Iris
//
//  Created by toño on 11/02/26.
//
//  AVCaptureSession for real-time camera frames. Outputs BGRA CVPixelBuffer for Core Image.
//

import AVFoundation
import CoreVideo

final class CameraManager: NSObject, @unchecked Sendable {
    
    // MARK: - Properties
    
    // Lazy init: session and queues created on first use to keep init lightweight
    private var _captureSession: AVCaptureSession?
    private var _sessionQueue: DispatchQueue?
    private var _outputQueue: DispatchQueue?
    private var _videoOutput: AVCaptureVideoDataOutput?
    private var isConfigured = false
    
    private var captureSession: AVCaptureSession {
        if _captureSession == nil {
            _captureSession = AVCaptureSession()
        }
        return _captureSession!
    }
    
    private var sessionQueue: DispatchQueue {
        if _sessionQueue == nil {
            _sessionQueue = DispatchQueue(label: "iris.camera.session")
        }
        return _sessionQueue!
    }
    
    private var outputQueue: DispatchQueue {
        if _outputQueue == nil {
            _outputQueue = DispatchQueue(label: "iris.camera.output")
        }
        return _outputQueue!
    }
    
    private var videoOutput: AVCaptureVideoDataOutput {
        if _videoOutput == nil {
            _videoOutput = AVCaptureVideoDataOutput()
        }
        return _videoOutput!
    }
    
    // Thread-safe access: camera callbacks run on output queue, UI reads on main
    private let callbackLock = NSLock()
    private var _onFrameCaptured: ((CVPixelBuffer) -> Void)?
    private var _onFrameForProcessing: ((CVPixelBuffer) -> Void)?

    var onFrameCaptured: ((CVPixelBuffer) -> Void)? {
        get { callbackLock.withLock { _onFrameCaptured } }
        set { callbackLock.withLock { _onFrameCaptured = newValue } }
    }
    var onFrameForProcessing: ((CVPixelBuffer) -> Void)? {
        get { callbackLock.withLock { _onFrameForProcessing } }
        set { callbackLock.withLock { _onFrameForProcessing = newValue } }
    }
    
    var isCameraAvailable: Bool {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil
            || AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) != nil
    }
    
    // MARK: - Permissions
    
    func checkPermissions() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }
    
    // MARK: - Session Lifecycle
    
    // Start on background queue so UI stays responsive
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            self?._captureSession?.stopRunning()
        }
    }
    
    // MARK: - Configuration
    
    private func configureSession() {
        guard !isConfigured else { return }
        guard !captureSession.isRunning else { return }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        // Prefer back camera, fallback to front (e.g. Simulator)
        let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        guard let camera,
              let input = try? AVCaptureDeviceInput(device: camera) else {
            captureSession.commitConfiguration()
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        // BGRA format required for Core Image and Vision
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: outputQueue)
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.commitConfiguration()
        isConfigured = true
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

// Receives each camera frame. Passes CVPixelBuffer to subscribers (e.g. FrameRenderer)
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        onFrameCaptured?(pixelBuffer)
        onFrameForProcessing?(pixelBuffer)
    }
}
