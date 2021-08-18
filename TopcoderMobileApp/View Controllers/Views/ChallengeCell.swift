//
//  ChallengeCell.swift
//  TopcoderMobileApp
//
//  Created by Volkov Alexander on 8/14/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import SwiftUI

/// Challenge type
enum ChallengeType: String {
    case code, design, f2f, dataScience, qa, unknown
    
    /// the color of the UI element in "Challenges" screen
    var color: Color {
        switch self {
        case .code, .f2f: return Color(0x3a8537)
        case .design: return Color(0x1477a3)
        case .dataScience: return Color(0xb74d15)
        case .qa: return Color(0x7f39a7)
        case .unknown: return Color.gray
        }
    }
    
    /// shortcut text for the type
    var short: String {
        switch self {
        case .code: return "Cd"
        case .design: return "CH"
        case .f2f: return "F2F"
        case .dataScience: return "CH"
        case .qa: return "QA"
        case .unknown: return "?"
        }
    }
    
    /// the second color
    var secondColor: Color {
        color.opacity(0.3)
    }
}

/// The challenge cell view
struct ChallengeCell: View {
    
    var item: Challenge
    var type: ChallengeType {
        item.challengeType ?? .unknown
    }
    
    /// Date formatter for the view
    static var endDateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MMM dd"
        return f
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 15) {
                VStack(spacing: 1) {
                    Text(type.short).frame(width: 30, height: 30, alignment: .center)
                        .background(type.color)
                        .cornerRadius(2)
                        .foregroundColor(.white)
                        .semibold(size: 13)
                    if !(item.events ?? []).isEmpty {
                        Text("TCO").frame(width: 30, height: 20, alignment: .center)
                            .background(type.secondColor)
                            .cornerRadius(2)
                            .foregroundColor(type.color)
                            .semibold(size: 9)
                    }
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text(item.title)
                        .semibold(size: 15)
                    
                    HStack(spacing: 12) {
                        let endsString = item.ends != nil ? ChallengeCell.endDateFormatter.string(from: item.ends!) : "-"
                        Text("Ends \(endsString)")
                            .regular(size: 13)
                            .foregroundColor(Color.black.opacity(0.5))
                        HStack(spacing: 5) {
                            ForEach(item.tags ?? [], id: \.self) { item in
                                TagView(title: item)
                            }
                        }
                    }
                    
                    // Prizes
                    VStack(alignment: .leading, spacing: 4) {
                        Text("$\(item.prize)").font(Font.system(size: 13, weight: .semibold))
                        // TODO check how to get tech stack - element is ready, but commented because there is no field in API response
//                        TagView(title: "Purse", color: Color(0xfafafb))
                    }
                    
                    // Phase
                    HStack {
                        Text("Submission")
                            .font(Font.system(size: 13, weight: .regular))
                            .foregroundColor(Color.black)
                        Spacer()
                        HStack(spacing: 2) {
                            Image(systemName: "person")
                                .foregroundColor(Color.gray)
                                .regular(size: 16)
                            Text("\(item.numOfRegistrants ?? 0)")
                                .padding(.trailing, 20)
                            Image(systemName: "doc")
                                .foregroundColor(Color.gray)
                                .regular(size: 16)
                            Text("\(item.numOfSubmissions ?? 0)")
                        }
                        .font(Font.system(size: 12, weight: .regular))
                    }
                    
                    // Progress
                    // TODO add logic for progress bar value
                    ProgressView(percent: 0.6)
                        .frame(height: 4)
                }
            }
            .padding(13)
            .padding(.top, 3)
            .padding(.bottom, 30-13) // as in design
            .background(Color.white)
            let str = item.registerRemainsString
            if let str = str {
                Divider()
                HStack {
                    Text("\(str) to register")
                        .frame(height: 44)
                        .padding(.leading, 50)
                        .bold(size: 15)
                        .foregroundColor(Color(0x4d92df))
                    Spacer()
                }
                .background(Color(UIColor(0xfafafb)))
            }
        }
        .foregroundColor(.black)
        .cornerRadius(8)
        .frame(maxWidth: .infinity)
    }
}

/// Tag view
struct TagView: View {
    
    /// the text for the tag
    let title: String
    /// the color of the background
    var color: Color = Color(0xebebeb)
    /// the text color
    var textColor: Color = .black
    
    var body: some View {
        Text(title)
            .frame(height: 20, alignment: .center)
            .padding([.leading, .trailing], 5)
            .background(color)
            .cornerRadius(3)
            .foregroundColor(textColor)
            .font(Font.system(size: 10, weight: .medium))
            
    }
}

/// Progress view
struct ProgressView: View {
    var percent: CGFloat
    
    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Color.gray.frame(width: g.size.width, height: g.size.height, alignment: .leading)
                    .cornerRadius(g.size.height / 2)
                Color(UIColor(0x76d127)).frame(width: g.size.width * percent, height: g.size.height, alignment: .leading)
                    .cornerRadius(g.size.height / 2)
            }
        }
    }
}

struct ChallengeCell_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeCell(item: Challenge(name: "72h Ognomy MVP Web Portal UI Prototype Challenge UI Prototype Challenge"))
    }
}
