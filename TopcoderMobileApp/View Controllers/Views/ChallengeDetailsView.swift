//
//  ChallengeDetailsView.swift
//  TopcoderMobileApp
//
//  Created by Volkov Alexander on 8/14/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import SwiftUI
import SwiftEx83

/// the challenge details
struct ChallengeDetailsView: View {
    
    var item: Challenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            // Title
            Text(item.title)
                .semibold(size: 18)
                .padding([.leading, .trailing], 16)
            
            // Tags
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        if let topType = item.type, let challengeType = item.challengeType {
                            TagView(title: topType, color: challengeType.color, textColor: .white)
                            ForEach(item.events?.map({$0.key ?? "-"}) ?? [], id: \.self) { key in
                                TagView(title: key.uppercased(), color: challengeType.secondColor, textColor: challengeType.color)
                            }
                        }
                    }
                    HStack(spacing: 4) {
                        ForEach(item.tags ?? [], id: \.self) { tag in
                            TagView(title: tag)
                        }
                    }
                }
                Button(action: {
                    showStub()
                }, label: {
                    Text("Recommended THRIVE Articles").regular(size: 14)
                })
                .frame(maxWidth: 150)
            }
            .padding([.leading, .trailing], 16)
            // Key information
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    Text("Key Information").medium(size: 9)
                        .foregroundColor(Color(0x737473))
                    Spacer()
                }
                .padding([.leading, .trailing], 10)
                .padding([.top, .bottom], 15)
                HStack(spacing: 30) {
                    let prizes = item.devPrizes
                    let colors: [Color] = [Color(0xfcd659), Color(0xd0d0ce), Color(0x974f33), Color(0xd7d7d7)]
                    ForEach(0..<prizes.count, id: \.self) { i in
                        VStack(alignment: .trailing) {
                            Text(i.toCountString())
                                .regular(size: 12)
                                .foregroundColor(Color(0x737473))
                            Text("$\(prizes[i])")
                                .medium(size: 20)
                                .frame(height: 40)
                                .addBottomBorder(colors[min(colors.count - 1, i)], height: 3)
                        }
                    }
                }
                .padding(.bottom, 20)
                // Buttons
                Button(action: {
                    showStub()
                }, label: {
                    Text("Register").medium(size: 16)
                        .frame(height: 40)
                        .frame(maxWidth: 250)
                        .background(item.passed ? Color.gray : Color(0x096ed3))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                })
                .padding(.bottom, 20)
                
                if let remains = item.registerRemainsString {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Next Deadline:")
                                .regular(size: 14)
                                .foregroundColor(Color.white.opacity(0.5))
                            Text(item.nextDeadLine)
                                .semibold(size: 14)
                                .foregroundColor(.white)
                        }
                        Color.white.opacity(0.2).frame(width: 1, height: 40)
                            .padding(.leading, 20)
                        HStack {
                            Text(remains)
                                .semibold(size: 14)
                                .foregroundColor(.white)
                            Text("until current deadline ends")
                                .regular(size: 14)
                                .foregroundColor(Color.white.opacity(0.5))
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(0x545556))
                }
            }
            
            .frame(maxWidth: .infinity)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(0xb8b9b8), lineWidth: 1)
            )
            .padding(.top, 10)
            .padding(.bottom, 20)
            .padding([.leading, .trailing], 16)
            Divider()
            
            
            // Details
            HStack {
                Text("Challenge Overview")
                    .bold(size: 20)
                Spacer()
            }
            .padding(.top, 40)
            .padding(.bottom, 20)
            .padding([.leading, .trailing], 16)
            Text(item.description?.removeHtmlTags() ?? "-")
                .regular(size: 14)
                .padding([.leading, .trailing], 16)
            Spacer()
        }
        .padding([.top, .bottom], 8)
    }
}

struct ChallengeDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeDetailsView(item: Challenge(name: "NASA HATTB Researcher Prototype Conversion 2", tags: ["Apple", "Swift", "JSON", "iOS"], type: "Challenge", track: "Design"))
    }
}

extension String {
    
    /// Remove html tags from the string and keep plain text
    ///
    /// - Returns: the plain text
    func removeHtmlTags() -> String {
        var str = self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        
        // Remove long spaces with single space symbol
        str = str.replaceDuplicates(" ").replaceDuplicates("\n ")
        return str
    }
    
    /// Replaces duplicates
    /// - Parameter search: the string to search
    func replaceDuplicates(_ search: String) -> String {
        var str = self
        var lenBefore: Int!
        var lenAfter: Int!
        repeat {
            lenBefore = str.length
            str = str.replacingOccurrences(of: "\(search)\(search)", with: search, options: .literal, range: nil)
            lenAfter = str.length
        } while lenAfter != lenBefore
        return str
    }
}

extension Int {
    
    /// Convert to count string
    func toCountString() -> String {
        let i = self
        if i == 0 { return "1st" }
        else if i == 1 { return "2nd" }
        else if i == 2 { return "3rd" }
        else { return "\(i+1)th" }
    }
}
