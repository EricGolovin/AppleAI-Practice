//
//  Faces.swift
//  FaceDetectionDemo-PracticalAIWithSwift
//
//  Created by Eric Golovin on 6/29/20.
//

import UIKit
import Vision

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
