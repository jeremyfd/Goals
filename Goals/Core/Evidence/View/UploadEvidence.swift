//
//  UploadEvidence.swift
//  Goals
//  Created by Work on 29/12/2023.
//

//import SwiftUI
//import AVFoundation
//import Photos
//
//struct UploadEvidence: View {
//    @State private var image: UIImage?
//    @State private var isCameraViewPresented = false
//    @State private var cameraView: CameraView?
//    @State private var isPreviewingCapturedImage = false
//    
//    var body: some View {
//        VStack {
//            if let image = image {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//            }
//            
//            if isPreviewingCapturedImage {
//                VStack {
//                    Image(uiImage: image!)
//                        .resizable()
//                        .scaledToFit()
//                    
//                    HStack {
//                        Button("Use") {
//                            isCameraViewPresented = false
//                            isPreviewingCapturedImage = false
//                        }
//                        
//                        Button("Retake") {
//                            isPreviewingCapturedImage = false
//                        }
//                    }
//                }
//            }
//            
//            Button("Open Camera") {
//                if cameraView == nil {
//                    print("DEBUG: Initializing CameraView")
//                    cameraView = CameraView(image: $image, isPresented: $isCameraViewPresented, isPreviewingCapturedImage: $isPreviewingCapturedImage)
//                }
//                print("DEBUG: Presenting camera view")
//                isCameraViewPresented = true
//            }
//        }
//        .fullScreenCover(isPresented: $isCameraViewPresented) {
//            
//            ZStack {
//                cameraView
//                
//                VStack {
//                    Spacer()
//                    HStack {
//                        Spacer()
//                        
//                        Button(action: {
//                            cameraView?.capturePhoto()
//                        }) {
//                            Image(systemName: "camera.circle")
//                                .font(.system(size: 60))
//                                .foregroundColor(.white)
//                        }
//                        Spacer()
//                    }
//                }
//                .background(Color.clear)
//            }
//        }
//    }
//}
//
//struct CameraView: UIViewRepresentable {
//    @Binding var image: UIImage?
//    @Binding var isPresented: Bool
//    @Binding var isPreviewingCapturedImage: Bool
//    let session = AVCaptureSession()
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self, isPreviewingCapturedImage: isPreviewingCapturedImage)
//    }
//
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView(frame: UIScreen.main.bounds) // Ensuring the view takes the full screen
//        setupSession(view: view, context: context)
//        return view
//    }
//    
//    func capturePhoto() {
//        guard let coordinator = self.makeCoordinator(), // Create the coordinator
//              let photoOutput = coordinator.photoOutput else { // Access photoOutput from the coordinator
//            print("DEBUG: No photo output found")
//            return
//        }
//        let settings = AVCapturePhotoSettings()
//        photoOutput.capturePhoto(with: settings, delegate: coordinator) // Use the coordinator as the delegate
//        print("DEBUG: capturePhoto called")
//    }
//
//    
//    private func setupSession(view: UIView, context: Context) {
//        session.beginConfiguration()
//        
//        // Adding video input
//        guard let videoDevice = AVCaptureDevice.default(for: .video),
//              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
//              session.canAddInput(videoInput) else {
//            print("Error: Could not add video input.")
//            return
//        }
//        session.addInput(videoInput)
//        
//        // Adding photo output
//        let photoOutput = AVCapturePhotoOutput()
//        guard session.canAddOutput(photoOutput) else {
//            print("Error: Could not add photo output.")
//            return
//        }
//        session.addOutput(photoOutput)
//        context.coordinator.photoOutput = photoOutput
//        
//        session.commitConfiguration()
//        
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.frame = view.bounds
//        previewLayer.videoGravity = .resizeAspectFill
//        view.layer.addSublayer(previewLayer)
//        
//        session.startRunning()
//    }
//    
//    func updateUIView(_ uiView: UIView, context: Context) {
//         guard let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer else {
//             return
//         }
//         layer.frame = uiView.bounds
//     }
//    
//    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
//        var parent: CameraView
//        var photoOutput: AVCapturePhotoOutput?
//        var isPreviewingCapturedImage: Binding<Bool>
//
//        init(parent: CameraView, isPreviewingCapturedImage: Binding<Bool>) {
//            self.parent = parent
//            self.isPreviewingCapturedImage = isPreviewingCapturedImage
//        }
//        
//        func capturePhoto() {
//            guard let photoOutput = self.photoOutput else {
//                print("DEBUG: No photo output found")
//                return
//            }
//            let settings = AVCapturePhotoSettings()
//            photoOutput.capturePhoto(with: settings, delegate: self)
//            print("DEBUG: capturePhoto called")
//        }
//        
//        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//            if let error = error {
//                print("DEBUG: Error capturing photo: \(error.localizedDescription)")
//                return
//            }
//            print("DEBUG: Photo captured, processing")
//            
//            if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
//                DispatchQueue.main.async {
//                    self.parent.image = image  // Update the image state
//                    self.parent.isPresented = false  // Optionally, close the camera view
//                    self.parent.isPreviewingCapturedImage = true
//                }
//            }
//        }
//    }
//}
//

//
//#Preview {
//    UploadEvidence()
//}
