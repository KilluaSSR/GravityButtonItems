//
//  GravityBoxView.swift
//  GravityButtonItems
//
//  Created by Killua Zoldyck on 4/16/25.
//

import SwiftUI
import UIKit 

struct GravityBoxView: UIViewControllerRepresentable {

    typealias UIViewControllerType = GravityButtonsViewController

    func makeUIViewController(context: Context) -> GravityButtonsViewController {
        print("[SwiftUI Representable] makeUIViewController")
        let viewController = GravityButtonsViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: GravityButtonsViewController, context: Context) {
        print("[SwiftUI Representable] updateUIViewController (frame: \(uiViewController.view.frame))")
    }

    static func dismantleUIViewController(_ uiViewController: GravityButtonsViewController, coordinator: ()) {
        print("[SwiftUI Representable] dismantleUIViewController")
    }
}
