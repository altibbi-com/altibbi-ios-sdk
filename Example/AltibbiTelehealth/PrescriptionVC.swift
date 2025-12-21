//
//  PrescriptionVC.swift
//  AltibbiTelehealth_Example
//
//  Created by Mahmoud Johar on 24/12/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import Foundation
import PDFKit

class PrescriptionVC: UIViewController {

    var receivedData: URL?
    var pdfView: PDFView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if receivedData != nil {
            DispatchQueue.main.async {
                self.pdfView = PDFView(frame: self.view.bounds)
                self.view.addSubview(self.pdfView)
                if let pdfDocument = PDFDocument(url: self.receivedData!) {
                    self.pdfView.document = pdfDocument
                }
            }
        }
    }

}
