//
//  ButtonConfig.swift
//  GravityButtonItems
//
//  Created by Killua Zoldyck on 4/16/25.
//

import SwiftUI

public struct ButtonConfig: Identifiable {
    public let id: String
    public let title: String
    public var font: Font
    public var cornerRadius: CGFloat
    
    public var selectedBackgroundColor: Color
    public var selectedTextColor: Color
    public var unselectedBackgroundColor: Color
    public var unselectedTextColor: Color
    
    public init(id: String,
                title: String,
                color: Color, 
                font: Font = .system(size: 25, weight: .bold),
                cornerRadius: CGFloat = 25,
                selectedTextColor: Color = .white,
                unselectedBackgroundColor: Color? = nil) {
        
            self.id = id
            self.title = title
            self.font = font
            self.cornerRadius = cornerRadius

            self.selectedBackgroundColor = color
            self.selectedTextColor = selectedTextColor
            self.unselectedBackgroundColor = unselectedBackgroundColor ?? color.opacity(0.2)
            self.unselectedTextColor = color
        }
}
