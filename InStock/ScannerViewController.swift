//
//  ScannerViewController.swift
//  InStock
//
//  Created by Abdullah Atkaev on 22.02.2023.
//

import AVFoundation
import UIKit
import SwiftUI

protocol BarcodeScannerViewControllerDelegate: AnyObject {
    func barcodeScannerViewControllerDidScan(_ viewController: BarcodeScannerViewController, result: String)
}

class BarcodeScannerViewController: UIViewController {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var delegate: BarcodeScannerViewControllerDelegate?
    var lastScannedDate: Date = Date(timeIntervalSince1970: 1)
    var scanningRect: CGRect = CGRect(x: 0, y: 0, width: 150, height: 150) {
        didSet {
            updateScanningRectLayer()
        }
    }
    private var scanningRectLayer: CAShapeLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)

            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)

            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [.ean13, .ean8, .upce]

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer?.videoGravity = .resizeAspectFill
            previewLayer?.frame = view.layer.bounds //CGRect(x: 0, y: 0, width: view.layer.bounds.width, height: 200)
            view.layer.addSublayer(previewLayer!)

            // Add scanning area layer to preview layer
            let scanningRect = CGRect(x: 0.1, y: 0.3, width: 0.8, height: 0.2)
            let maskLayer = CAShapeLayer()
            let path = UIBezierPath(rect: previewLayer!.frame)
            let scanningAreaPath = UIBezierPath(rect: CGRect(x: previewLayer!.bounds.width * scanningRect.origin.x, y: previewLayer!.bounds.height * scanningRect.origin.y, width: previewLayer!.bounds.width * scanningRect.width, height: previewLayer!.bounds.height * scanningRect.height))
            path.append(scanningAreaPath)
            maskLayer.path = path.cgPath
            maskLayer.fillRule = .evenOdd
            maskLayer.fillColor = UIColor.black.withAlphaComponent(0.5).cgColor
            previewLayer?.addSublayer(maskLayer)

            DispatchQueue.global(qos: .background).async {
                self.captureSession?.startRunning()
            }
            try captureDevice.lockForConfiguration()
            if captureDevice.isFocusModeSupported(.continuousAutoFocus) {
                captureDevice.focusMode = .continuousAutoFocus
            }
            captureDevice.unlockForConfiguration()
        } catch {
            print(error)
            return
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            DispatchQueue.global(qos: .background).async {
                self.captureSession?.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession?.stopRunning()
        }
    }

    private func updateScanningRectLayer() {
        guard let previewLayer = previewLayer else { return }
        let path = UIBezierPath(rect: scanningRect)
        path.append(UIBezierPath(rect: previewLayer.bounds))
        scanningRectLayer?.path = path.cgPath
        scanningRectLayer?.fillRule = .evenOdd
    }
}

extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            return
        }

        if let metadataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
            if let barcodeValue = metadataObject.stringValue {
                if Date().timeIntervalSince(lastScannedDate) >= 2 {
                    delegate?.barcodeScannerViewControllerDidScan(self, result: barcodeValue)
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)

                    lastScannedDate = Date()
                }

            }
        }
    }
}


struct BarcodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedBarcode: String

    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(scannedBarcode: $scannedBarcode)
    }

    class Coordinator: NSObject, BarcodeScannerViewControllerDelegate {
        @Binding var scannedBarcode: String

        init(scannedBarcode: Binding<String>) {
            _scannedBarcode = scannedBarcode
        }

        func barcodeScannerViewControllerDidScan(_ viewController: BarcodeScannerViewController, result: String) {
            scannedBarcode = result
        }
    }
}

