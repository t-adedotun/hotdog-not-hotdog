//
//  ViewController.swift
//  hotdog-not-hotdog
//
//  Created by Taiwo on 15/02/2018.
//  Copyright © 2018 Taiwo. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!

    let imagePicker = UIImagePickerController()

    var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage

            guard let ciImage = CIImage(image: pickedImage) else {
                fatalError("Failed to convert image to CIImage")
            }

            detect(image: ciImage)
        }

        imagePicker.dismiss(animated: true, completion: nil)
    }

    func playSound(name: String) {

        guard let sound = NSDataAsset(name: name) else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(data: sound.data, fileTypeHint: "m4a")

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }

    func detect(image: CIImage) {

        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Error laoding CoreML model.")
        }

        let request = VNCoreMLRequest(model: model) { (request, error) in

            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Failed to process image")
            }

            if let firstResult = results.first {

                if firstResult.identifier.contains("hotdog") {

                    self.navigationController?.navigationBar.barTintColor = UIColor(red:0.02, green:0.5, blue:0.09, alpha:1.0)
                    self.navigationItem.title = "Hotdog!"
                    self.playSound(name: "hotdog")
                } else {

                    self.navigationController?.navigationBar.barTintColor = UIColor(red:0.5, green:0.00, blue:0.00, alpha:1.0)
                    self.navigationItem.title = "Not Hotdog!"
                    self.playSound(name: "not-hotdog")
                }
            }
        }

        let handler = VNImageRequestHandler(ciImage: image)

        do {
            try handler.perform([request])
        } catch {
            print ("An error occurred performing the image analysis request")
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {

        present(imagePicker, animated: true, completion: nil)
    }
}

