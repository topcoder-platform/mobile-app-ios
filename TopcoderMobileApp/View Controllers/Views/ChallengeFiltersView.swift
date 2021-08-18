//
//  ChallengeFiltersView.swift
//  TopcoderMobileApp
//
//  Created by Volkov Alexander on 8/14/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import SwiftUI

/// Filters view
struct ChallengeFiltersView: View {
    
    @EnvironmentObject var data: ChallengesDataSource
    
    /// the selected filter
    @Binding var filter: ChallengeFilter
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 17) {
                Button(action: {
                    data.setFilter(.allActive)
                }, label: {
                    ChallengeFilterTopItem(title: "Active", selected: filter != .past)
                        .padding(.leading, 24)
                })
                Button(action: {
                    data.setFilter(.past)
                }, label: {
                    ChallengeFilterTopItem(title: "Past Challenges", selected: filter == .past)
                })
                Spacer()
            }
            .frame(height: 44)
            .background(Color(UIColor(0xfafafb)))
            if filter != .past {
                Divider()
                VStack(alignment: .leading, spacing: 3) {
                    VStack(alignment: .leading, spacing: 0) {
                        Button(action: {
                            data.setFilter(.allActive)
                        }, label: {
                            ChallengeFilterMiddleItem(title: "All Challenges", selected: filter == .allActive)
                        })
                        
                        Button(action: {
                            data.setFilter(.my)
                        }, label: {
                            ChallengeFilterMiddleItem(title: "My Challenges", selected: filter == .my)
                        })
                        
                        Button(action: {
                            data.setFilter(.allOpen)
                        }, label: {
                            ChallengeFilterMiddleItem(title: "Open for registration", selected: filter == .allOpen)
                        })

                    }
                    Divider()
                        .padding(.top, filter == .allOpen ? 12 : 0)
                        .padding(.bottom, filter == .openForReview ? 12 : 0)
                    
                    Button(action: {
                        data.setFilter(.openForReview)
                    }, label: {
                        ChallengeFilterMiddleItem(title: "Open for Review", selected: filter == .openForReview)
                    })
                    
                    if filter != .openForReview {
                        Divider()
                    }
                }
                .padding(14)
                .background(Color.white)
            }
        }
        .foregroundColor(Color.black)
        .cornerRadius(8)
        .frame(maxWidth: .infinity)
    }
}

/// The top filter item
struct ChallengeFilterTopItem: View {
    
    var title: String
    var selected: Bool
    
    /// the color of the highlighted
    let highlightColor = Color(0x2db68b)
    
    var body: some View {
        if selected {
            Text(title)
                .bold(size: 11)
                .frame(maxHeight: .infinity)
                .addBottomBorder(highlightColor)
        }
        else {
            Text(title)
                .regular(size: 11)
                .frame(maxHeight: .infinity)
        }
    }
}

/// The subfilter item
struct ChallengeFilterMiddleItem: View {
    
    var title: String
    var selected: Bool
    var count: Int?
    
    /// the color of the highlighted
    let highlightColor = Color(0x2db68b)
    
    var body: some View {
        if selected {
            HStack {
                Text(title).padding(.leading, 10)
                Spacer()
                if let count = count {
                    Text("\(count)").padding(.trailing, 10)
                }
            }
            
            .bold(size: 11)
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            .background(Color(0xd5d5d5))
            .cornerRadius(4)
        }
        else {
            HStack {
                Text(title).padding(.leading, 10)
                Spacer()
                if let count = count {
                    Text("\(count)").padding(.trailing, 10)
                }
            }
            .regular(size: 11)
            .frame(maxWidth: .infinity)
            .frame(height: 38)
        }
    }
}

struct ChallengeFiltersView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeFiltersView(filter: .constant(.allOpen))
            .environmentObject(ChallengesDataSource())
            .padding()
            .background(Color.gray)
    }
}

extension View {
    
    /// Add bottom border
    /// - Parameters:
    ///   - color: the color
    ///   - height: the height
    func addBottomBorder(_ color: Color, height: CGFloat = 2) -> some View {
        self.overlay(Rectangle().frame(width: nil, height: height, alignment: .leading).foregroundColor(color), alignment: .bottom)
    }
}
