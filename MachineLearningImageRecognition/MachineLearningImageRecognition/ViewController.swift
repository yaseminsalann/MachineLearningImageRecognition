//
//  ViewController.swift
//  MachineLearningImageRecognition
//
//  Created by Yasemin salan on 22.02.2025.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    var choosenImage = CIImage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func changeClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true,completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!) {
            choosenImage = ciImage
           
        }
        recognizeImage(image: choosenImage)
    }
    func recognizeImage(image:CIImage) {
        //1)Request
        //2)Handler
        //MobileNetV2() indirdiğimiz model
        resultLabel.text = "Finding..."
        if let model = try? VNCoreMLModel(for: MobileNetV2().model){
            let request = VNCoreMLRequest(model: model) { (vnrequest, error) in
                guard let results = vnrequest.results as? [VNClassificationObservation] else {
                    return
                }
                if let firstResult = results.first {
                    DispatchQueue.main.async {
                        let confidenceLevel = firstResult.confidence * 100
                        let rounded = Int(confidenceLevel * 100) / 100
                        
                        self.resultLabel.text = "% \(rounded) it's \(firstResult.identifier) "
                    }
                    
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async{
                do{
                    try? handler.perform([request])
                }catch let error{
                    print("Error: \(error)")
                }
                
            }
           
            
        }
        
       
    }
    
}

