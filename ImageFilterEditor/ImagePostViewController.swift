//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by Sean Acres on 7/8/20.
//  Copyright © 2020 Sean Acres. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class ImagePostViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gaussBlurSlider: UISlider!
    @IBOutlet weak var tiledFilterSwitch: UISwitch!
    @IBOutlet weak var bloomFilterSwitch: UISwitch!
    @IBOutlet weak var gloomFilterSwitch: UISwitch!
    @IBOutlet weak var pixellateFilterSwitch: UISwitch!
    
    var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else {
                scaledImage = nil
                return
            }
            
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            
            guard let scaledUIImage = originalImage.imageByScaling(toSize: scaledSize) else {
                scaledImage = nil
                return
            }
            
            scaledImage = CIImage(image: scaledUIImage)
        }
    }
    
    var scaledImage: CIImage? {
        didSet {
            updateImage()
        }
    }
    
    var outputImage: CIImage?
    
    private let context = CIContext()
    private let gaussianBlurFilter = CIFilter.gaussianBlur()
    private let tiledFilter = CIFilter.eightfoldReflectedTile()
    private let bloomFilter = CIFilter.bloom()
    private let gloomFilter = CIFilter.gloom()
    private let pixellateFilter = CIFilter.pixellate()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        originalImage = imageView.image
    }
    
    private func image(byFiltering inputImage: CIImage) -> UIImage? {
        
        gaussianBlurFilter.inputImage = inputImage
        gaussianBlurFilter.radius = gaussBlurSlider.value
        
        outputImage = gaussianBlurFilter.outputImage
            
        if tiledFilterSwitch.isOn {
            tiledFilter.inputImage = outputImage
            outputImage = tiledFilter.outputImage
        }
        
        if bloomFilterSwitch.isOn {
            bloomFilter.inputImage = outputImage
            bloomFilter.radius = 30
            outputImage = bloomFilter.outputImage
        }
        
        if gloomFilterSwitch.isOn {
            gloomFilter.inputImage = outputImage
            gloomFilter.intensity = 0.9
            outputImage = gloomFilter.outputImage
        }
        
        if pixellateFilterSwitch.isOn {
            pixellateFilter.inputImage = outputImage
            pixellateFilter.scale = 24
            outputImage = pixellateFilter.outputImage
        }
        
        guard let outputImage = outputImage else { return nil }
        guard let renderedCGImage = context.createCGImage(outputImage, from: inputImage.extent) else { return nil }
        
        return UIImage(cgImage: renderedCGImage)
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Photo Library is not available")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    

    @IBAction func choosePhotoPressed(_ sender: Any) {
        presentImagePickerController()
    }
    
    @IBAction func gaussBlurChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func tiledSwitchChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func bloomSwitchChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func gloomSwitchChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func pixellateSwitchChanged(_ sender: Any) {
        updateImage()
    }
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            originalImage = image
        } else if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
