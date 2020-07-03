//
//  ContentView.swift
//  FaceDetectionDemo-PracticalAIWithSwift
//
//  Created by Eric Golovin on 6/29/20.
//

import SwiftUI
import UIKit
import Vision

struct ContentView: View {
    @State private var imagePickerOpen: Bool = false
    @State private var cameraOpen: Bool = false
    @State private var image: UIImage? = nil
    @State private var faces: [VNFaceObservation]? = nil
    
    private var faceCount: Int { return faces?.count ?? 0 }
    private let placeholderImage = UIImage(named: "placeholder")!
    private var cameraEnabled: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    private var detectionEnabled: Bool { image != nil && faces == nil }
    
    var body: some View {
        
        if imagePickerOpen { return imagePickerView() }
        if cameraOpen { return cameraView() }
        return mainView()
    }
    
    private func getFaces() {
        print("Getting faces...")
        self.faces = []
        self.image?.detectFaces(completion: { result in
            self.faces = result
        })
    }
    
    private func controlReturned(image: UIImage?) {
        print("Image return \(image == nil ? "failure" : "success")...")
        self.image = image?.fixOrientation()
        self.faces = nil
    }
    
    private func summonImagePicker() {
        print("Summoning ImagePicker...")
        imagePickerOpen = true
    }
    
    private func summonCamera() {
        print("Summoning Camera...")
        cameraOpen = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
    private func mainView() -> AnyView {
        return AnyView(NavigationView {
            MainView(image: image ?? placeholderImage, text: "\(faceCount) face\(faceCount == 1 ? "" : "s")", button: {
                TwoStateButton(text: "Detect Faces", disabled: !detectionEnabled, action: getFaces)
            })
            .padding()
            .navigationBarTitle(Text("FaceDetectionDemo"), displayMode: .large)
            .navigationBarItems(
                leading: Button(action: summonImagePicker, label: { Text("Select") }),
                trailing: Button(action: summonCamera, label: { Image(systemName: "camera") })
                    .disabled(!cameraEnabled)
            )
        })
    }
    
    private func imagePickerView() -> AnyView {
        return  AnyView(ImagePicker { result in
            self.controlReturned(image: result)
            self.imagePickerOpen = false
        })
    }
    
    private func cameraView() -> AnyView {
        return  AnyView(ImagePicker(camera: true) { result in
            
            self.controlReturned(image: result)
            self.cameraOpen = false
        })
    }
}
