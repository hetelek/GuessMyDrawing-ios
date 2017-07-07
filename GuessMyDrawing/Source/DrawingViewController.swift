import UIKit
import CoreGraphics
import CoreML

public class DrawingViewController: UIViewController, DrawingViewDelegate {
    // MARK: - IBOutlets
    @IBOutlet weak var drawingView: DrawingView!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var guideLabel: UILabel!
    @IBOutlet weak var canvasSize: NSLayoutConstraint!
    
    // MARK: - Private properties
    private let drawnImageClassifier = DrawnImageClassifier()
    private var labelNames: [String] = []
    private var currentChallenge: String? {
        didSet {
            if let currentChallenge = currentChallenge {
                guideLabel.text = "Try drawing: \(currentChallenge)"
            }
            else {
                guideLabel.text = "Freeplay"
            }
        }
    }
    private var currentPrediction: DrawnImageClassifierOutput? {
        didSet {
            if let currentPrediction = currentPrediction {
                
                // display top 5 scores
                let sorted = currentPrediction.category_softmax_scores.sorted { $0.value > $1.value }
                let top5 = sorted.prefix(5)
                resultsLabel.text = top5.map { $0.key }.joined(separator: ", ")
                
                // check if it's correct
                checkChallenge()
            }
            else {
                resultsLabel.text = "Waiting for drawing..."
            }
        }
    }
    
    
    // MARK: - View Controller Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // read labels
        if let path = Bundle.main.path(forResource: "labels", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let labelNames = data.components(separatedBy: .newlines).filter { $0.count > 0 }
                self.labelNames.append(contentsOf: labelNames)
            } catch {
                print("error loading labels: \(error)")
            }
        }
        
        // setup drawing view and start challenge
        drawingView.delegate = self
        newChallenge()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // set stroke width to 4% of the width
        let strokeWidth = drawingView.bounds.width * 0.04
        drawingView.strokeWidth = strokeWidth
        
        // set size of canvas
        canvasSize.constant = min(view.bounds.width, view.bounds.height) * 0.7
    }
    
    
    // MARK: - IBActions
    @IBAction func clearButtonTapped(_ sender: Any) {
        clearDrawingView()
    }
    
    @IBAction func nextChallengeButtonTapped(_ sender: Any) {
        newChallenge()
    }
    
    
    // MARK: - Game methods
    private func newChallenge() {
        clearDrawingView()
        currentChallenge = labelNames[Int(arc4random()) % labelNames.count]
    }
    
    private func checkChallenge() {
        guard let currentChallenge = currentChallenge,
            let currentPrediction = currentPrediction else {
            return
        }
        
        if currentPrediction.category == currentChallenge {
            newChallenge()
        }
    }
    
    
    // MARK: - Delegate methods
    private func clearDrawingView() {
        // clear view and reset label
        drawingView.clear()
        currentPrediction = nil
    }
    
    public func didEndDrawing() {
        // get image and resize it
        let image = UIImage(view: drawingView)
        let resized = image.resize(newSize: CGSize(width: 28, height: 28))
        
        guard let pixelBuffer = resized.grayScalePixelBuffer() else {
            print("couldn't create pixel buffer")
            return
        }
        
        do {
            currentPrediction = try drawnImageClassifier.prediction(image: pixelBuffer)
        }
        catch {
            print("error making prediction: \(error)")
        }
    }
}
