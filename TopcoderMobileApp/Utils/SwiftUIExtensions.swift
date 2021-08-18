//
//  SwiftUIExtensions.swift
//  TopcoderMobileApp
//
//  Created by Volkov Alexander on 8/14/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import SwiftUI

extension Color {
    
    /// Create color with sRGB value in 16-format, e.g. 0xFF0000 -> red color
    ///
    /// - Parameter hex: the color in hex
    public init(_ hex: Int) {
        let components = (
            r: Double((hex >> 16) & 0xff) / 255,
            g: Double((hex >> 08) & 0xff) / 255,
            b: Double((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.r, green: components.g, blue: components.b)
    }
    
    /// the text color
    static var text: Color {
        Color.black
    }
}

extension View {
    
    /// apply custom regular font
    public func regular(size: CGFloat) -> some View {
        self.font(Font.system(size: size, weight: .regular))
    }
    
    /// apply custom medium font
    public func medium(size: CGFloat) -> some View {
        self.font(Font.system(size: size, weight: .medium))
    }
    
    /// apply custom semibold font
    public func semibold(size: CGFloat) -> some View {
        self.font(Font.system(size: size, weight: .semibold))
    }
    
    /// apply custom bold font
    public func bold(size: CGFloat) -> some View {
        self.font(Font.system(size: size, weight: .bold))
    }
}
