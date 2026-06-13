import Foundation
import SwiftUI

// MARK: - Helper Function to Save Image from Local directory
func saveImageToCache(image: UIImage, fileName: String) {
    if let data = image.jpegData(compressionQuality: 0.8) {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)
        
        if let libraryDirectory = urls.first {
            let fileURL = libraryDirectory.appendingPathComponent(fileName)
            
            do {
                try data.write(to: fileURL)
                print("Image saved successfully!")
            } catch {
                print("Error saving image: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Helper Function to Fetch Image from Local directory
func loadCachedImage(fileName: String) -> UIImage? {
    let fileManager = FileManager.default
    let urls = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)
    
    if let libraryDirectory = urls.first {
        let fileURL = libraryDirectory.appendingPathComponent(fileName)
        
        if let imageData = try? Data(contentsOf: fileURL) {
            if let img =  UIImage(data: imageData) {
                return img
            }
        }
    }
    return nil
}
