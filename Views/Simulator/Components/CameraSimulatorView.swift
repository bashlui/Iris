//
//  CameraSimulatorView.swift
//  Iris
//
//  Created by toño on 11/02/26.
//
//  Split-screen camera: left clear, right blurred by condition (myopia, hyperopia, astigmatism).
//

import SwiftUI
import CoreImage
import CoreVideo

struct CameraSimulatorView: View {
    @Binding var simulationState: SimulationState
    var cameraManager: CameraManager

    var body: some View {
        CameraSimulatorRepresentable(
            simulationState: simulationState,
            cameraManager: cameraManager
        )
    }
}

// FrameRenderer: runs on camera queue, applies Core Image blur per condition.
// Uses NSLock because it's called from camera callback (non-main) and updateUIView (main)
final class FrameRenderer: @unchecked Sendable {
    private let lock = NSLock()
    private var splitPosition: CGFloat = 0.5
    private var isSplitActive: Bool = true
    private var severity: CGFloat = 3
    private var condition: EyeCondition = .myopia
    private var astigmatismAxis: CGFloat = 45

    private let ciContext = CIContext()

    func updateState(
        splitPosition: CGFloat,
        isSplitActive: Bool,
        severity: CGFloat,
        condition: EyeCondition,
        astigmatismAxis: CGFloat
    ) {
        lock.withLock {
            self.splitPosition = splitPosition
            self.isSplitActive = isSplitActive
            self.severity = severity
            self.condition = condition
            self.astigmatismAxis = astigmatismAxis
        }
    }

    // Called for each camera frame. Returns composited clear + blurred image
    func processFrame(_ pixelBuffer: CVPixelBuffer) -> CGImage? {
        let (split, isSplit, sev, cond, axis) = lock.withLock {
            (splitPosition, isSplitActive, severity, condition, astigmatismAxis)
        }
        let splitPos = isSplit ? split : 1.0
        let blurRadius = cond == .normal ? CGFloat(0) : (sev / 10.0) * 25.0
        return composeFrame(
            pixelBuffer: pixelBuffer,
            splitPosition: splitPos,
            blurRadius: blurRadius,
            condition: cond,
            astigmatismAxis: axis
        )
    }

    // Build final image: apply condition-specific blur, then split and composite
    private func composeFrame(
        pixelBuffer: CVPixelBuffer,
        splitPosition: CGFloat,
        blurRadius: CGFloat,
        condition: EyeCondition,
        astigmatismAxis: CGFloat
    ) -> CGImage? {
        var source = CIImage(cvPixelBuffer: pixelBuffer)
        source = source.oriented(.up)

        var bounds = source.extent
        if !bounds.width.isFinite || !bounds.height.isFinite || bounds.width <= 0 || bounds.height <= 0 {
            return nil
        }
        let clearImage = source

        if blurRadius <= 0 {
            return ciContext.createCGImage(clearImage, from: bounds)
        }

        var blurred: CIImage
        if condition == .astigmatism {
            // CIMotionBlur simulates directional streaks (astigmatism)
            let angle = (astigmatismAxis - 90) * .pi / 180
            if let filter = CIFilter(name: "CIMotionBlur") {
                filter.setValue(source, forKey: kCIInputImageKey)
                filter.setValue(blurRadius * 2, forKey: kCIInputRadiusKey)
                filter.setValue(Float(angle), forKey: "inputAngle")
                blurred = filter.outputImage ?? source
            } else {
                blurred = source
            }
        } else if condition == .hyperopia {
            // Hyperopia: close objects blurry. Gaussian + vignette for near-focus strain
            if let gaussianFilter = CIFilter(name: "CIGaussianBlur") {
                gaussianFilter.setValue(source, forKey: kCIInputImageKey)
                gaussianFilter.setValue(blurRadius * 1.2, forKey: kCIInputRadiusKey)
                blurred = gaussianFilter.outputImage ?? source
                
                if let vignetteFilter = CIFilter(name: "CIVignette") {
                    vignetteFilter.setValue(blurred, forKey: kCIInputImageKey)
                    vignetteFilter.setValue(blurRadius * 0.15, forKey: "inputIntensity")
                    vignetteFilter.setValue(blurRadius * 0.3, forKey: "inputRadius")
                    blurred = vignetteFilter.outputImage ?? blurred
                }
            } else {
                blurred = source
            }
        } else {
            // Myopia: uniform Gaussian blur (distant objects blur)
            if let filter = CIFilter(name: "CIGaussianBlur") {
                filter.setValue(source, forKey: kCIInputImageKey)
                filter.setValue(blurRadius, forKey: kCIInputRadiusKey)
                blurred = filter.outputImage ?? source
            } else {
                blurred = source
            }
        }
        
        // Clamp blurred image to avoid edge artifacts from blur extending beyond bounds
        blurred = blurred.cropped(to: bounds)

        if splitPosition >= 1.0 { return ciContext.createCGImage(clearImage, from: bounds) }
        if splitPosition <= 0   { return ciContext.createCGImage(blurred, from: bounds) }

        // Crop and composite: left = clear, right = blurred
        let splitX = bounds.minX + bounds.width * splitPosition
        let clearCrop   = clearImage.cropped(to: CGRect(x: bounds.minX, y: bounds.minY, width: splitX - bounds.minX, height: bounds.height))
        let blurredCrop = blurred.cropped(to: CGRect(x: splitX, y: bounds.minY, width: bounds.maxX - splitX, height: bounds.height))
        let combined = blurredCrop.composited(over: clearCrop)
        return ciContext.createCGImage(combined, from: bounds)
    }
}

// Bridges SwiftUI to UIKit. Coordinator holds renderer and subscribes to camera frames
private struct CameraSimulatorRepresentable: UIViewRepresentable {
    let simulationState: SimulationState
    let cameraManager: CameraManager

    func makeCoordinator() -> Coordinator {
        Coordinator(cameraManager: cameraManager)
    }

    func makeUIView(context: Context) -> CameraSimulatorUIView {
        let view = CameraSimulatorUIView(renderer: context.coordinator.renderer)
        view.backgroundColor = .black
        context.coordinator.view = view
        context.coordinator.setupSubscription()
        return view
    }

    func updateUIView(_ uiView: CameraSimulatorUIView, context: Context) {
        context.coordinator.view = uiView
        let state = simulationState
        context.coordinator.renderer.updateState(
            splitPosition: CGFloat(state.splitPosition),
            isSplitActive: state.isSplitViewActive,
            severity: CGFloat(state.severity),
            condition: state.activeCondition,
            astigmatismAxis: CGFloat(state.astigmatismAxis)
        )
        uiView.updateDivider(
            splitPosition: CGFloat(state.splitPosition),
            isSplitActive: state.isSplitViewActive
        )
    }

    static func dismantleUIView(_ uiView: CameraSimulatorUIView, coordinator: Coordinator) {
        coordinator.cancelSubscription()
    }
}

// Holds renderer and connects camera callback to UIView display
final class Coordinator: @unchecked Sendable {
    weak var view: CameraSimulatorUIView?
    let renderer: FrameRenderer
    let cameraManager: CameraManager

    init(cameraManager: CameraManager) {
        self.cameraManager = cameraManager
        self.renderer = FrameRenderer()
    }

    func setupSubscription() {
        let renderer = self.renderer
        // Each frame: renderer blurs, then we set CGImage on main queue
        cameraManager.onFrameCaptured = { [weak self] buffer in
            guard let cgImage = renderer.processFrame(buffer) else { return }
            DispatchQueue.main.async { [weak self] in
                self?.view?.setDisplayImage(cgImage)
            }
        }
    }

    func cancelSubscription() {
        cameraManager.onFrameCaptured = nil
    }
}

// CALayer displays the composited image. Divider layer shows split line
final class CameraSimulatorUIView: UIView {
    private let imageLayer = CALayer()
    private let dividerLayer = CALayer()
    private let renderer: FrameRenderer

    init(renderer: FrameRenderer) {
        self.renderer = renderer
        super.init(frame: .zero)
        imageLayer.contentsGravity = .resizeAspectFill
        layer.addSublayer(imageLayer)
        dividerLayer.backgroundColor = UIColor.white.cgColor
        layer.addSublayer(dividerLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageLayer.frame = bounds
    }

    func updateDivider(splitPosition: CGFloat, isSplitActive: Bool) {
        if isSplitActive {
            dividerLayer.isHidden = false
            let x = bounds.width * splitPosition
            dividerLayer.frame = CGRect(x: x - 1, y: 0, width: 2, height: bounds.height)
        } else {
            dividerLayer.isHidden = true
        }
    }

    func setDisplayImage(_ cgImage: CGImage) {
        imageLayer.contents = cgImage
    }
}
