//
//  VideoSession.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import Foundation
import AVFoundation
import Combine

struct VideoSessionError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    var errorDescription: String? {
        return description
    }
}

final class VideoSession {
    private(set) var captureSession: AVCaptureSession!
    private(set) var previewLayer: AVCaptureVideoPreviewLayer?
    private let codesPublisher: CodesPublisher
    private var metadataObjectsDelegate: MetadataObjectsDelegate!
    let queue = DispatchQueue(label: "codes", qos: .userInteractive)

    init?(codesPublisher: CodesPublisher) {
        #if targetEnvironment(simulator)
        return nil
        #else

        self.codesPublisher = codesPublisher

        do {

            captureSession = AVCaptureSession()

            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                throw VideoSessionError("Could not open video capture device.")
            }

            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            guard captureSession.canAddInput(videoInput) else {
                throw VideoSessionError("Could not add video input device.")
            }
            captureSession.addInput(videoInput)

            metadataObjectsDelegate = MetadataObjectsDelegate(codesPublisher: codesPublisher)

            let metadataOutput = AVCaptureMetadataOutput()
            guard captureSession.canAddOutput(metadataOutput) else {
                throw VideoSessionError("Could not add metadata output.")
            }
            captureSession.addOutput(metadataOutput)

            metadataOutput.metadataObjectTypes = [.qr]
            metadataOutput.setMetadataObjectsDelegate(metadataObjectsDelegate, queue: queue)

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer!.videoGravity = .resizeAspectFill
        } catch {
            print("🛑 \(error)")
            codesPublisher.send(completion: .failure(error))
        }
        #endif
    }

    func startRunning() {
        guard let captureSession = captureSession else { return }
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }

    func stopRunning() {
        guard let captureSession = captureSession else { return }
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    var isRunning: Bool {
        captureSession?.isRunning ?? false
    }

    @objc
    class MetadataObjectsDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let codesPublisher: CodesPublisher
        var lastFound: Set<String> = []

        init(codesPublisher: CodesPublisher) {
            self.codesPublisher = codesPublisher
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            let codes = Set(metadataObjects.compactMap {
                ($0 as? AVMetadataMachineReadableCodeObject)?.stringValue
            })
            if !codes.isEmpty, codes != lastFound {
                lastFound = codes
                codesPublisher.send(codes)
            }
        }
    }
}
