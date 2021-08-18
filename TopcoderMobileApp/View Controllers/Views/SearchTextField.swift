//
//  SearchTextField.swift
//  TopcoderMobileApp
//
//  Created by Volkov Alexander on 8/14/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import SwiftUI

/// The search field
struct SearchTextField: View {
    
    var title: String
    @Binding var text: String
    
    var placeholder: String {
        return "\(title)"
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .top
            ), content: {
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        HStack(spacing: 11) {
                            Image(systemName: "magnifyingglass")
                                .medium(size: 18)
                            Text(placeholder)
                            Spacer()
                        }
                    }
                    .foregroundColor(Color(0xaaaaaa))
                    .regular(size: 15)
                    .frame(height: 40)
                    .multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 0, leading: .padding + (!text.isEmpty ? 30 : 0), bottom: 0, trailing: .padding))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(0xaaaaaa), lineWidth: 1)
                        
                    )
                    .overlay(ZStack {
                        if !text.isEmpty {
                            HStack(spacing: 3) {
                                Image(systemName: "magnifyingglass")
                                    .medium(size: 18)
                                    .foregroundColor(Color(0xaaaaaa))
                                Spacer()
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color.white.opacity(0.55))
                                    .onTapGesture {
                                        text = ""
                                    }
                            }
                            .padding([.leading, .trailing], 15)
                            .regular(size: 15)
                        }
                    })
            })
        }
    }
}

struct SearchTextField_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
            SearchTextField(title: "Search", text: Binding(get: {"123"}, set: {_ in }))
        }
        .previewLayout(.fixed(width: 300, height: 100))
    }
}

extension CGFloat {
    
    /// paddings
    static let padding: CGFloat = 15
}

extension View {
    
    /// Adds placeholder to the view
    /// - Parameters:
    ///   - show: true - show, false - hide
    ///   - alignment: the alignment
    ///   - placeholder: the placeholder content
    func placeholder<Content: View>(when show: Bool, alignment: Alignment = .center, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(show ? 1 : 0)
            self
        }
    }
}
