import UIKit

public extension UIImage {
    public convenience init(view: UIView) {
        // draw view in context
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        // get image, return
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
    
    public func resize(newSize: CGSize) -> UIImage {
        // create context - make sure we are on a 1.0 scale
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0);
        
        // draw with new size, get image, and return
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return newImage!
    }
    
    public func grayScalePixelBuffer() -> CVPixelBuffer? {
        // create gray scale pixel buffer
        var optionalPixelBuffer: CVPixelBuffer?
        guard CVPixelBufferCreate(kCFAllocatorDefault, 28, 28, kCVPixelFormatType_OneComponent8, nil, &optionalPixelBuffer) == kCVReturnSuccess else {
            return nil
        }
        
        guard let pixelBuffer = optionalPixelBuffer else {
            return nil
        }
        
        // draw image in pixel buffer
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: baseAddress, width: 28, height: 28, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: colorSpace, bitmapInfo: 0)
        context!.draw(cgImage!, in: CGRect(x: 0, y: 0, width: 28, height: 28))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        
        return pixelBuffer
    }
}
