//
//  CustomCameraView.swift
//  SwiftUIPlayground
//
//  Created by Eojin Choi on 2023/07/24.
//

import SwiftUI
import AVFoundation

struct CustomCameraView: View {

    @StateObject var camera = CameraModel()

    var body: some View {
        ZStack {
            
            // MARK: preview for camera
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
            
            VStack {
                
                if camera.isTaken {
                    
                    HStack {
                        
                        Spacer()
                        
                        Button(action: camera.reTake, label: {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .foregroundColor(Color.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        })
                        .padding(.trailing, 10)
                    }
                }
                
                Spacer()
                
                HStack {
                    
                    // if taken showing button and again take picture...
                    
                    if camera.isTaken {
                        
                        Button(action: {
                            if !camera.isSaved {
                                camera.savePic()
                            }
                        }, label: {
                            Text(camera.isSaved ? "Saved" : "Save")
                                .foregroundColor(Color.black)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .clipShape(Capsule())
                        })
                        .padding(.leading)
                        
                        Spacer()
                        
                    } else {
                        
                        Button(action: camera.takePic, label: {
                            
                            ZStack {
                                
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 35, height: 35)
                                
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 45, height: 45)
                            }
                        })
                    }
                }
                .frame(height: 75)
            }
        }
        .onAppear(perform: {
            camera.Check()
        })
    }
}

struct CustomCameraView_Previews: PreviewProvider {
    static var previews: some View {
        CustomCameraView()
    }
}

// MARK: - Camera Model

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    
    @Published var isTaken: Bool = false
    
    @Published var session = AVCaptureSession()
    
    @Published var alert: Bool = false
    
    @Published var output = AVCapturePhotoOutput()
    
    @Published var preview = AVCaptureVideoPreviewLayer()
    
    @Published var isSaved = false
    @Published var picData = Data(count: 0)
    
    func Check() {
        
        // first check cameras got permission
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            return
            
            // setting up session
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: {(status) in
                if status {
                    self.setUp()
                }
            })
        case .denied:
            self.alert.toggle()
            return
            
        default:
            break
        }
    }
    
    func setUp() {
        // setting up camera...
        
        do {
            // setting configurations...
            
            self.session.beginConfiguration()
            
            let device = AVCaptureDevice.default(for: .video)
            
            let input = try AVCaptureDeviceInput(device: device!)
            
            // checking and adding to session...
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            
            /// 가이딩 하이라이트 띄워주는 부분
            
            // same for output...
            
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func takePic() {
        
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            self.session.stopRunning()
            
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
            }
        }
    }
    
    func reTake() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
                self.isSaved = false
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if error != nil {
            return
        }
        
        print("pic taken...")
        
        guard let imageData = photo.fileDataRepresentation() else {return}
        
        self.picData = imageData
    }
    
    func savePic() {
        let image = UIImage(data: self.picData)!
        
        // saving image...
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.isSaved = true
        print("saved successfully...")
    }
}

struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        camera.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        //
    }
}
