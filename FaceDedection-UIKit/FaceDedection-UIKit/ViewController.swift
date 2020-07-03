//
//  ViewController.swift
//  FaceDetection-UIKit
//
//  Created by Eric Golovin on 7/3/20.
//

import UIKit
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var libraryBarButton: UIBarButtonItem!
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var numberOfFacesLabel: UILabel!
    @IBOutlet weak var detectFacesButton: UIButton!
    
    var faces: [VNFaceObservation]?
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        detectFacesButton.isEnabled = false
        
    }

    @IBAction func detectFacesTapped(_ sender: UIButton) {
        self.photoImageView.image?.detectFaces(completion: { faces in
            self.faces = faces
            
            let faceCount = self.faces?.count
            
            DispatchQueue.main.async {
                self.numberOfFacesLabel.text = "\(faceCount ?? 0) face\(faceCount == 1 ? "" : "s")"
            }
        })
    }
    
    @IBAction func libraryBarTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.photoImageView.image = image
        } else {
            fatalError("Error: Cannot pick an image")
        }
        
        detectFacesButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
}

extension UIImage {
    func detectFaces(completion: @escaping ([VNFaceObservation]?) -> ()) {
        guard let image = self.cgImage else { return completion(nil) }
        let request = VNDetectFaceRectanglesRequest()
        
        DispatchQueue.global().async {
            let handler = VNImageRequestHandler(cgImage: image, orientation: self.cgImageOrientation)
            
            try? handler.perform([request])
            guard let observations = request.results as? [VNFaceObservation] else {
                return completion(nil)
            }
            
            completion(observations)
        }
    }
}

extension UIImage {
    func fixOrientation() -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        self.draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    var cgImageOrientation: CGImagePropertyOrientation {
        switch self.imageOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default:
            fatalError("Error: No case for imageOrientation")
        }
    }
}
