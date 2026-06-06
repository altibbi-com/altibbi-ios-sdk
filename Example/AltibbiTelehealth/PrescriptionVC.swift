import UIKit
import Foundation
import PDFKit

class PrescriptionVC: UIViewController {

    var receivedData: URL?
    private var pdfView: PDFView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Prescription"
        view.backgroundColor = AppColors.background
        setupPDFView()
    }

    private func setupPDFView() {
        pdfView = PDFView(frame: view.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.backgroundColor = AppColors.background
        pdfView.autoScales = true
        view.addSubview(pdfView)

        if let url = receivedData, let document = PDFDocument(url: url) {
            pdfView.document = document
        }
    }
}
