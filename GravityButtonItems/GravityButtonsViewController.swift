//
//  GravityButtonsViewController.swift
//  GravityButtonItems
//
//  Created by Killua Zoldyck on 4/16/25.
//

import UIKit
import CoreMotion
import SwiftUI

class GravityButtonsViewController: UIViewController {

    // Properties
    var animator: UIDynamicAnimator?
    var gravityBehavior: UIGravityBehavior?
    var collisionBehavior: UICollisionBehavior?
    var itemBehavior: UIDynamicItemBehavior?

    let motionManager = CMMotionManager()
    var buttons: [UIButton] = []
    var buttonConfigs: [ButtonConfig] = [] // Store button configurations
    var selectedButtonIDs: Set<String> = Set() // Track selected button IDs

    private let selectedIDsUserDefaultsKey = "selectedButtonIDsKey" // Key for UserDefaults
    
    // Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[UIKit VC] viewDidLoad")
        view.backgroundColor = .clear
        loadSelectedIDs() // Load saved selections
        setupButtonConfigs() // Setup configs first
        setupButtons()
        setupDynamics()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("[UIKit VC] viewDidAppear")
        startMotionUpdates()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("[UIKit VC] viewWillDisappear")
        stopMotionUpdates()
    }

    // Setup Methods
    func setupButtonConfigs() {
        buttonConfigs = [
            ButtonConfig(id: "btn1", title: "1", color: .purple),
            ButtonConfig(id: "btn2", title: "2", color: .blue),
            ButtonConfig(id: "btn3", title: "3", color: .green),
            ButtonConfig(id: "btn4", title: "4", color: .orange),
            ButtonConfig(id: "btn5", title: "5", color: .red),
            ButtonConfig(id: "btn6", title: "6", color: .cyan),
            ButtonConfig(id: "btn7", title: "7", color: .mint),
            ButtonConfig(id: "btn8", title: "8", color: .indigo),
            ButtonConfig(id: "btn9", title: "9", color: .pink),
            ButtonConfig(id: "btn10", title: "10", color: .yellow)
        ]
    }

    func setupButtons() {
        print("[UIKit VC] Setting up buttons...")
        let buttonSize = CGSize(width: 100, height: 50)
        let spacing: CGFloat = 5

        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()

        for (index, config) in buttonConfigs.enumerated() {
            let button = UIButton(type: .custom)
            button.tag = index
            button.setTitle(config.title, for: .normal)
            
            updateButtonAppearance(button, config: config, isSelected: selectedButtonIDs.contains(config.id))

            button.layer.cornerRadius = config.cornerRadius
            button.layer.borderWidth = 1.5
            button.layer.borderColor = UIColor.clear.cgColor 
            button.clipsToBounds = true

            let randomX = CGFloat.random(in: view.bounds.minX + spacing...max(view.bounds.minX + spacing, view.bounds.maxX - buttonSize.width - spacing))
            let randomY = CGFloat.random(in: view.safeAreaInsets.top + spacing...max(view.safeAreaInsets.top + spacing, view.bounds.midY - buttonSize.height / 2))

            // Ensure frame calculation is valid even if bounds are zero initially
             if view.bounds.width > 0 && view.bounds.height > 0 {
                button.frame = CGRect(origin: CGPoint(x: randomX, y: randomY), size: buttonSize)
             } else {
                 // Provide a default small frame if view bounds aren't ready
                 button.frame = CGRect(origin: .zero, size: buttonSize)
             }

            // Add tap action
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

            view.addSubview(button)
            buttons.append(button)
        }
         if view.bounds != .zero {
             view.setNeedsLayout()
             view.layoutIfNeeded()
         }
    }
    
     override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
         if animator == nil {
             buttons.forEach { button in
                 if button.frame.origin == .zero && view.bounds != .zero {
                     let buttonSize = button.frame.size
                     let spacing: CGFloat = 5
                      let randomX = CGFloat.random(in: view.bounds.minX + spacing...max(view.bounds.minX + spacing, view.bounds.maxX - buttonSize.width - spacing))
                      let randomY = CGFloat.random(in: view.safeAreaInsets.top + spacing...max(view.safeAreaInsets.top + spacing, view.bounds.midY - buttonSize.height / 2))
                      button.frame.origin = CGPoint(x: randomX, y: randomY)
                 }
             }
             // Now that frames are potentially correct, setup dynamics if not already done
             if animator == nil && !buttons.isEmpty && view.bounds != .zero { // Added bounds check
                  print("[UIKit VC] Setting up dynamics after layout...")
                 setupDynamics()
             }
         }
     }

    func setupDynamics() {
        // Ensure setup only happens once and buttons are ready
        guard animator == nil, !buttons.isEmpty, view.bounds != .zero else {
             if view.bounds == .zero { print("[UIKit VC] Warning: View bounds are zero during setupDynamics attempt.") }
            return
        }
        print("[UIKit VC] Setting up Dynamics...")

        animator = UIDynamicAnimator(referenceView: view)

        gravityBehavior = UIGravityBehavior(items: buttons)
        gravityBehavior?.gravityDirection = CGVector(dx: 0, dy: 1.0) // Initial

        collisionBehavior = UICollisionBehavior(items: buttons)
        collisionBehavior?.translatesReferenceBoundsIntoBoundary = true

        itemBehavior = UIDynamicItemBehavior(items: buttons)
        itemBehavior?.elasticity = 0.6
        itemBehavior?.friction = 0.05
        itemBehavior?.density = 0.2
        itemBehavior?.resistance = 0.05
        itemBehavior?.angularResistance = 0.1
        itemBehavior?.allowsRotation = true

        animator?.addBehavior(gravityBehavior!)
        animator?.addBehavior(collisionBehavior!)
        animator?.addBehavior(itemBehavior!)
        print("[UIKit VC] Dynamics setup complete.")
    }

    func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("[UIKit VC] Error: Device Motion not available.")
            return
        }
        guard animator != nil else {
             print("[UIKit VC] Warning: Attempting to start motion updates before animator is ready.")
            return
        }

        if motionManager.isDeviceMotionActive {
            print("[UIKit VC] Motion updates already active.")
            return
        }

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0

        print("[UIKit VC] Starting device motion updates...")
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
            guard let self = self, let motion = motion else { return } // Ensure self and motion exist

            if let error = error {
                print("[UIKit VC] Device motion update error: \(error.localizedDescription)")
                self.stopMotionUpdates() // Stop on error
                return
            }

            let gravity = motion.gravity
            let dx = CGFloat(gravity.x)
            let dy = CGFloat(-gravity.y)

            // Ensure gravity behavior exists before updating
            self.gravityBehavior?.gravityDirection = CGVector(dx: dx, dy: dy)
        }
    }

     func stopMotionUpdates() {
         if motionManager.isDeviceMotionActive {
             print("[UIKit VC] Stopping device motion updates.")
             motionManager.stopDeviceMotionUpdates()
         }
     }

    // Deinitialization
    deinit {
        print("[UIKit VC] Deinitializing. Stopping motion updates.")
        stopMotionUpdates()
        if let animator = animator {
             animator.removeAllBehaviors()
        }
        self.animator = nil
    }

    // Button Actions
    @objc func buttonTapped(_ sender: UIButton) {
        guard sender.tag >= 0 && sender.tag < buttonConfigs.count else {
             print("[UIKit VC] Error: Button tapped with invalid tag: \(sender.tag)")
             return
         }
        let config = buttonConfigs[sender.tag]
        let buttonID = config.id
        
        if selectedButtonIDs.contains(buttonID) {
            selectedButtonIDs.remove(buttonID)
            print("[UIKit VC] Button Deselected: \(buttonID)")
        } else {
            selectedButtonIDs.insert(buttonID)
            print("[UIKit VC] Button Selected: \(buttonID)")
        }
        
        saveSelectedIDs()
        
        updateButtonAppearance(sender, config: config, isSelected: selectedButtonIDs.contains(buttonID))
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
    }
    
    // Persistence (UserDefaults)
    func saveSelectedIDs() {
        let idsArray = Array(selectedButtonIDs)
        UserDefaults.standard.set(idsArray, forKey: selectedIDsUserDefaultsKey)
        print("[UIKit VC] Saved selected IDs: \(idsArray)")
    }
    
    func loadSelectedIDs() {
        if let idsArray = UserDefaults.standard.array(forKey: selectedIDsUserDefaultsKey) as? [String] {
            selectedButtonIDs = Set(idsArray)
            print("[UIKit VC] Loaded selected IDs: \(idsArray)")
        } else {
            print("[UIKit VC] No saved selected IDs found.")
            // Initialize with empty set if nothing is saved (already default)
            selectedButtonIDs = Set()
        }
    }
    
    // Appearance Update
    func updateButtonAppearance(_ button: UIButton, config: ButtonConfig, isSelected: Bool) {
        let backgroundColor = isSelected ? config.selectedBackgroundColor : config.unselectedBackgroundColor
        let textColor = isSelected ? config.selectedTextColor : config.unselectedTextColor
        let swiftUIFont = config.font
        
        button.backgroundColor = UIColor(backgroundColor)
        button.setTitleColor(UIColor(textColor), for: .normal)
        

        let fontDescription = String(describing: swiftUIFont)
        var uiFont = UIFont.systemFont(ofSize: 15, weight: .medium)

        if let sizeRange = fontDescription.range(of: #"size: (\d+(\.\d+)?)"#, options: .regularExpression),
           let sizeString = fontDescription[sizeRange].components(separatedBy: ": ").last,
           let size = Double(sizeString) {
            
            var weight: UIFont.Weight = .medium
            if fontDescription.contains(".bold") { weight = .bold }
            else if fontDescription.contains(".semibold") { weight = .semibold }
            else if fontDescription.contains(".light") { weight = .light }
            else if fontDescription.contains(".thin") { weight = .thin }
            else if fontDescription.contains(".black") { weight = .black }
            
            uiFont = UIFont.systemFont(ofSize: CGFloat(size), weight: weight)
        }
        button.titleLabel?.font = uiFont
    }
}
